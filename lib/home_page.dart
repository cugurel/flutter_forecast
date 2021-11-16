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

  var temps = List.filled(5, 0);
  var images = ['c', 'c', 'c', 'c', 'c'];
  var dates = ['c', 'c', 'c', 'c', 'c'];

  Future<void> getDeviceLocation() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (error) {
      print('Şu hata oluştu: $error');
    }
  }

  Future<void> getLocationDataLattLong() async {
    locationData = await http.get(
        'https://www.metaweather.com/api/location/search/?lattlong=${position!.latitude},${position!.longitude}');
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

      for (int i = 0; i < temps.length; i++) {
        temps[i] =
            tempDataParsed['consolidated_weather'][i + 1]['the_temp'].round();
      }

      for (int i = 0; i < temps.length; i++) {
        images[i] = tempDataParsed['consolidated_weather'][i + 1]
                ['weather_state_abbr']
            .toString();
      }

      for (int i = 0; i < temps.length; i++) {
        dates[i] = tempDataParsed['consolidated_weather'][i + 1]
                ['applicable_date']
            .toString();
      }
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
    await getLocationData(); // Get woeid from API information by using lat and long
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
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          'https://www.metaweather.com/static/img/weather/png/$abbr.png'),
                    ),
                    Text(
                      '$temperature° C',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 70,
                        shadows: <Shadow>[
                          Shadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              offset: Offset(-3, 3)),
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
                    SizedBox(
                      height: 50,
                    ),
                    DailyWeatherCards(context),
                  ],
                ),
              ),
            ),
    );
  }

  Container DailyWeatherCards(BuildContext context) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          DailyWeather(
            date: dates[0],
            temp: temps[0],
            image: images[0],
          ),
          DailyWeather(
            date: dates[1],
            temp: temps[1],
            image: images[1],
          ),
          DailyWeather(
            date: dates[2],
            temp: temps[2],
            image: images[2],
          ),
          DailyWeather(
            date: dates[3],
            temp: temps[3],
            image: images[3],
          ),
          DailyWeather(
            date: dates[4],
            temp: temps[4],
            image: images[4],
          ),
        ],
      ),
    );
  }
}

class DailyWeather extends StatelessWidget {
  final String image;
  final int temp;
  final String date;

  const DailyWeather(
      {Key? key, required this.image, required this.temp, required this.date})
      : super(key: key);
  @override
  Widget build(BuildContext context) {

    List<String> weekDays=['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'];

    String WeekDay = weekDays[DateTime.parse(date).weekday-1];
    return Card(
      elevation: 2,
      color: Colors.transparent,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://www.metaweather.com/static/img/weather/png/$image.png',
              height: 50,
              width: 50,
            ),
            Text('$temp° C'),
            Text('$WeekDay'),
          ],
        ),
      ),
    );
  }
}
