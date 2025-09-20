import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/location_service.dart';

class LocationWidget extends StatefulWidget {
  final Function(String? address, double? latitude, double? longitude)? onLocationUpdate;
  final bool showToggle;
  final bool showCurrentLocation;

  const LocationWidget({
    super.key,
    this.onLocationUpdate,
    this.showToggle = true,
    this.showCurrentLocation = true,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  String? _currentAddress;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _locationService.initialize();
    if (_locationService.isLocationEnabled && _locationService.isPermissionGranted) {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationService.isLocationEnabled || !_locationService.isPermissionGranted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? locationData = await _locationService.getLocationWithAddress();
      if (locationData != null) {
        setState(() {
          _currentAddress = locationData['address'];
          _latitude = locationData['latitude'];
          _longitude = locationData['longitude'];
        });

        // Notify parent widget
        widget.onLocationUpdate?.call(_currentAddress, _latitude, _longitude);
      }
    } catch (e) {
      print('Error getting current location: $e');
      _showErrorSnackBar('Failed to get current location');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLocationServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _locationService.toggleLocationServices();
      if (success && _locationService.isLocationEnabled) {
        await _getCurrentLocation();
        _showSuccessSnackBar('Location services enabled');
      } else if (!_locationService.isLocationEnabled) {
        setState(() {
          _currentAddress = null;
          _latitude = null;
          _longitude = null;
        });
        widget.onLocationUpdate?.call(null, null, null);
        _showInfoSnackBar('Location services disabled');
      } else {
        _showErrorSnackBar('Failed to toggle location services');
      }
    } catch (e) {
      print('Error toggling location services: $e');
      _showErrorSnackBar('Error toggling location services');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _locationService.isLocationEnabled 
              ? Colors.green.shade200 
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: _locationService.isLocationEnabled 
                    ? Colors.green.shade600 
                    : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Services',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              if (widget.showToggle)
                Switch(
                  value: _locationService.isLocationEnabled,
                  onChanged: (_) => _toggleLocationServices(),
                  activeColor: Colors.green,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _locationService.isLocationEnabled 
                  ? Colors.green.shade50 
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _locationService.isLocationEnabled 
                    ? Colors.green.shade200 
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _locationService.isLocationEnabled 
                      ? Icons.check_circle 
                      : Icons.location_off,
                  size: 16,
                  color: _locationService.isLocationEnabled 
                      ? Colors.green.shade600 
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  _locationService.getLocationStatusMessage(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _locationService.isLocationEnabled 
                        ? Colors.green.shade700 
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          // Current location display
          if (widget.showCurrentLocation && _currentAddress != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Current Location',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentAddress!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (_latitude != null && _longitude != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          // Action buttons
          if (widget.showCurrentLocation) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || !_locationService.isLocationEnabled 
                        ? null 
                        : _getCurrentLocation,
                    icon: _isLoading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: Text(
                      _isLoading ? 'Getting...' : 'Refresh Location',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (!_locationService.isLocationEnabled) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _toggleLocationServices,
                      icon: const Icon(Icons.location_on, size: 16),
                      label: Text(
                        'Enable',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

