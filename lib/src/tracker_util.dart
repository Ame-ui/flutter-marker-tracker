import 'dart:math';
import 'dart:ui';

class MarkerTracker {
  /// calculate the bearing between center and marker to calculate angle
  static double _calculateBearing(
      double startLat, double startLng, double endLat, double endLng) {
    // Convert latitude and longitude from degrees to radians
    final lat1 = _degreeToRadian(startLat);
    final lng1 = _degreeToRadian(startLng);
    final lat2 = _degreeToRadian(endLat);
    final lng2 = _degreeToRadian(endLng);

    // Calculate the difference in longitude
    final dLng = lng2 - lng1;

    // Calculate the bearing
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearingRad = atan2(y, x);

    // Convert the bearing from radians to degrees
    // to keep degree between 0-360 ([degree] + 360 and % 360 )
    final bearingDeg = (_radianToDegree(bearingRad) + 360) % 360;

    return bearingDeg;
  }

  /// calculate the percentage of the current degree between two degree
  static double _calculatePercentWithDegree(
      {required double degree, required double min, required double max}) {
    return (degree - min) / (max - min);
  }

  static double _degreeToRadian(double degree) => degree * pi / 180;

  static double _radianToDegree(double radian) => radian * 180 / pi;

  static bool _isWithinBounds(
      double trackLat,
      double trackLng,
      double southwestLat,
      double southwestLng,
      double northeastLat,
      double northeastLng) {
    final isLatWithin = trackLat >= southwestLat && trackLat <= northeastLat;

    bool isLngWithin;
    if (southwestLng <= northeastLng) {
      // Normal case: No wrapping around the International Date Line
      isLngWithin = trackLng >= southwestLng && trackLng <= northeastLng;
    } else {
      // Wrapping case: Crossing the International Date Line
      isLngWithin = trackLng >= southwestLng || trackLng <= northeastLng;
    }

    // Return true if both latitude and longitude are within bounds
    return isLatWithin && isLngWithin;
  }

  /// calculate the offset of the specific marker through [onGetOffset]
  ///
  /// if [onGetOffset] give null value it mean the marker is inside the visible bound of the map
  ///
  /// if [isCheckOutOfBound] is true, then you have to pass the southwestLatlng and northeastLatlng
  static void calculateOffset(
      {required double centerLat,
      required double centerLng,
      required double trackLat,
      required double trackLng,
      required double mapWidth,
      required double mapHeight,
      required double trackerSize,
      required bool isCheckOutOfBound,
      double? southWestLat,
      double? southWestLng,
      double? northEastLat,
      double? northEastLng,
      double padding = 5,
      required Function(Offset? offset) onGetOffset}) {
    assert(mapWidth > 0);
    assert(mapHeight > 0);
    assert(trackerSize > 0);
    assert(trackerSize < mapWidth);
    assert(trackerSize < mapHeight);

    if (isCheckOutOfBound) {
      assert(southWestLat != null);
      assert(southWestLng != null);
      assert(northEastLat != null);
      assert(northEastLng != null);
    }
    bool shouldCalculate = true;
    if (isCheckOutOfBound) {
      shouldCalculate = false;
      shouldCalculate = !_isWithinBounds(trackLat, trackLng, southWestLat!,
          southWestLng!, northEastLat!, northEastLng!);
      if (!shouldCalculate) {
        onGetOffset(null);
      }
    }
    if (shouldCalculate) {
      final bearing =
          _calculateBearing(centerLat, centerLng, trackLat, trackLng);

      /// to find the degree of each edge of the rectangle(mapWidth,mapHeight)
      final opposite = mapHeight;
      final adjacent = mapWidth;
      final oneAngle = _radianToDegree(atan(opposite / adjacent));
      final horizontalAngle = 2 * (90 - oneAngle);
      final verticalAngle = 180 - (horizontalAngle);

      final tr = horizontalAngle / 2;
      final br = tr + verticalAngle;
      final bl = br + horizontalAngle;
      final tl = bl + verticalAngle;
      final double totalTrackerSize = trackerSize + padding * 2;

      if (bearing >= tr && bearing < br) {
        final percentage =
            _calculatePercentWithDegree(degree: bearing, min: tr, max: br);
        onGetOffset(Offset(
          mapWidth - totalTrackerSize / 2,
          totalTrackerSize / 2 + percentage * (mapHeight - totalTrackerSize),
        ));
      } else if (bearing >= br && bearing < bl) {
        final percentage =
            1 - _calculatePercentWithDegree(degree: bearing, min: br, max: bl);
        onGetOffset(Offset(
          totalTrackerSize / 2 + percentage * (mapWidth - totalTrackerSize),
          mapHeight - totalTrackerSize / 2,
        ));
      } else if (bearing >= bl && bearing < tl) {
        final percentage =
            1 - _calculatePercentWithDegree(degree: bearing, min: bl, max: tl);
        onGetOffset(Offset(
          totalTrackerSize / 2,
          totalTrackerSize / 2 + percentage * (mapHeight - totalTrackerSize),
        ));
      } else {
        if ((bearing >= tl && bearing <= 360)) {
          final percentage =
              _calculatePercentWithDegree(degree: bearing, min: tl, max: 360) /
                  2;

          onGetOffset(Offset(
            totalTrackerSize / 2 + percentage * (mapWidth - totalTrackerSize),
            totalTrackerSize / 2,
          ));
        } else if ((bearing >= 0 && bearing < tr)) {
          final percentage = 0.5 +
              _calculatePercentWithDegree(degree: bearing, min: 0, max: tr) / 2;

          onGetOffset(Offset(
            totalTrackerSize / 2 + percentage * (mapWidth - totalTrackerSize),
            totalTrackerSize / 2,
          ));
        }
      }
    }
  }
}
