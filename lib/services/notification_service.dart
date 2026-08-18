import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class NotificationService {
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final SupabaseService _supabase = SupabaseService();

  Future<void> initialize() async {
    try {
      // Check if Firebase is actually initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('Firebase not initialized. Skipping notification setup.');
        return;
      }

      // 1. Request permissions (crucial for iOS and Android 13+)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification permissions granted');
      
      // 2. Get and save the initial token
      try {
        String? token = await _fcm.getToken();
        if (token != null) {
          await _saveToken(token);
        }
      } catch (e) {
        debugPrint('Error getting FCM token: $e');
      }

      // 3. Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) async {
        await _saveToken(newToken);
      });

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground Message: ${message.notification?.title}');
        // You could use local notifications here to show a banner
      });

      // 5. Handle interaction when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened via notification: ${message.data}');
      });
      
    } else {
      debugPrint('Notification permissions denied');
    }
  } catch (e) {
    debugPrint('Firebase Messaging initialization failed: $e');
  }
}

  Future<void> _saveToken(String token) async {
    debugPrint('FCM Token: $token');
    if (_supabase.currentUser != null) {
      try {
        await _supabase.updateFcmToken(token);
      } catch (e) {
        debugPrint('Failed to save FCM token to Supabase: $e');
      }
    }
  }
}
