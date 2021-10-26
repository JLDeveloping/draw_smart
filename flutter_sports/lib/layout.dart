import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sports/draw.dart';
import 'package:flutter_sports/settings.dart';
import 'package:esense_flutter/esense.dart';
import 'package:flutter_sports/look.dart';

class Layout extends StatefulWidget {
  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with SingleTickerProviderStateMixin{

  ///Gibt die aktuelle Seite an
  int _selectedIndex = 0;

  ///Dienen dem Aufruf von Funktionen innerhalt der States der Widgets
  GlobalKey<SettingsState> _keySettings = GlobalKey();
  GlobalKey<LookState> _keyLook = GlobalKey();
  GlobalKey<DrawState> _keyDraw = GlobalKey();
  var bottomKey = GlobalKey();

  ///Die Appbar
  AppBar appBar;

  ///Variablen für ESense-Verbindung
  String deviceName = 'Unknown';
  double voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _button = 'not pressed';
  StreamSubscription subscription;
  bool connection = false;
  bool initConnection = false;

  ///Name der ESense Kopfhörer
  String eSenseName = 'eSense-0569';

  ///Fensterbreite und -höhe
  double width;
  double height;

  ///Koordinaten des Punktes, an den zuletzt geschaut wurde
  double lastX;
  double lastY;

  ///Breite der Linie die gezeichnet wird
  double linienbreite = 3;

  /// Wird bei der Initialisierung des Zustandes aufgerufen
  @override
  void initState() {
    super.initState();
    initESense();
  }

  ///Erstellt das Widget, dient als Grundgerüst
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    appBar = AppBar(
      title: Text("Flutter zeichnet"),
    );
    return Scaffold(
      appBar: appBar,
      body: IndexedStack(
        children: <Widget>[
          Look(
            child: Draw(
              key: _keyDraw,
            ),
            appBarHeight: appBar.preferredSize.height,
            key: _keyLook,
          ),
          Settings(
            key: _keySettings,
          ),
        ],
        index: _selectedIndex,
      ),
      bottomNavigationBar: Padding(
        key: bottomKey,
        padding: EdgeInsets.all(8),
        child: Container(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0, 1),
                blurRadius: 6,
              )
            ]
          ),
          child: Padding (
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Slider(
                    value: linienbreite,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: linienbreite.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        linienbreite = value;
                        _keyDraw.currentState.changeStrokeWidth(value);
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 0;
                              _keyDraw.currentState.clean();
                            });
                          },
                        ),
                        Text("Löschen"),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                        ),
                        Text("Zeichnen"),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                        ),
                        Text("Einstellungen"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          if (ESenseManager.connected != null) {
            if (!sampling) {
              _startListenToSensorEvents();
            } else {
              _pauseListenToSensorEvents();
            }
          }
        },
        tooltip: 'Anfangen zu zeichnen',
        child: (!sampling) ? Icon(Icons.play_arrow) : Icon(Icons.pause),
      ),
    );
  }

  ///Initialisiert die Verbindung zu den ESense
  initESense() async {
    connection = false;

    //Setzt den Listener auf Verbindungsevents
    ESenseManager.connectionEvents.listen((event) {
      if (event.type == ConnectionType.connected) _listenToESenseEvents();
      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'Verbunden';
            initConnection = true;
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'Unbekannt';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'Getrennt';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'Gerät gefunden';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'Gerät nicht gefunden';
            break;
        }
        _keySettings.currentState.updateDeviceName(deviceName);
        if (connection && _deviceStatus != "Verbunden" && initConnection) {
          connection = false;
          connect();
        }
      });
    });
    connection = await ESenseManager.connect(eSenseName);
    setState(() {
      _deviceStatus = connection ? 'Verbunden' : 'Verbindung fehlgeschlagen';
      if (!connection) {
        connect();
      }
      _keySettings.currentState.updateDeviceStatus(_deviceStatus);
    });
  }

  void connect() async {
    while (!connection) {
      connection = await ESenseManager.connect(eSenseName);
    }
  }

  ///Listener für ESenseEvents (Geräteevents)
  void _listenToESenseEvents() async {
    ESenseManager.eSenseEvents.listen((event) {
      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            deviceName = (event as DeviceNameRead).deviceName;
            _keySettings.currentState.updateDeviceName(deviceName);
            break;
          case BatteryRead:
            voltage = (event as BatteryRead).voltage;
            _keySettings.currentState.updateDeviceVoltage(voltage);
            break;
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed ? 'gedrückt' :
            'nicht gedrückt';
            break;
        }
      });
    });
    _getESenseProperties();
  }

  ///Wenn der Knopf gedrückt wurde
  void buttonPressed(ButtonEventChanged event) {
    if (ESenseManager.connected != null) {
      if (!sampling) {
        _startListenToSensorEvents();
      } else {
        _pauseListenToSensorEvents();
      }
    }
  }

  ///Listener für Sensorevents
  void _startListenToSensorEvents() async {
    subscription = ESenseManager.sensorEvents.listen((event) {
      updatePosition(event);
    });
    setState(() {
      sampling = true;
    });
  }

  ///Pausieren des SensorEvent Listeners
  void _pauseListenToSensorEvents() async {
    subscription.cancel();
    setState(() {
      sampling = false;
    });
  }

  ///Beenden der Verbindung
  void dispose() {
    _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    super.dispose();
  }

  ///Eigenschaften der ESense erfragen
  void _getESenseProperties() async {
    Timer.periodic(Duration(seconds: 5), (timer) async =>
    await ESenseManager.getBatteryVoltage());

    Timer(Duration(seconds: 2), () async =>
    await ESenseManager.getDeviceName());

    Timer(Duration(seconds: 3), () async =>
    await ESenseManager.getAccelerometerOffset());

    Timer(Duration(seconds: 4), () async => await
    ESenseManager.getAdvertisementAndConnectionInterval());

    Timer(Duration(seconds: 5), () async => await
    ESenseManager.getSensorConfig());
  }

  ///Richtet den Blickpunkt aus
  void updatePosition(SensorEvent event) {
    //Setzt die Anfangsposition auf die Mitte des Bildschirms
    if (lastX == null) {
      lastX = width/2;
      lastY = height/2;
    }
    //var x = convertToDeg(event.gyro[0]) + 0.20;
    //var y = convertToDeg(event.gyro[2]) + 0.54;
    var x = convertToDeg(event.gyro[0]);
    var y = convertToDeg(event.gyro[2]);

    //Vernachlässigung kleinerer Schwankungen, um Messfehler zu korrigieren
    if (x >= -0.75 && x <= 0.75) {
      x = 0.0;
    } else {
      x = 8 * x;
    }
    if (y >= -0.75 && y <= 0.75) {
      y = 0.0;
    } else {
      y = 7 * y;
    }

    //Blickpunkt im Zeichenbereich halten
    if (lastX + x <= 0 || lastX + x >= width.toDouble()) {
      x = 0;
    }
    if (lastY + y <= 50 || lastY + y >= (height -
        bottomKey.currentContext.size.height)) {
      y = 0;
    }
    //Position für Blickpunkt
    Offset position = new Offset(lastX + x, lastY + y);
    _keyLook.currentState.newPosition(0, position);
    //Position für Zeichenpunkt
    position = new Offset(lastX + x, lastY + y - appBar.preferredSize.height);
    _keyDraw.currentState.startDrawing(position);
    //Speichern der aktuellen Position
    lastX += x;
    lastY += y;
  }

  ///Wandelt die Gyroskopdaten in deg/s um
  double convertToDeg(int value) {
    return (value/500);
  }
}
