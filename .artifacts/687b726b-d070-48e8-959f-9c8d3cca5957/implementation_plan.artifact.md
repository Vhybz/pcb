# Implementation Plan - PCB Defect Scanner

Build a comprehensive Flutter UI for the "PCB Defect Scanner" application based on the provided industrial design reference.

## User Review Required

> [!IMPORTANT]
> The app will use dummy data and placeholders for the camera. Real camera integration and YOLO model implementation are out of scope for this phase.

## Proposed Changes

### Dependencies & Setup
- Add `go_router`, `google_fonts`, `intl`, and `provider` to `pubspec.yaml`.
- Initialize directory structure.

### Core & Theme
- **[NEW] [app_colors.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/core/constants/app_colors.dart)**: Define the dark navy, bright blue, and status colors (PASS/FAIL/WARN).
- **[NEW] [app_theme.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/core/theme/app_theme.dart)**: Create a Material 3 Dark Theme with Google Fonts (e.g., 'Inter' or 'Roboto').

### Models & Services
- **[NEW] [defect_model.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/models/defect.dart)**: Model for PCB defects.
- **[NEW] [inspection_model.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/models/inspection.dart)**: Model for inspection records.
- **[NEW] [mock_data_service.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/services/mock_data_service.dart)**: Provides realistic dummy data for dashboard and history.

### Navigation
- **[NEW] [app_router.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/routes/app_router.dart)**: Configure GoRouter with routes for all 8 screens.

### Screens Implementation
- **[NEW] Splash Screen**: Logo and loading state.
- **[NEW] Dashboard**: Stats overview and recent inspections.
- **[NEW] PCB Scanner**: Camera UI layout with positioning frame.
- **[NEW] Analyzing PCB**: Progress indicators and AI scan feel.
- **[NEW] Inspection Result**: Bounding boxes on image and defect list.
- **[NEW] Defect Details**: Detailed view of a specific defect.
- **[NEW] Inspection History**: Searchable list of past scans.
- **[NEW] Settings**: App and model configuration.

### Reusable Widgets
- **[NEW] [stat_card.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/widgets/stat_card.dart)**: Dashboard summary cards.
- **[NEW] [inspection_list_tile.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/widgets/inspection_list_tile.dart)**: List item for history/recent scans.
- **[NEW] [defect_list_tile.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/widgets/defect_list_tile.dart)**: List item for detected defects.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure basic widget building (if any tests are added, otherwise manual verification).
- Check for linter errors using `flutter analyze`.

### Manual Verification
- Verify navigation flow: Splash -> Dashboard -> Scanner -> Analyzing -> Result -> Defect Details.
- Check "History" and "Settings" from Dashboard.
- Confirm dark theme adherence to the reference image.
- Ensure buttons respond and navigate correctly.
