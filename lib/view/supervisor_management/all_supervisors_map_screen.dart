import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:raptor_pro/view/widgets/common_app_bar.dart';
import 'package:raptor_pro/view/widgets/common_loader.dart';
import 'package:raptor_pro/utils/marker_generator.dart';

class AllSupervisorsMapScreen extends StatefulWidget {
  const AllSupervisorsMapScreen({Key? key}) : super(key: key);

  @override
  State<AllSupervisorsMapScreen> createState() => _AllSupervisorsMapScreenState();
}

class _AllSupervisorsMapScreenState extends State<AllSupervisorsMapScreen> {
  bool isLoading = true;
  String? errorMsg;
  Set<Marker> markers = {};
  LatLng? initialCenter;

  @override
  void initState() {
    super.initState();
    _fetchAllLocations();
  }

  Future<void> _fetchAllLocations() async {
    try {
      final response = await ApiData().getSupervisorLocations();
      if (response != null && response['status'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        Set<Marker> newMarkers = {};
        
        for (var item in dataList) {
          if (item['latitude'] != null && item['longitude'] != null) {
            final lat = double.tryParse(item['latitude'].toString());
            final lng = double.tryParse(item['longitude'].toString());
            
            if (lat == null || lng == null) continue;

            final name = item['name'] ?? 'Supervisor';
            final id = item['id'].toString();
            
            final updatedAt = item['location_updated_at'] ?? item['updated_at'] ?? item['created_at'];
            String lastUpdated = 'Unknown';
            if (updatedAt != null) {
              try {
                final DateTime dt = DateTime.parse(updatedAt.toString()).toLocal();
                lastUpdated = DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
              } catch (e) {
                lastUpdated = updatedAt.toString();
              }
            }

            if (initialCenter == null) {
              initialCenter = LatLng(lat, lng);
            }

            final customIcon = await MarkerGenerator.createCustomMarkerBitmap(name);

            newMarkers.add(
              Marker(
                markerId: MarkerId('supervisor_$id'),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: name,
                  snippet: 'Last Updated: $lastUpdated',
                ),
                icon: customIcon,
              ),
            );
          }
        }

        setState(() {
          markers = newMarkers;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = response?['message'] ?? 'No locations available';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Error fetching locations: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar(
        title: "All Supervisors Location",
        onTap: () => Get.back(),
      ),
      body: isLoading
          ? const Center(child: CommonLoader())
          : errorMsg != null
              ? Center(child: Text(errorMsg!, style: const TextStyle(fontSize: 16, color: Colors.grey)))
              : markers.isEmpty
                  ? const Center(child: Text('No location data available', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: initialCenter ?? const LatLng(0, 0),
                        zoom: 12,
                      ),
                      markers: markers,
                    ),
    );
  }
}
