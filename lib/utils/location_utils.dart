import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/location_service.dart';

class LocationUtils {
  static final LocationService _locationService = LocationService();

  /// Show location permission dialog
  static Future<bool> showLocationPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Permission',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'This app needs location permission to show nearby pothole reports and help you report potholes with accurate location data.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Allow',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Show location services disabled dialog
  static Future<bool> showLocationServicesDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Services Disabled',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Location services are disabled. Please enable them in your device settings to use location features.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await _locationService.enableLocationServices();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Enable',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Get current location with error handling
  static Future<Map<String, dynamic>?> getCurrentLocationWithErrorHandling(BuildContext context) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await _locationService.checkLocationServices();
      if (!serviceEnabled) {
        bool shouldEnable = await showLocationServicesDialog(context);
        if (!shouldEnable) return null;
      }

      // Check permissions
      bool hasPermission = await _locationService.checkLocationPermission();
      if (!hasPermission) {
        bool shouldAllow = await showLocationPermissionDialog(context);
        if (!shouldAllow) return null;
      }

      // Get location
      return await _locationService.getLocationWithAddress();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }
  }

  /// Format coordinates for display
  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Get distance text with proper formatting
  static String getDistanceText(double distanceInMeters) {
    return _locationService.formatDistance(distanceInMeters);
  }

  /// Check if location is available
  static Future<bool> isLocationAvailable() async {
    return _locationService.isLocationEnabled && _locationService.isPermissionGranted;
  }
}

