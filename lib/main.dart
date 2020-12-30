import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoimage/geoimage.dart';
import 'package:path_provider/path_provider.dart';

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
    var raster = GeoRaster(file);

    raster.read();
    print(raster.geoInfo.worldEnvelope);
// Env[-9551282.179409388 : -9505452.568807404 , 5571611.137992457 : 5601393.000950782 ]
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("test"),
        ),
        body: Center(
          child: RaisedButton(
            onPressed: _raster,
            child: Text("PUSH HERE"),
          ),
        ));
  }
}
