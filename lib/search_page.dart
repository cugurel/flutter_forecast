import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? choosenCity;

  final myController = TextEditingController();

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Uyarı'),
            content: new Text('Şehir Seçimi Hatalı!'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text('Kapat'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage('assets/search.jpg'))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: myController,
                  //onChanged: (value){
                  // choosenCity = value;
                  //},
                  decoration: InputDecoration(hintText: 'Şehir Seçiniz'),
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              FlatButton(
                onPressed: () async {
                  var response = await http.get(
                      'https://www.metaweather.com/api/location/search/?query=${myController.text}');
                  jsonDecode(response.body).isEmpty
                      ? _showDialog()
                      : Navigator.pop(context, myController.text);

                },
                child: Text('Şehri Seç'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
