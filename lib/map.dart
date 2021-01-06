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
  List<String> log = List();

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
    setState(() {
      log.add("reading file from asset...");
    });
    print("HAI");
    print(byteData.buffer);
    Directory tempPath = await getTemporaryDirectory();
    final file = File('${tempPath.path}/map.tif');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    print(file);
    return file;
  }

  Future<Uint8List> _raster() async {
    // Image _test = Image.asset("asset/icon.png");
    var file = await getImageFileFromAssets("asset/map.tif");
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
    setState(() {
      log.add("loading image....");
    });
    final Uint8List list = await _raster();
    if (list.isNotEmpty) {
      setState(() {
        log.add("load image success");
      });
    }

    return _mapController.addImageSource(
      name,
      // widget.assets,
      list,
      LatLngQuad(
        topLeft: LatLng(-6.96240535, 107.63321113),
        topRight: LatLng(-6.96240535, 107.63762236),
        bottomRight: LatLng(-6.96678662, 107.63762236),
        bottomLeft: LatLng(-6.96678662, 107.63321113),
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
                  zoom: 8.0, target: LatLng(-6.96678662, 107.63321113)),
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
          Expanded(
            child: ListView.builder(
              itemCount: log.length,
              itemBuilder: (context, index) {
                return Text(
                  log[index],
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
