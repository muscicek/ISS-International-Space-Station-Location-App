import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

ValueNotifier<int> a = ValueNotifier<int>(0);
double? _latitude;
double? _longitude;
GoogleMapController? _controller;
BitmapDescriptor _icon = BitmapDescriptor.defaultMarker;
MapType _mapType = MapType.satellite;
Color _color = Color(0xff121147);
Future fetchData() async {
  final response =
      await http.get(Uri.parse("http://api.open-notify.org/iss-now.json"));
  if (response.statusCode != null) {
    print("success");
  } else {
    print("failed");
  }
  final responseJson = jsonDecode(response.body);
  _latitude = double.parse(responseJson["iss_position"]["latitude"]);
  _longitude = double.parse(responseJson["iss_position"]["longitude"]);
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/images/iss.png",
    ).then((value) {
      _icon = value;
    });
    Timer.periodic(Duration(milliseconds: 1000), (Timer t) {
      setState(() {
        fetchData();
        a.value++;
        if (a.value == 100) {
          a.value = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (_mapType == MapType.satellite) {
                    _mapType = MapType.normal;
                    _color = Color(0xff0EC65F);
                  } else {
                    _mapType = MapType.satellite;
                    _color = Color(0xff121147);
                  }
                });
              },
              icon: Icon(Icons.change_circle_outlined))
        ],
        leading: IconButton(
          onPressed: () {
            fetchData();
            _controller
                ?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
              zoom: 7,
              target: LatLng(_latitude!, _longitude!),
            )));
          },
          icon: Icon(Icons.gps_fixed),
        ),
        backgroundColor: _color,
        centerTitle: true,
        title: Text("ISS Location"),
      ),
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: a,
          builder: (BuildContext context, value, Widget? child) {
            if (_latitude != null && _longitude != null) {
              return GoogleMap(
                myLocationEnabled: true,
                mapType: _mapType,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_latitude!, _longitude!),
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
                markers: {
                  Marker(
                    markerId: MarkerId("ISS"),
                    position: LatLng(_latitude!, _longitude!),
                    icon: _icon,
                  ),
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
