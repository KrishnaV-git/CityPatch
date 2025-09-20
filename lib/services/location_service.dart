import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocationEnabled = false;
  bool _isPermissionGranted = false;

  // Getters
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isPermissionGranted => _isPermissionGranted;

  /// Initialize location service and check permissions
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLocationEnabled = false;
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isPermissionGranted = false;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isPermissionGranted = false;
        return false;
      }

      _isLocationEnabled = true;
      _isPermissionGranted = true;
      
      // Load saved location preference
      await _loadLocationPreference();
      
      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      return false;
    }
  }

  /// Get current location with high accuracy
  Future<Position?> getCurrentLocation() async {
    try {
      if (!_isLocationEnabled || !_isPermissionGranted) {
        return null;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = position;
      
      // Get address from coordinates
      await _getAddressFromPosition(position);
      
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get address from position coordinates
  Future<String?> _getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Format address
        List<String> addressParts = [];
        
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        _currentAddress = addressParts.join(', ');
        return _currentAddress;
      }
    } catch (e) {
      print('Error getting address from position: $e');
    }
    return null;
  }

  /// Enable location services
  Future<bool> enableLocationServices() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Request to enable location services
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      _isLocationEnabled = true;
      _isPermissionGranted = true;
      
      // Save preference
      await _saveLocationPreference(true);
      
      return true;
    } catch (e) {
      print('Error enabling location services: $e');
      return false;
    }
  }

  /// Disable location services (app-level)
  Future<bool> disableLocationServices() async {
    try {
      _isLocationEnabled = false;
      _currentPosition = null;
      _currentAddress = null;
      
      // Save preference
      await _saveLocationPreference(false);
      
      return true;
    } catch (e) {
      print('Error disabling location services: $e');
      return false;
    }
  }

  /// Toggle location services
  Future<bool> toggleLocationServices() async {
    if (_isLocationEnabled) {
      return await disableLocationServices();
    } else {
      return await enableLocationServices();
    }
  }

  /// Get location with address
  Future<Map<String, dynamic>?> getLocationWithAddress() async {
    try {
      Position? position = await getCurrentLocation();
      if (position != null) {
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': _currentAddress ?? 'Address not available',
          'accuracy': position.accuracy,
          'timestamp': position.timestamp,
        };
      }
    } catch (e) {
      print('Error getting location with address: $e');
    }
    return null;
  }

  /// Check if location permission is granted
  Future<bool> checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      _isPermissionGranted = permission == LocationPermission.whileInUse || 
                            permission == LocationPermission.always;
      return _isPermissionGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> checkLocationServices() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _isLocationEnabled = serviceEnabled;
      return serviceEnabled;
    } catch (e) {
      print('Error checking location services: $e');
      return false;
    }
  }

  /// Save location preference
  Future<void> _saveLocationPreference(bool enabled) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_enabled', enabled);
    } catch (e) {
      print('Error saving location preference: $e');
    }
  }

  /// Load location preference
  Future<void> _loadLocationPreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isLocationEnabled = prefs.getBool('location_enabled') ?? false;
    } catch (e) {
      print('Error loading location preference: $e');
    }
  }

  /// Get distance between two points in meters
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get distance from current location to given coordinates
  double? getDistanceFromCurrent(double latitude, double longitude) {
    if (_currentPosition == null) return null;
    
    return getDistanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Get location status message
  String getLocationStatusMessage() {
    if (!_isLocationEnabled) {
      return 'Location services are disabled';
    }
    if (!_isPermissionGranted) {
      return 'Location permission not granted';
    }
    if (_currentPosition == null) {
      return 'Location not available';
    }
    return 'Location services active';
  }
}

