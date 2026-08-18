# Implementation Plan - Application Architecture for YOLO Integration

This plan outlines the steps to establish a decoupled architecture for PCB defect detection, allowing for future YOLO integration while providing a mock implementation for immediate use.

## Proposed Changes

### Models

#### [MODIFY] [defect.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/models/defect.dart)
- Rename `name` to `className` to better align with object detection terminology.
- Ensure all required fields (`className`, `confidence`, `boundingBox`, `severity`, `location`) are present.

### Services

#### [MODIFY] [detection_service.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/services/detection_service.dart)
- Keep the abstract class `DetectionService` as the interface for detection.

#### [NEW] [mock_detection_service.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/services/mock_detection_service.dart)
- Create `MockDetectionService` implementing `DetectionService`.
- Return a realistic list of `Defect` objects after a simulated delay.

#### [MODIFY] [app_state.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/services/app_state.dart)
- Add `DetectionService` as a dependency (via constructor injection).
- Add a method to perform detection using the service and update the state.

### UI Integration

#### [MODIFY] [main.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/main.dart)
- Initialize `MockDetectionService` and provide it to `AppState`.

#### [MODIFY] [analysis_screen.dart](file:///C:/Users/DELL/StudioProjects/pcb/lib/screens/analysis/analysis_screen.dart)
- Use the `DetectionService` from `AppState` to trigger actual (mocked) detection.
- Wait for the detection to complete before navigating to the result screen.

## Verification Plan

### Automated Tests
- Create a unit test for `MockDetectionService` to ensure it returns the expected mock defects.
- Create a test for `AppState` to verify it correctly handles detection results.

### Manual Verification
- Run the app and navigate through the scanner to the analysis screen.
- Verify that the "Analysis" phase takes time and then displays the result screen with (mock) defects.
- Check that the dashboard/history reflects the newly added "inspections".
