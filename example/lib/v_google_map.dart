import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:marker_tracker/marker_tracker.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  ValueNotifier<bool> xShow = ValueNotifier(false);
  GoogleMapController? googleMapController;
  ValueNotifier<Offset> trackerPosition = ValueNotifier(Offset.zero);

  final double trackerSize = 50;
  @override
  void dispose() {
    googleMapController?.dispose();
    xShow.dispose();
    trackerPosition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapWidth = MediaQuery.of(context).size.width;
    final mapHeight = MediaQuery.of(context).size.height * 0.7;
    LatLngBounds _getLatLngBounds(CameraPosition position) {
      double lat = position.target.latitude;
      double lng = position.target.longitude;
      double zoom = position.zoom;

      // Calculate a dynamic buffer size based on the zoom level
      double latBuffer =
          0.01 * (21 - zoom); // The larger the zoom, the smaller the buffer
      double lngBuffer = 0.01 * (21 - zoom); // Same for longitude buffer

      // Adjust the buffer to avoid too small values
      latBuffer = latBuffer > 0.0001 ? latBuffer : 0.0001;
      lngBuffer = lngBuffer > 0.0001 ? lngBuffer : 0.0001;

      // Define bounds with a dynamic buffer around the center point
      LatLng southwest = LatLng(lat - latBuffer, lng - lngBuffer);
      LatLng northeast = LatLng(lat + latBuffer, lng + lngBuffer);

      return LatLngBounds(southwest: southwest, northeast: northeast);
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Google Map',
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
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                        target: LatLng(16.819376, 96.178474), zoom: 15),
                    onMapCreated: (controller) {
                      googleMapController = controller;
                    },
                    onCameraMove: (position) async {
                      final bound =
                          await googleMapController!.getVisibleRegion();

                      MarkerTracker.calculateOffset(
                        centerLat: position.target.latitude,
                        centerLng: position.target.longitude,
                        trackLat: 16.819376,
                        trackLng: 96.178474,
                        mapWidth: mapWidth,
                        mapHeight: mapHeight,
                        trackerSize: trackerSize,
                        isCheckOutOfBound: true,
                        southWestLat: bound.southwest.latitude,
                        southWestLng: bound.southwest.longitude,
                        northEastLat: bound.northeast.latitude,
                        northEastLng: bound.northeast.longitude,
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
                    markers: {
                      const Marker(
                          markerId: MarkerId('16.819376, 96.178474'),
                          position: LatLng(16.819376, 96.178474),
                          icon: BitmapDescriptor.defaultMarker)
                    },
                  )),
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
