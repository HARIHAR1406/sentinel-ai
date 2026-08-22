import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';
import '../../data/services/location_service.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // Default initial camera position (e.g., center of the US or a placeholder)
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

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationServiceProvider);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: locationState.status == LocationStatus.ready,
            myLocationButtonEnabled: false, // We use a custom button
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
              // Optional: set custom map style here if needed
            },
          ),
          
          // Simulated Map Pins
          // (These will eventually be real Markers in the GoogleMap widget)
          // For now, they are preserved as UI elements over the map.
          const Positioned(
            top: 200,
            left: 100,
            child: Icon(Icons.location_on, color: AppColors.riskHighDark, size: 40),
          ),
          const Positioned(
            top: 400,
            left: 250,
            child: Icon(Icons.location_on, color: AppColors.riskMediumDark, size: 40),
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
                    // Location State Overlay (if not ready/loading)
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
                    
                    // Zoom Controls (Custom)
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
                  color: Theme.of(context).bottomSheetTheme.backgroundColor,
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
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.warning, color: AppColors.riskHighDark),
                      title: const Text('Theft Reported'),
                      subtitle: const Text('500m away • Active'),
                      trailing: const RiskChip(level: RiskLevel.high),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline, color: AppColors.riskMediumDark),
                      title: const Text('Suspicious Activity'),
                      subtitle: const Text('1.2km away • 2 hrs ago'),
                      trailing: const RiskChip(level: RiskLevel.medium),
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
