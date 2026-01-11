import 'package:permission_handler/permission_handler.dart';

/// Handles all app permissions (Camera, Storage, Biometrics, Location)
/// Required for ID capture, selfie verification, and polling station check
class CamPermissionHandler {
  
  /// Request camera permission for ID capture and selfie
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  /// Request storage permission for saving documents
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  
  /// Request location permission for polling station verification
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
  
  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
  
  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }
  
  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }
  
  /// Request all necessary permissions at once
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.camera,
      Permission.storage,
      Permission.location,
    ].request();
  }
  
  /// Open app settings if permissions are permanently denied
  static Future<void> openSettings() async {
    await openAppSettings();
  }
  
  /// Check if any critical permission is denied
  static Future<bool> hasAllCriticalPermissions() async {
    final camera = await hasCameraPermission();
    final storage = await hasStoragePermission();
    return camera && storage;
  }
}