import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:potholedetect/submit.dart';
import 'services/location_service.dart';
import 'widgets/location_widget.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  File? _image;
  final _noteCtrl = TextEditingController();
  int _severity = 3;
  bool _loading = false;
  double? _lat;
  double? _lng;
  String? _address;
  final LocationService _locationService = LocationService();

  // --- Take photo ---
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // --- Get location ---
  Future<void> _getLocation() async {
    setState(() => _loading = true);

    try {
      Map<String, dynamic>? locationData =
          await _locationService.getLocationWithAddress();
      if (locationData != null) {
        setState(() {
          _lat = locationData['latitude'];
          _lng = locationData['longitude'];
          _address = locationData['address'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location captured: ${_address ?? 'Address not available'}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to get location. Please enable location services.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onLocationUpdate(String? address, double? latitude, double? longitude) {
    setState(() {
      _address = address;
      _lat = latitude;
      _lng = longitude;
    });
  }

  // --- Submit (without Firebase Storage) ---
  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You must be logged in to submit a report')));
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please take a photo')));
      return;
    }
    if (_lat == null || _lng == null) {
      await _getLocation();
      if (_lat == null) return;
    }

    setState(() => _loading = true);

    // --- Simulate submission (no Firebase) ---
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    setState(() => _loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ReportSubmittedPage()),
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report a Pothole',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Photo Section ---
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to take photo',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Severity Section ---
              Text(
                'Severity Level',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
              Slider(
                min: 1,
                max: 5,
                divisions: 4,
                value: _severity.toDouble(),
                activeColor: _getSeverityColor(_severity),
                inactiveColor: Colors.grey.shade300,
                onChanged: (v) => setState(() => _severity = v.toInt()),
              ),
              Center(
                child: Text(
                  'Severity $_severity - ${_getSeverityText(_severity)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: _getSeverityColor(_severity),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Notes Section ---
              TextField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  hintText: 'Describe the pothole...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // --- Location Section ---
              LocationWidget(
                onLocationUpdate: _onLocationUpdate,
                showToggle: true,
                showCurrentLocation: true,
              ),
              const SizedBox(height: 32),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Report',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityText(int severity) {
    switch (severity) {
      case 1:
        return 'Minor';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }
}
