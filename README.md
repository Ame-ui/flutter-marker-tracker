# Marker Tracker

`marker_tracker` is a Flutter package that helps track the position of markers on a map even when they move outside the visible bounds. It calculates an offset that points to the direction of the marker relative to the map's visible area, making it useful for displaying directional indicators or guiding users to markers outside their current view.

## Features

- **Directional Offsets**: Provides the offset to indicate the direction of a marker when it is outside the visible bounds of the map.
- **Compatible with Popular Maps**: Works seamlessly with mapping libraries like:
  - [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
  - [flutter_map](https://pub.dev/packages/flutter_map)
- **Dynamic Tracking**: Handles map movements and zoom levels in real time.

![Demo](https://raw.githubusercontent.com/Ame-ui/flutter-marker-tracker/main/demo.gif)

<!-- https://github.com/Ame-ui/flutter-marker-tracker -->

## Installation

Add `marker_tracker` to your `pubspec.yaml` file:

```yaml
dependencies:
  marker_tracker: latest_version
```

## Usage

```dart
import 'package:marker_tracker/marker_tracker.dart';
```

## Example

Inside the onMapEvent of the FlutterMap

```dart
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
        print(xShow.value);
        if (xShow.value) xShow.value = false;
    } else {
        if (!xShow.value) xShow.value = true;
        trackerPosition.value = offset;
    }
    },
);
```

Inside the stack, on top of the map

```dart
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
```

## Parameters

-centerLat: Latitude of the center of the map
-centerLng: Longitude of the center of the map
-trackLat: Latitude of the marker to track
-trackLng: Longitude of the marker to track
-mapWidth: Width of the map widget
-mapHeight: Height of the map widget
-trackerSize: Size of the tracker
-onGetOffset: this function provide the offset throught the Function(Offset offset)
-isCheckOutOfBound: Whether to track the marker, [true]-only calculate the offset if the marker is outside of the visible bound, [false]- track the marker all the time even if the marke is inside the visible bound

Parameter bellow are required if the isCheckOutOfBound is true
-southWestLat: Latitude of the south-west corner of the visible bound
-southWestLng: Longitude of the south-west corner of the visible bound
-northEastLat: Latitude of the north-east corner of the visible bound
-northEastLng: Longitude of the north-east corner of the visible bound

## Contribution

Contributions are welcome! If you have any issues or feature requests, please create an issue on the ![GitHub repository](https://github.com/Ame-ui/flutter-marker-tracker).
