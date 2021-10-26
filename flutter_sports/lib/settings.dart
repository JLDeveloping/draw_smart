import 'package:flutter/material.dart';

///Widget zur Anzeige der ESense Informationen und Eigenschaften
class Settings extends StatefulWidget {

  Settings({Key key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {

  String deviceName = "";
  String deviceStatus = "";
  double deviceVoltage = -1;

  ///Verändert die Gerätenamenanzeige
  void updateDeviceName(String text) {
    setState(() {
      deviceName = text;
    });
  }

  ///Verändert die Gerätestatusanzeige
  void updateDeviceStatus(String text) {
    setState(() {
      deviceStatus = text;
    });
  }

  ///Verändert die Spannungsanzeige
  void updateDeviceVoltage(double v) {
    setState(() {
      deviceVoltage = v;
    });
  }

  ///Erstellt das Widget
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          child: Text('eSense Device Status: \t$deviceStatus'),
        ),
        Container(
          child: Text('eSense Device Name: \t$deviceName'),
        ),
        Container(
          child: Text('eSense Battery Level: \t$deviceVoltage'),
        )
      ],
    );
  }
}



