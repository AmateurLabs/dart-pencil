library pencil;

import "dart:html";
import "dart:collection";
import "dart:math";
import "dart:math" as Math;

part "shape.dart";

class Pencil {
  CanvasElement _canvas;
  CanvasRenderingContext2D _ctx;
  CanvasElement getCanvas() => _canvas;
  CanvasRenderingContext2D getContext() => _ctx;

  Queue<_StackOp> _transforms = new Queue<_StackOp>();

  Pencil.fromCanvas(CanvasElement ele) {
    _canvas = ele;
    _init();
  }

  Pencil.createCanvas(Element parent, [int width = 800, int height = 600]) {
    _canvas = new CanvasElement();
    _canvas.width = width;
    _canvas.height = height;
    parent.append(_canvas);
    _init();
  }
  
  void _init() {
    _ctx = _canvas.getContext('2d');
    //_ctx.translate(0.5, 0.5);
    _ctx.imageSmoothingEnabled = false;
    _ctx.save();
  }
  
  static const Color _clearColor = const Color._const(100, 149, 237);
  Pencil clear([Color style = _clearColor]) => move(_canvas.width / 2, _canvas.height / 2).box(_canvas.width, _canvas.height).fill(style).draw();
  
  Pencil shape(Shape shape) {
    _ctx.translate(shape.position.x, shape.position.y);
    _ctx.rotate(shape.rotation*PI/180.0);
    shape._draw(_ctx);
    _ctx.rotate(-shape.rotation*PI/180.0);
    _ctx.translate(-shape.position.x, -shape.position.y);
    return this;
  }
  
  Pencil polygon(int sides, num diameter) {
    List<Vector> points = new List<Vector>();
    for (int i = 0; i <= sides; i ++) points.add(new Vector(diameter * 0.5 * cos(i * 2.0 * PI / sides), diameter * 0.5 * sin(i * 2.0 * PI / sides)));
    return shape(new Polygon(points));
  }
  
  Pencil box(num width, num height) {
    return shape(new Box(width, height));
  }
  
  Pencil square(num size) => box(size, size);
  
  Pencil circle(num diameter) {
    return shape(new Circle(diameter));
  }
  
  Pencil heart(num size) {
    return shape(new Heart(size));
  }
  
  Pencil text(String text, { String align:"center", String base:"middle" }) {
    _ctx.textAlign = align;
    _ctx.textBaseline = base;
    return this;
  }
  
  Pencil sprite(Sprite sprite) {
    sprite._draw(_ctx);
    return this;
  }

  Pencil fill(Color style) {
    _ctx.fillStyle = style.toString();
    _ctx.fill();
    return this;
  }

  Pencil stroke(Color style) {
    _ctx.strokeStyle = style.toString();
    _ctx.stroke();
    return this;
  }
  
  Pencil clip() {
    _ctx.clip();
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
  
  Pencil spin(num angle) => rotate(angle);

  Pencil scale(num x, num y) {
    _Scale op = new _Scale(x, y);
    op.apply(this);
    _transforms.add(op);
    return this;
  }
  
  Pencil grow(num x, num y) => scale(x, y);

  Pencil draw() {
    while (_transforms.length > 0) _transforms.removeLast().unapply(this);
    _ctx.restore();
    _ctx.save();
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
  void unapply(Pencil pencil) => pencil.getContext().scale(1/x, 1/y);
}

class Color {
  final int r;
  final int g;
  final int b;
  final double a;
  
  Color(this.r, this.g, this.b, [this.a = 1.0]);
  const Color._const(this.r, this.g, this.b, [this.a = 1.0]);
  
  static const Color white = const Color._const(255, 255, 255);
  static const Color lightGray = const Color._const(191, 191, 191);
  static const Color gray = const Color._const(127, 127, 127);
  static const Color darkGray = const Color._const(63, 63, 63);
  static const Color black = const Color._const(0, 0, 0);
  static const Color red = const Color._const(255, 0, 0);
  static const Color orange = const Color._const(255, 127, 0);
  static const Color yellow = const Color._const(255, 255, 0);
  static const Color lime = const Color._const(127, 255, 0);
  static const Color green = const Color._const(0, 255, 0);
  static const Color turquoise = const Color._const(0, 255, 127);
  static const Color cyan = const Color._const(0, 255, 255);
  static const Color azure = const Color._const(0, 127, 255);
  static const Color blue = const Color._const(0, 0, 255);
  static const Color violet = const Color._const(127, 0, 255);
  static const Color magenta = const Color._const(255, 0, 255);
  static const Color rose = const Color._const(255, 0, 127);
  static const Color transparent = const Color._const(0, 0, 0, 0.0);
  String toString() => "rgba($r,$g,$b,$a)";
  
  static const List<Color> spectrum = const [red, orange, yellow, lime, green, turquoise, cyan, azure, blue, violet, magenta, rose];
}
