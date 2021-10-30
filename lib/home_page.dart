import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_forecast/search_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String city = 'Ankara';
  int? temperature;
  var woeid;
  var locationData;
  String abbr = 'c';
  Position? position;

  Future<void> getDeviceLocation() async{
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }

  Future<void> getLocationDataLattLong() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?lattlong=${position!.latitude},${position!.longitude}');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
    city = locationDataParsed[0]['title'];
  }


  Future<void> getLocationTemperature() async {
    var response =
        await http.get('https://www.metaweather.com/api/location/$woeid/');
    var tempDataParsed = jsonDecode(response.body);

    setState(() {
      temperature =
          tempDataParsed['consolidated_weather'][0]['the_temp'].round();
      abbr = tempDataParsed['consolidated_weather'][0]['weather_state_abbr'];
    });
  }

  Future<void> getLocationData() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?query=$city');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
  }

  void getDataFromApi() async {
    await getDeviceLocation(); //Take location information from device
    await getLocationDataLattLong(); // Get woeid from API information by using lat and long
    getLocationTemperature(); //Get temperature by using woeid
  }

  void getDataFromApiByCity() async {
    await getLocationData();// Get woeid from API information by using lat and long
    getLocationTemperature(); //Get temperature by using woeid
  }

  @override
  void initState() {
    getDataFromApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage('assets/$abbr.jpg'))),
      child: temperature == null
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$temperature° C',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 70,
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            offset: Offset(-3,3)
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '$city',
                          style: TextStyle(fontSize: 30),
                        ),
                        IconButton(
                            onPressed: () async {
                              city = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage()));

                              getDataFromApiByCity();
                              setState(() {
                                city = city;
                              });
                            },
                            icon: Icon(Icons.search))
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
