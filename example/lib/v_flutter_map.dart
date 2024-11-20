import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:marker_tracker/marker_tracker.dart';

class FlutterMapPage extends StatefulWidget {
  const FlutterMapPage({super.key});

  @override
  State<FlutterMapPage> createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
  MapController mapController = MapController();
  ValueNotifier<bool> xShow = ValueNotifier(false);
  ValueNotifier<Offset> trackerPosition = ValueNotifier(Offset.zero);

  final double trackerSize = 50;
  @override
  void dispose() {
    mapController.dispose();
    xShow.dispose();
    trackerPosition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapWidth = MediaQuery.of(context).size.width;
    final mapHeight = MediaQuery.of(context).size.height * 0.7;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Flutter Map',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Stack(
            children: [
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
                width: mapWidth,
                height: mapHeight,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(16.819376, 96.178474),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapEvent: (mapEvent) {
                      final bound = mapController.camera.visibleBounds;
                      MarkerTracker.calculateOffset(
                        centerLat: mapController.camera.center.latitude,
                        centerLng: mapController.camera.center.longitude,
                        trackLat: 16.819376,
                        trackLng: 96.178474,
                        mapWidth: mapWidth,
                        mapHeight: mapHeight,
                        trackerSize: trackerSize,
                        isCheckOutOfBound: true,
                        southWestLat: bound.southWest.latitude,
                        southWestLng: bound.southWest.longitude,
                        northEastLat: bound.northEast.latitude,
                        northEastLng: bound.northEast.longitude,
                        onGetOffset: (offset) {
                          if (offset == null) {
                            if (xShow.value) xShow.value = false;
                          } else {
                            if (!xShow.value) xShow.value = true;
                            trackerPosition.value = offset;
                          }
                        },
                      );
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          point: const LatLng(16.819376, 96.178474),
                          child: Image.asset('assets/pin.png'))
                    ])
                  ],
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: xShow,
                builder: (BuildContext context, bool value, Widget? child) {
                  return ValueListenableBuilder<Offset>(
                    valueListenable: trackerPosition,
                    builder: (context, position, child) {
                      return Positioned(
                        left: position.dx - trackerSize / 2,
                        top: position.dy - trackerSize / 2,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                          child: !value
                              ? const SizedBox.shrink()
                              : Container(
                                  width: trackerSize,
                                  height: trackerSize,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
