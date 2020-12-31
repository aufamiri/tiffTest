import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoimage/geoimage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proj4dart/proj4dart.dart';
import 'package:tiffTest/map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List data;

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

  void _raster() async {
    // Image _test = Image.asset("asset/icon.png");
    var file = await getImageFileFromAssets("asset/landsat.tif");
    var raster = GeoImage(file);
    raster.read();

    // Image test = decodeTiff(file);

    // print("test : ${raster.imageBytes}");
    // print("coba : ${raster.image}");
    // print("nyobak : ${raster.geoInfo}");
    data = raster.image;
// Env[-9551282.179409388 : -9505452.568807404 , 5571611.137992457 : 5601393.000950782 ]
  }

  void _convert() {
    Point point = Point(x: -9551282.179, y: 5601393.001);

    Projection projSrc = Projection('EPSG:3857');
    Projection projDst = Projection('EPSG:4326');

    var result = projSrc.transform(projDst, point);
    //THE Resulting Coordinate is Long,Lat !!
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("test"),
        ),
        body: Center(
          child: Column(
            children: [
              RaisedButton(
                onPressed: _convert,
                child: Text("PUSH HERE"),
              ),
              RaisedButton(
                onPressed: _raster,
                child: Text("HERE"),
              ),
              RaisedButton(
                child: Text("to map"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapView(data),
                    ),
                  );
                },
              )
            ],
          ),
        ));
  }
}
