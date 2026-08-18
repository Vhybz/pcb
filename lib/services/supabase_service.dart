import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/inspection.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  StreamSubscription<AuthState> onAuthStateChange(void Function(AuthChangeEvent, Session?) callback) {
    return _supabase.auth.onAuthStateChange.listen((data) {
      callback(data.event, data.session);
    });
  }

  // --- Authentication ---

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String profession,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'phone': phone,
        'profession': profession,
      },
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // --- Profile ---

  Future<Map<String, dynamic>?> getProfile() async {
    if (currentUser == null) return null;
    return await _supabase
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();
  }

  Future<void> updateProfile({
    String? username,
    String? phone,
    String? profession,
    String? avatarUrl,
  }) async {
    if (currentUser == null) return;
    
    final updates = {
      'id': currentUser!.id,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (username != null) updates['username'] = username;
    if (phone != null) updates['phone'] = phone;
    if (profession != null) updates['profession'] = profession;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabase.from('profiles').upsert(updates);
  }

  Future<void> updateFcmToken(String token) async {
    if (currentUser == null) return;
    await _supabase.from('profiles').update({
      'fcm_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser!.id);
  }

  Future<String?> uploadAvatar(Uint8List bytes) async {
    if (currentUser == null) return null;
    
    final fileName = '${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'avatars/$fileName';

    await _supabase.storage.from('avatars').uploadBinary(path, bytes);

    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  // --- Inspections ---

  Future<void> saveInspection(Inspection inspection, String imagePath) async {
    if (currentUser == null) return;

    // 1. Prepare Bytes
    Uint8List bytes;
    if (imagePath.startsWith('assets/')) {
      final byteData = await rootBundle.load(imagePath);
      bytes = byteData.buffer.asUint8List();
    } else {
      // XFile works on both Web and Mobile/Desktop
      bytes = await XFile(imagePath).readAsBytes();
    }

    await saveInspectionWithBytes(inspection, bytes);
  }

  Future<void> saveInspectionWithBytes(Inspection inspection, Uint8List bytes) async {
    if (currentUser == null) return;

    // 2. Upload Image
    final fileName = '${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = 'pcb_images/$fileName';

    await _supabase.storage.from('pcb_images').uploadBinary(storagePath, bytes);
    final imageUrl = _supabase.storage.from('pcb_images').getPublicUrl(storagePath);

    // 3. Save Inspection
    final inspectionData = await _supabase.from('inspections').insert({
      'user_id': currentUser!.id,
      'status': inspection.status == InspectionStatus.pass ? 'pass' : 'fail',
      'image_url': imageUrl,
      'defect_count': inspection.defects.length,
    }).select().single();

    final inspectionId = inspectionData['id'];

    // 4. Save Defects
    if (inspection.defects.isNotEmpty) {
      final defectsData = inspection.defects.map((d) => {
        'inspection_id': inspectionId,
        'class_name': d.className,
        'confidence': d.confidence,
        'severity': d.severity.name,
        'location_info': d.location,
        'bounding_box': {
          'x': d.boundingBox.x,
          'y': d.boundingBox.y,
          'w': d.boundingBox.width,
          'h': d.boundingBox.height,
        },
      }).toList();

      await _supabase.from('defects').insert(defectsData);
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    if (currentUser == null) return [];
    return await _supabase
        .from('inspections')
        .select('*, defects(*)')
        .eq('user_id', currentUser!.id)
        .order('timestamp', ascending: false);
  }
}
