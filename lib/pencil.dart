
library pencil;

import "dart:html";
import "dart:math";
  
CanvasElement _canvas;
CanvasRenderingContext2D _ctx;

class Pencil {
  CanvasElement getCanvas() => _canvas;
  CanvasRenderingContext2D getContext() => _ctx;
  
  static void setCanvas(CanvasElement ele) {
    _canvas = ele;
  }
  
  static CanvasElement createCanvas(Element parent, [int width = 800, int height = 600]) {
    _canvas = new CanvasElement();
    _canvas.width = width;
    _canvas.height = height;
    parent.append(_canvas);
    return _canvas;
  }
}

class Path {
  List<Point> points = new List<Point>();
  
  void _draw() {
    if (points.length > 0) {
      _ctx.beginPath();
      _ctx.moveTo(points[0].x, points[0].y);
      for (int i = 1; i < points.length; i ++) {
        _ctx.lineTo(points[i].x, points[i].y);
      }
    }
  }
  
  void fill(Object style) {
    _draw();
    _ctx.fillStyle = style;
    _ctx.fill();
    _ctx.closePath();
  }
  
  void stroke(Object style) {
    _draw();
    _ctx.strokeStyle = style;
    _ctx.stroke();
    _ctx.closePath();
  }
}

class Color {
  static const String red = "#FF0000";
  static const String yellow = "#FFFF00";
  static const String green = "#00FF00";
  static const String cyan = "#00FFFF";
  static const String blue = "#0000FF";
  static const String magenta = "#FF00FF";
  
  static String rgb(num r, num g, num b) => "rgb($r,$g,$b)";
  static String rgba(num r, num g, num b, num a) => "rgba($r,$g,$b,$a)";
  static String hsl(num h, num s, num l) => "hsl($h,$s,$l)";
}