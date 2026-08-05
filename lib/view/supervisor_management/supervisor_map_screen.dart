import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:intl/intl.dart';
import 'package:raptor_pro/utils/marker_generator.dart';

class SupervisorMapScreen extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;
  final String supervisorMobile;

  const SupervisorMapScreen({
    Key? key,
    required this.supervisorId,
    required this.supervisorName,
    this.supervisorMobile = '',
  }) : super(key: key);

  @override
  State<SupervisorMapScreen> createState() => _SupervisorMapScreenState();
}

class _SupervisorMapScreenState extends State<SupervisorMapScreen> {
  bool isLoading = true;
  LatLng? location;
  String? errorMsg;
  String lastUpdated = 'Unknown';
  BitmapDescriptor? markerIcon;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final data = await ApiData().getSupervisorLocation(widget.supervisorId);
      if (data != null && data['status'] == true && data['data'] != null) {
        final latData = data['data']['latitude'];
        final lngData = data['data']['longitude'];
        final updatedAt = data['data']['location_updated_at'] ?? data['data']['updated_at'] ?? data['data']['created_at'];
        
        if (latData == null || lngData == null) {
          setState(() {
            errorMsg = 'Location coordinates are not available yet.';
            isLoading = false;
          });
          return;
        }

        final lat = double.tryParse(latData.toString());
        final lng = double.tryParse(lngData.toString());

        if (lat == null || lng == null) {
           setState(() {
            errorMsg = 'Invalid location coordinates received.';
            isLoading = false;
          });
          return;
        }

        if (updatedAt != null) {
          try {
            final DateTime dt = DateTime.parse(updatedAt.toString()).toLocal();
            // Use intl for neat formatting
            lastUpdated = DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
          } catch (e) {
            lastUpdated = updatedAt.toString();
          }
        }

        // Generate custom marker
        final customIcon = await MarkerGenerator.createCustomMarkerBitmap(widget.supervisorName);

        setState(() {
          location = LatLng(lat, lng);
          markerIcon = customIcon;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = data?['message'] ?? 'Location not available';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Error fetching location: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CommonLoader())
            : Stack(
                children: [
                  // Map Background
                  if (location != null)
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: location!,
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('supervisor_${widget.supervisorId}'),
                          position: location!,
                          infoWindow: InfoWindow(
                            title: widget.supervisorName,
                            snippet: 'Last Updated: $lastUpdated',
                          ),
                          icon: markerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          errorMsg ?? 'Location not available',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),

                  // Top Header Card
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFD32F2F),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.supervisorName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1976D2), // Blue name as requested
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Back Button
                                InkWell(
                                  onTap: () => Get.back(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5C6BC0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.arrow_back, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          'Back',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Text(
                                '${widget.supervisorMobile.isNotEmpty ? "${widget.supervisorMobile} • " : ""}Last updated $lastUpdated',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
