import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simulated Map Background
          Container(
            color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF070B16) 
              : const Color(0xFFE2E8F0),
            child: const Center(
              child: Icon(Icons.map, size: 200, color: Colors.black12),
            ),
          ),
          
          // Simulated Map Pins
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

          // Map Controls
          SafeArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      child: IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                          const Divider(height: 1),
                          IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
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
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
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
