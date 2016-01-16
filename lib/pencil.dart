library pencil;

import "dart:html";
import "dart:collection";
import "dart:math";

class Pencil {
  CanvasElement _canvas;
  CanvasRenderingContext2D _ctx;
  CanvasElement getCanvas() => _canvas;
  CanvasRenderingContext2D getContext() => _ctx;

  Queue<_StackOp> _transforms = new Queue<_StackOp>();

  Pencil.fromCanvas(CanvasElement ele) {
    _canvas = ele;
    _ctx = _canvas.getContext('2d');
  }

  Pencil.createCanvas(Element parent, [int width = 800, int height = 600]) {
    _canvas = new CanvasElement();
    _canvas.width = width;
    _canvas.height = height;
    parent.append(_canvas);
    _ctx = _canvas.getContext('2d');
  }
  
  Pencil clear([Object style = "#6495ED"]) => move(_canvas.width / 2, _canvas.height / 2).rectangle(_canvas.width, _canvas.height).fill(style).up();
  
  Pencil shape(List<Point> points) {
    for (int i = 0; i < points.length; i ++) {
      if (i == 0) _ctx.moveTo(points[i].x, points[i].y);
      else _ctx.lineTo(points[i].x, points[i].y);
    }
    return this;
  }
  
  Pencil polygon(int sides, num radius) {
    List<Point> points = new List<Point>();
    for (int i = 0; i <= sides; i ++) points.add(new Point(radius * cos(i * 2.0 * PI / sides), radius * sin(i * 2.0 * PI / sides)));
    return shape(points);
  }
  
  Pencil rectangle(num width, num height) {
    _ctx.rect(-width/2, -height/2, width, height);
    return this;
  }
  
  Pencil square(num size) => rectangle(size, size);
  
  Pencil circle(num radius) {
    _ctx.arc(0, 0, radius, 0, PI * 2.0);
    return this;
  }

  Pencil fill(Object style) {
    _ctx.fillStyle = style;
    _ctx.fill();
    return this;
  }

  Pencil stroke(Object style) {
    _ctx.strokeStyle = style;
    _ctx.stroke();
    return this;
  }

  Pencil translate(num x, num y) {
    _Translate op = new _Translate(x, y);
    op.apply(this);
    _transforms.add(op);
    return this;
  }
  
  Pencil move(num x, num y) => translate(x, y);

  Pencil rotate(num angle) {
    _Rotate op = new _Rotate(angle*PI/180.0);
    op.apply(this);
    _transforms.add(op);
    return this;
  }

  Pencil scale(num x, num y) {
    _Scale op = new _Scale(x, y);
    op.apply(this);
    _transforms.add(op);
    return this;
  }

  Pencil up() {
    while (_transforms.length > 0) _transforms.removeLast().unapply(this);
    _ctx.beginPath();
    return this;
  }
}

abstract class _StackOp {
  void apply(Pencil pencil);
  void unapply(Pencil pencil);
}

class _Translate extends _StackOp {
  num x;
  num y;
  _Translate(this.x, this.y);
  void apply(Pencil pencil) => pencil.getContext().translate(x, y);
  void unapply(Pencil pencil) => pencil.getContext().translate(-x, -y);
}

class _Rotate extends _StackOp {
  num angle;
  _Rotate(this.angle);
  void apply(Pencil pencil) => pencil.getContext().rotate(angle);
  void unapply(Pencil pencil) => pencil.getContext().rotate(-angle);
}

class _Scale extends _StackOp {
  num x;
  num y;
  _Scale(this.x, this.y);
  void apply(Pencil pencil) => pencil.getContext().scale(x, y);
  void unapply(Pencil pencil) => pencil.getContext().scale(-x, -y);
}

class Color {
  static const String white = "#FFFFFF";
  static const String lightGray = "#BFBFBF";
  static const String gray = "#7F7F7F";
  static const String darkGray = "#3F3F3F";
  static const String black = "#000000";
  static const String red = "#FF0000";
  static const String orange = "#FF7F00";
  static const String yellow = "#FFFF00";
  static const String lime = "#7FFF00";
  static const String green = "#00FF00";
  static const String turquoise = '#00FF7F';
  static const String cyan = "#00FFFF";
  static const String azure = "#007FFF";
  static const String blue = "#0000FF";
  static const String violet = "#7F00FF";
  static const String magenta = "#FF00FF";
  static const String rose = "#FF007F";

  static String rgb(num r, num g, num b) => "rgb($r,$g,$b)";
  static String rgba(num r, num g, num b, num a) => "rgba($r,$g,$b,$a)";
  static String hsl(num h, num s, num l) => "hsl($h,$s,$l)";
}
