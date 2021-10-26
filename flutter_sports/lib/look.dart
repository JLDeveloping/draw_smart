import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

///Zeigt den Blickpunkt an
class Look extends StatefulWidget {

  ///Das Widget, über dem der Blickpunkt gezeichnet werden soll
  final Widget child;

  ///Durchmesser der Anzeige
  final double size;

  ///Farbe der Anzeige
  final Color color = Colors.deepOrange;

  ///Übergebene Höhe der AppBar, um den Zeichenbereich zu beschränken
  final double appBarHeight;

  Look({
    Key key,
    @required this.child,
    this.size = 40,
    this.appBarHeight,
  }) : super(key: key);

  @override
  LookState createState() => LookState();
}

class LookState extends State<Look> {

  ///Aktueller Blickpunkt
  Offset position;

  ///Derstellt das Widget zur Anzeige
  Iterable<Widget> buildLookIndicators() sync* {
    if (position != null) {
        //yield fügt etwas dem Outputstream hinzu
        yield Positioned.directional(
          start: position.dx - widget.size / 2,
          top: position.dy - widget.size / 2,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.3),
            ),
            child: Icon(
              Icons.visibility_rounded,
              size: widget.size,
              color: widget.color.withOpacity(0.9),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
      }
    }

  ///Verändert die aktuelle Position
  ///Wird vom Parent aufgerufen
  void newPosition(int index, Offset position) {
    Offset offset = new Offset(position.dx, position.dy - widget.appBarHeight);
    setState(() {
      this.position = offset;
    });
  }

  ///Erstellt den Stack aus child und der Blickanzeige
  @override
  Widget build(BuildContext context) {
    var children = [
      widget.child,
    ]..addAll(buildLookIndicators());
    return Stack(children: children);
  }
}
