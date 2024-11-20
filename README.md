# Marker Tracker

`marker_tracker` is a Flutter package designed to calculate and provide the offset for the tracker based on a specific `Location`. It helps developers easily manage and track marker positions on the screen, especially when using interactive maps.

## Features

- Get precise screen offsets for any `LatLng` point.
- Compatible with popular Flutter map libraries like:
  - [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
  - [flutter_map](https://pub.dev/packages/flutter_map)
- Simplifies marker animations and real-time tracking.
- Accurate calculations, even during zoom or map movements.

![Demo](https://raw.githubusercontent.com/Ame-ui/rotary-number-picker/main/picker_demo.gif)

<!-- (https://raw.githubusercontent.com/Ame-ui/rotary-number-picker/main/picker_demo.gif) -->

## Installation

Add `rotary_number_picker` to your `pubspec.yaml` file:

```yaml
dependencies:
  rotary_number_picker: latest_version
```

## Usage

```yaml
import 'package:rotary_number_picker/rotary_number_picker.dart';
```

## Example

```dart
import 'package:rotary_number_picker/rotary_number_picker.dart';

RotaryNumberPicker(
    circleDiameter: MediaQuery.of(context).size.width,
    numberCircleColor: Colors.grey.withOpacity(0.2),
    selectedNumberCircleColor: Colors.orange,
    numberTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
    selectedNumberTextStyle: const TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    wheelBgColor: Colors.white,
    wheelInnerCircleColor: Colors.grey.withOpacity(0.2),
    dropAreaBorderColor: Colors.orange,
    dropAreaColor: Colors.orange.withOpacity(0.2),
    onGetNumber: (number) {
        print('Selected number: $number');
    },
),
```

## Parameters

- circleDiameter: Diameter of the picker wheel (required).
- numberCircleColor: Color of the circles of each number.
- selectedNumberCircleColor: Color of the circle of the selected number.
- numberTextStyle: Text style of the normal numbers text.
- selectedNumberTextStyle: Text style of the selected number text.
- wheelBgColor: Background color of the wheel.
- wheelInnerCircleColor: Inner circle color of the wheel.
- dropAreaBorderColor: Border color of the drop area.
- dropAreaColor: Color of the drop area (prefer color with opacity).
- onGetNumber: Callback function that returns the selected number (required)..

## Contribution

Contributions are welcome! If you have any issues or feature requests, please create an issue on the ![GitHub repository](https://github.com/Ame-ui/rotary-number-picker).
