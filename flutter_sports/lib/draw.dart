import 'dart:ui';
import 'package:flutter/material.dart';

///Widget zum zeichnen
class Draw extends StatefulWidget {

  Draw({Key key}) : super (key: key);

  @override
  DrawState createState() => DrawState();
}

class DrawState extends State<Draw> {

  ///Aktuelle Farbe
  Color selectedColor = Colors.black;

  ///Pinselart
  StrokeCap strokeCap = StrokeCap.butt;

  ///Deckkraft
  double opacity = 1.0;

  ///Breite der Linie
  double strokeWidth = 3.0;

  ///Liste der Punkte
  List<DrawingPoint> points = List();

  ///Leert die Liste der Punkte, um die Zeichenfläche zu säubern
  void clean() {
    setState(() {
      points.clear();
    });
  }

  ///Wenn ein neuer Punkt gezeichnet werden soll
  ///Erstellt mit den aktuellen Daten einen Punkt und fügt ihn hinzu
  void startDrawing(Offset position) {
    var paint = Paint()
      ..strokeCap = strokeCap
      ..isAntiAlias = true
      ..color = selectedColor.withOpacity(opacity)
      ..strokeWidth = strokeWidth;
    setState(() {
      points.add(new DrawingPoint(
          position,
          paint,
      ));
    });
  }

  ///Verändert die Linienstärke
  void changeStrokeWidth(double value) {
    setState(() {
      strokeWidth = value;
    });
  }

  ///Signalisiert, dass abgesetzt wurde
  void stopDrawing() {
    setState(() {
      points.add(null);
    });
  }

  ///Erstellt die Zeichenfläche
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        size: Size.infinite,
        painter: DrawingPainter(
          pointsList: points,
        ),
      ),
    );
  }
}

///Zeichenpunkt, speichert Position und Zeichenart
class DrawingPoint {
  Offset point;
  Paint paint;

  DrawingPoint(Offset point, Paint paint) {
    this.point = point;
    this.paint = paint;
  }
}

///Klasse zum Zeichnen der Punkte
class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});    //Zeichnet die Punkte
  List<DrawingPoint> pointsList;        //Liste der Punkte
  List<Offset> offsetPoints = List();   //Liste mit Koordinaten

  ///Zeichnenmethode
  @override
  void paint(Canvas canvas, Size size) {
    ///Durchgehen der Punkte
    for (int i = 0; i < pointsList.length - 1; i++) {
      ///Falls dieser und der nächste Punkt nicht null sind
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        ///Zeichnet eine Linie zwischend en beiden Punkten
        canvas.drawLine(pointsList[i].point, pointsList[i +1].point ,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        ///Falls der Endpunkt erreicht ist
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].point);
        offsetPoints.add(Offset(
            pointsList[i].point.dx + 0.1, pointsList[i].point.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }
  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => oldDelegate.pointsList!=pointsList;
}