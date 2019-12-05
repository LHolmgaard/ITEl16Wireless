import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Hustand'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    this.getData();
  }

  var isTooHot = [false, false];
  bool isTooCold = false;
  double count = 21;
  Map data;
  List temps;

  void incrementTemp() {
    setState(() {
      count = count + 0.5;
    });
  }

  void decreaseTemp() {
    setState(() {
      count = count - (0.5);
    });
  }

  Future<List> getData() async {
    http.Response response = await http.get(
        Uri.encodeFull(
            "https://api.thingspeak.com/channels/921101/feeds.json?api_key=Z8LDZO3GVSCMT5UL&results=2"),
        headers: {"Accept": "application/json"});
    data = json.decode(response.body);
    setState(() {
      temps = data["feeds"];
    });
    // print(double.parse(temps[1]['field1']))
    Timer(Duration(seconds: 3), () {
      for (int i = 0; i < temps.length; i++) {
        if (double.parse(temps[i]['field1']) > count + 3) {
          setState(() {
            isTooHot[i] = true;
          });
        } else if (double.parse(temps[1]['field1']) < count - 3) {
          setState(() {
            isTooCold = true;
          });
        } else {
          setState(() {
            isTooHot[i] = false;
            isTooCold = false;
          });
        }
      }
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue, Colors.red],
          ),
        ),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 400,
              child: ListView.builder(
                padding: EdgeInsets.all(15.0),
                itemCount: temps == null ? 0 : 2,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: isTooHot[index] ? Colors.red : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.fire,
                            size: 25.0,
                            color: isTooHot[index] ? Colors.black : Colors.red,
                          ),
                          Text(
                            index == 0 ? "Rum temp: " : "Afgangs temp: ",
                            style: TextStyle(
                                color: isTooHot[index]
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "${temps[1]['field' + (1 + index).toString()]}",
                            style: TextStyle(
                                color: isTooHot[index]
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              "Ønsket temperatur:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 20.0,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: decreaseTemp,
                  child: new Icon(
                    FontAwesomeIcons.minus,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.blue,
                  padding: const EdgeInsets.all(15.0),
                ),
                Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                RawMaterialButton(
                  onPressed: incrementTemp,
                  child: new Icon(
                    FontAwesomeIcons.plus,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.red,
                  padding: const EdgeInsets.all(15.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
