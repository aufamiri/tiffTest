import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoimage/geoimage.dart';
import 'package:image/image.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tiffTest/locate.dart';
import 'secret.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapboxMapController _mapController;
  String _mapStyles = MapboxStyles.DARK;

  void _onMapCreated(MapboxMapController controller) async {
    _mapController = controller;

    // final location = await getCurrentLocation();
    // await _mapController.animateCamera(CameraUpdate.newLatLng(location));

    // await _mapController.addLine(
    //   LineOptions(
    //     geometry: [
    //       LatLng(location.latitude - 0.004, location.longitude + 0.005),
    //       LatLng(location.latitude + 0.001, location.longitude),
    //       LatLng(location.latitude + 0.001, location.longitude - 0.003),
    //       LatLng(location.latitude + 0.002, location.longitude - 0.004),
    //     ],
    //     lineColor: "#FF2B2B",
    //     lineWidth: 1.0,
    //   ),
    // );
  }

  Future<File> getImageFileFromAssets(String path) async {
    print("STAT");
    final byteData = await rootBundle.load(path);
    print("HAI");
    print(byteData.buffer);
    Directory tempPath = await getTemporaryDirectory();
    final file = File('${tempPath.path}/test.tif');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    print(file);
    return file;
  }

  Future<Uint8List> _raster() async {
    // Image _test = Image.asset("asset/icon.png");
    var file = await getImageFileFromAssets("asset/landsat.tif");
    var raster = GeoImage(file);
    raster.read();

    // print("test : ${raster.imageBytes}");
    // print("coba : ${raster.image}");
    // print("nyobak : ${raster.geoInfo}");
    // data = raster.image;
    return encodePng(raster.image);
// Env[-9551282.179409388 : -9505452.568807404 , 5571611.137992457 : 5601393.000950782 ]
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    // final ByteData bytes = await rootBundle.load(assetName);
    // final Uint8List list = bytes.buffer.asUint8List();
    final Uint8List list = await _raster();
    return _mapController.addImageSource(
      name,
      // widget.assets,
      list,
      LatLngQuad(
        topLeft: LatLng(44.87016, -85.79928),
        topRight: LatLng(44.87016, -85.39184),
        bottomRight: LatLng(44.68254, -85.39184),
        bottomLeft: LatLng(44.68254, -85.79928),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Demo | Long Click for Marker"),
        actions: [
          DropdownButton(
            value: _mapStyles,
            items: [
              DropdownMenuItem(
                child: Text("Dark"),
                value: MapboxStyles.DARK,
              ),
              DropdownMenuItem(
                child: Text("Light"),
                value: MapboxStyles.LIGHT,
              ),
              DropdownMenuItem(
                child: Text("Satellite"),
                value: MapboxStyles.SATELLITE_STREETS,
              )
            ],
            onChanged: (value) {
              setState(() {
                _mapStyles = value;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: MapboxMap(
              accessToken: token,
              styleString: _mapStyles,
              initialCameraPosition: CameraPosition(
                  zoom: 10.0, target: LatLng(44.87016, -85.39184)),
              onMapCreated: _onMapCreated,
            ),
          ),
          RaisedButton(
            onPressed: () {
              addImageFromAsset("test", "asset/icon.png");
            },
            child: Text("1. add  img"),
          ),
          RaisedButton(
            onPressed: () {
              _mapController.addLayer("coba", "test");
            },
            child: Text("2. place img"),
          ),
        ],
      ),
    );
  }
}
