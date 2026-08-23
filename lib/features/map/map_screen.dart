import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';
import '../../data/services/location_service.dart';
import '../../data/services/database_service.dart';
import '../../data/models/incident_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // Default initial camera position
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(39.8283, -98.5795),
    zoom: 4.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationServiceProvider.notifier).initializeAndGetLocation();
    });
  }

  void _recenterMap() async {
    final locationState = ref.read(locationServiceProvider);
    if (locationState.position != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationState.position!.latitude, locationState.position!.longitude),
          zoom: 15.0,
        ),
      ));
    } else {
      // If position is null, try to initialize again
      ref.read(locationServiceProvider.notifier).initializeAndGetLocation();
    }
  }

  Set<Marker> _buildMarkers(BuildContext context, List<IncidentModel> incidents) {
    final markers = <Marker>{};
    final currentUser = FirebaseAuth.instance.currentUser;
    
    for (final incident in incidents) {
      // Only show verified incidents or pending incidents created by the current user
      if (incident.verificationStatus != VerificationStatus.verified && incident.reportedBy != currentUser?.uid) {
        continue;
      }
      
      // Determine color based on severity
      double hue;
      switch (incident.severity) {
        case IncidentSeverity.critical:
        case IncidentSeverity.high:
          hue = BitmapDescriptor.hueRed;
          break;
        case IncidentSeverity.medium:
          hue = BitmapDescriptor.hueOrange;
          break;
        case IncidentSeverity.low:
          hue = BitmapDescriptor.hueYellow;
          break;
      }

      markers.add(
        Marker(
          markerId: MarkerId(incident.id),
          position: LatLng(incident.latitude, incident.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          onTap: () {
            if (incident.verificationStatus == VerificationStatus.verified) {
              context.push('/incident_detail', extra: incident);
            }
          },
          infoWindow: InfoWindow(
            title: incident.title,
            snippet: incident.verificationStatus == VerificationStatus.pending ? 'Pending Verification' : 'Verified',
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationServiceProvider);
    final incidentsAsyncValue = ref.watch(nearbyIncidentsStreamProvider);
    
    final incidents = incidentsAsyncValue.asData?.value ?? [];

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: locationState.status == LocationStatus.ready,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _buildMarkers(context, incidents),
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
          ),
          
          // Search Bar Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Find locations...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.filter_list),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),

          // Map Controls & Permission State Overlay
          SafeArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Location State Overlay
                    if (locationState.status != LocationStatus.ready && locationState.status != LocationStatus.initial)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_off, color: Theme.of(context).colorScheme.onErrorContainer, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              locationState.status == LocationStatus.loading ? 'Locating...' : 'Location Unavailable',
                              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    
                    // Recenter Button
                    Card(
                      child: IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _recenterMap,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Zoom Controls
                    Card(
                      child: Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add), 
                            onPressed: () async {
                              final controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.zoomIn());
                            }
                          ),
                          const Divider(height: 1),
                          IconButton(
                            icon: const Icon(Icons.remove), 
                            onPressed: () async {
                              final controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.zoomOut());
                            }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomSheetTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 0)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text('Nearby Incidents', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    
                    // Reactive List of Incidents
                    incidentsAsyncValue.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No recent incidents found.'),
                          );
                        }
                        return Column(
                          children: data.map((incident) {
                            final currentUser = FirebaseAuth.instance.currentUser;
                            // Hide unverified incidents unless owned by current user
                            if (incident.verificationStatus != VerificationStatus.verified && incident.reportedBy != currentUser?.uid) {
                              return const SizedBox.shrink();
                            }
                            
                            RiskLevel riskLevel;
                            switch (incident.severity) {
                              case IncidentSeverity.critical:
                              case IncidentSeverity.high:
                                riskLevel = RiskLevel.high;
                                break;
                              case IncidentSeverity.medium:
                                riskLevel = RiskLevel.medium;
                                break;
                              case IncidentSeverity.low:
                                riskLevel = RiskLevel.low;
                                break;
                            }

                            final diff = DateTime.now().difference(incident.timestamp);
                            String timeStr;
                            if (diff.inMinutes < 60) {
                              timeStr = '\${diff.inMinutes} mins ago';
                            } else if (diff.inHours < 24) {
                              timeStr = '\${diff.inHours} hrs ago';
                            } else {
                              timeStr = '\${diff.inDays} days ago';
                            }

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    incident.verificationStatus == VerificationStatus.verified ? Icons.warning : Icons.help_outline, 
                                    color: riskLevel == RiskLevel.high ? AppColors.riskHighDark : AppColors.riskMediumDark
                                  ),
                                  title: Text(incident.title),
                                  subtitle: Text('${incident.verificationStatus == VerificationStatus.verified ? "Verified" : "Pending"} • $timeStr'),
                                  trailing: RiskChip(level: riskLevel),
                                  onTap: () {
                                    if (incident.verificationStatus == VerificationStatus.verified) {
                                      context.push('/incident_detail', extra: incident);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Unverified incidents cannot be viewed in detail.')),
                                      );
                                    }
                                  },
                                ),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error loading incidents: \$err'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Above bottom sheet / nav
        child: FloatingActionButton(
          heroTag: 'emergency_map',
          onPressed: () => context.push('/emergency_support'),
          backgroundColor: AppColors.emergencyDark,
          child: const Icon(Icons.emergency, color: Colors.white),
        ),
      ),
    );
  }
}
