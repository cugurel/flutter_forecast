import 'package:flutter/material.dart';
import 'package:weather_forecast/search_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String city = 'Ankara';
  int temperature = 20;

  var locationData;

  void getLocationData() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?query=Ankara');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage('assets/c.jpg'))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {

                  print('Http get çalıimadan önce location data: $locationData');
                  getLocationData();
                  Future.delayed(Duration(seconds: 5), () {
                    print('Get çalıştıktan sonra çalışan data:$locationData');
                  });

                },
                child: Text('Get Location Data'),
                color: Colors.grey,
              ),
              Text(
                '$temperature° C',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 70),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Ankara',
                    style: TextStyle(fontSize: 30),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage()));
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
