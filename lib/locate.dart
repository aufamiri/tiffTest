import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

Future<LatLng> getCurrentLocation() async {
  Location location = Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }

  PermissionStatus permissionStatus = await location.hasPermission();
  if (permissionStatus != PermissionStatus.granted) {
    permissionStatus = await location.requestPermission();

    if (permissionStatus != PermissionStatus.granted) {
      return null;
    }
  }

  final locationData = await location.getLocation();
  return LatLng(locationData.latitude, locationData.longitude);
}
