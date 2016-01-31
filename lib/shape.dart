
part of pencil;

class Vector {
  num x;
  num y;
  
  Vector([this.x, this.y]) {
    this.x ??= 0.0;
    this.y ??= 0.0;
  }
  Vector.from(Vector v) : this(v.x, v.y);
  
  void set(num x, num y) {
    this.x = x;
    this.y = y;
  }
  
  void setVector(Vector v) {
    this.x = v.x;
    this.y = v.y;
  }
  
  Vector operator +(Vector other) => new Vector(x + other.x, y + other.y);
  Vector operator -(Vector other) => new Vector(x - other.x, y - other.y);
  Vector operator *(num other) => new Vector(x * other, y * other);
  Vector operator /(num other) => new Vector(x / other, y / other);
  bool operator ==(other) => other is Vector && other.x == x && other.y == y;
  int get hashCode => x.hashCode * 31 + y.hashCode;
  
  num get sqrMagnitude => x * x + y * y;
  num get magnitude => sqrt(sqrMagnitude);
  Vector get normalized => this / magnitude;
  
  void clamp(Vector min, Vector max) => set(Math.min(min.x, Math.max(max.x, x)), Math.min(min.y, Math.max(max.y, y)));
  void clampMagnitude(num maxMagnitude) => setVector(normalized * Math.max(maxMagnitude, magnitude));
  void scale(Vector other) => set(x * other.x, y * other.y);
  
  static num angle(Vector a, Vector b) => acos(dot(a, b) / (a.magnitude * b.magnitude));
  static num dot(Vector a, Vector b) => a.x * b.x + a.y * b.y;
  static Vector reflect(Vector dir, Vector normal) => dir - normal * 2 * dot(normal, dir);
  static Vector rotate(Vector p, num t) {
    num theta = t * (PI / 180.0);
    return new Vector(cos(theta) * p.x - sin(theta) * p.y, sin(theta) * p.x + cos(theta) * p.y);
  }
  static num distance(Vector a, Vector b) => (b - a).magnitude;
  static Vector min(Vector a, Vector b) => new Vector(Math.min(a.x, b.x), Math.min(a.y, b.y));
  static Vector max(Vector a, Vector b) => new Vector(Math.max(a.x, b.x), Math.max(a.y, b.y));
  static Vector lerp(Vector a, Vector b, num t) => a + (b - a) * t;
  
  static Vector get zero => new Vector(0, 0);
  static Vector get one => new Vector(1, 1);
  static Vector get left => new Vector(-1, 0);
  static Vector get right => new Vector(1, 0);
  static Vector get up => new Vector(0, -1);
  static Vector get down => new Vector(0, 1);
}

abstract class Shape {
  Vector position;
  num rotation;
  
  Shape({Vector position, num rotation, this.fill, this.stroke}) {
    this.position = position ?? Vector.zero;
    this.rotation = rotation ?? 0.0;
  }
  
  Color fill;
  Color stroke;
  
  num getRadius();
  void _draw(CanvasRenderingContext2D ctx) {
    if (fill != null) {
      ctx.fillStyle = fill.toString();
      ctx.fill();
    }
    if (stroke != null) {
      ctx.strokeStyle = stroke.toString();
      ctx.stroke();
    }
  }
  
  bool contains(Vector p) => HitTest.contains(this, p);
  bool intersects(Shape s) => HitTest.intersects(this, s);
  
  Shape clone();
}

class Box extends Shape {
  num width;
  num height;
  
  Box(this.width, this.height, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke);
  Box.square(num size, {Vector position, num rotation, Color fill, Color stroke}) : this(size, size, position: position, rotation: rotation, fill: fill, stroke: stroke);
  
  num getRadius() => sqrt(width*width+height*height) * 0.5;
  
  void _draw(CanvasRenderingContext2D ctx) {
    ctx.rect(-width * 0.5, -height * 0.5, width, height);
    super._draw(ctx);
  }
  
  Shape clone() => new Box(width, height, position: position, rotation: rotation, fill: fill, stroke: stroke);
}

class Circle extends Shape {
  num diameter;
  
  Circle(this.diameter, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke);
  
  num getRadius() => diameter * 0.5;
  
  void _draw(CanvasRenderingContext2D ctx) {
    ctx.arc(0, 0, diameter * 0.5, 0, PI * 2.0);
    super._draw(ctx);
  }
  Shape clone() => new Circle(diameter, position: position, rotation: rotation, fill: fill, stroke: stroke);
}

class Triangle extends Shape {
  Vector p0;
  Vector p1;
  Vector p2;
  
  Triangle(this.p0, this.p1, this.p2, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke);
  Triangle.isosceles(num width, num height, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke) {
    p0 = new Vector(0, -height * 0.5);
    p1 = new Vector(width * 0.5, height * 0.5);
    p2 = new Vector(-width * 0.5, height * 0.5);
  }
  Triangle.equilateral(num height, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke) {
    num s = height / (sqrt(3) * 0.5);
    p0 = new Vector(0, -height * 0.5);
    p1 = new Vector(s * 0.5, height * 0.5);
    p2 = new Vector(-s * 0.5, height * 0.5);
  }
  Triangle.right(num width, num height, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke) {
    p0 = new Vector(-width * 0.5, -height * 0.5);
    p1 = new Vector(width * 0.5, height * 0.5);
    p2 = new Vector(-width * 0.5, height * 0.5);
  }
  
  num getRadius() => max(p0.magnitude, max(p1.magnitude, p2.magnitude));
  
  void _draw(CanvasRenderingContext2D ctx) {
    ctx.moveTo(p0.x, p0.y);
    ctx.lineTo(p1.x, p1.y);
    ctx.lineTo(p2.x, p2.y);
    ctx.lineTo(p0.x, p0.y);
    super._draw(ctx);
  }
  
  Shape clone() => new Triangle(p0, p1, p2, position: position, rotation: rotation, fill: fill, stroke: stroke);
}

class Heart extends Shape {
  num size;
  
  Heart(this.size, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke);
  
  getRadius() => size * 0.575;
  
  void _draw(CanvasRenderingContext2D ctx) {
    num radius = size * 0.5;
    ctx.translate(0, radius * 0.125);
    ctx.moveTo(0, radius * 0.75);
    ctx.bezierCurveTo(-radius, 0, -radius, -radius * 0.5, -radius, -radius * 0.5);
    ctx.arc(-radius * 0.5, -radius * 0.5, radius * 0.5, PI, PI * 2.0);
    ctx.arc(radius * 0.5, -radius * 0.5, radius * 0.5, PI, PI * 2.0);
    ctx.moveTo(radius, -radius * 0.5);
    ctx.bezierCurveTo(radius, -radius * 0.5, radius, 0, 0, radius * 0.75);
    ctx.translate(0, -radius * 0.125);
    super._draw(ctx);
  }
  
  static Vector _lCirclePt(num size) => new Vector(-size * 0.5 * 0.5, -size * 0.5 * 0.5 + size * 0.5 * 0.125);
  static Vector _rCirclePt(num size) => new Vector(size * 0.5 * 0.5, -size * 0.5 * 0.5 + size * 0.5 * 0.125);
  static num _circleRad(num size) => size * 0.25;
  static List<Vector> _tPts(num size) => [new Vector(-size * 0.465, -size * 0.0625), new Vector(size * 0.465, -size * 0.0625), new Vector(0, size * 0.4375)];
  
  Shape clone() => new Heart(size, position: position, rotation: rotation, fill: fill, stroke: stroke);
}

class Line extends Shape {
  Vector p0;
  Vector p1;
  
  Line(this.p0, this.p1, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke);
  
  num getRadius() => (p1 - p0).magnitude;
  
  void _draw(CanvasRenderingContext2D ctx) {
    ctx.moveTo(p0.x, p0.y);
    ctx.lineTo(p1.x, p1.y);
    super._draw(ctx);
  }
  
  Shape clone() => new Line(p0, p1, position: position, rotation: rotation, fill: fill, stroke: stroke);
}

class Polygon extends Shape {
  List<Vector> points;
  
  Polygon(this.points, {Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke);
  
  num getRadius() => points.fold(0, (num val, Vector pt) => max(val, pt.magnitude));
  
  void _draw(CanvasRenderingContext2D ctx) {
    if (points.length < 3) return;
    ctx.moveTo(points[0].x, points[0].y);
    for (int i = 1; i < points.length; i ++) ctx.lineTo(points[i].x, points[i].y);
    ctx.lineTo(points[0].x, points[0].y);
    super._draw(ctx);
  }
  
  Shape clone() => new Polygon(points.toList().map((Vector v) => new Vector.from(v)), position: position, rotation: rotation, fill: fill, stroke: stroke);
}

class Label extends Shape {
  String text;
  String font;
  int fontWeight;
  int fontSize;
  String align;
  String baseline;
  
  Label(this.text, {this.fontSize:24,this.fontWeight:400,this.font:"Arial Black",this.align:Align.center,this.baseline:Baseline.middle, Vector position, num rotation, Color fill, Color stroke}) : super(position: position, rotation: rotation, fill: fill, stroke: stroke) {
    if (font == "Arial Black" && fontWeight == 400) {
      font = "Arial";
      fontWeight = 900;
    }
  }
  
  num getRadius() => 0;
  
  void _draw(CanvasRenderingContext2D ctx) {
    ctx.font = "$fontWeight ${fontSize}px $font, Arial";
    ctx.textAlign = align;
    ctx.textBaseline = baseline;
    if (fill != null) {
      ctx.fillStyle = fill.toString();
      ctx.fillText(text, 0, 0);
    }
    if (stroke != null) {
      ctx.strokeStyle = stroke.toString();
      ctx.strokeText(text, 0, 0);
    }
  }
  
  Shape clone() => new Label(text, fontSize: fontSize, align: align, baseline: baseline, position: position, rotation: rotation, fill: fill, stroke: stroke);
}

class Sprite {
  ImageElement img;
  int frameX;
  int frameY;
  num srcX;
  num srcY;
  num srcW;
  num srcH;
  num width;
  num height;
  
  bool _loaded = false;
  
  Sprite(String src, {this.width, this.height, this.frameX:0, this.frameY:0, this.srcX:0, this.srcY:0, this.srcW, this.srcH}) {
    img = new ImageElement();
    img.src = src;
    img.onLoad.listen((Event e) {
      srcW ??= img.width;
      srcH ??= img.height;
      width ??= srcW;
      height ??= srcH;
      _loaded = true;
    });
  }
  
  Box getBounds() => (_loaded) ? new Box(width, height) : null;
  
  void _draw(CanvasRenderingContext2D ctx) {
    if (_loaded) ctx.drawImageScaledFromSource(img, srcX+srcW*frameX, srcY+srcH*frameY, srcW, srcH, -width/2, -height/2, width, height);
  }
}

abstract class Align {
  static const String start = "start";
  static const String end = "end";
  static const String left = "left";
  static const String center = "center";
  static const String right = "right";
}

abstract class Baseline {
  static const String top = "top";
  static const String bottom = "bottom";
  static const String middle = "middle";
  static const String alphabetic = "alphabetic";
  static const String hanging = "hanging";
}

Vector _rot(Vector p, num t) {
  num theta = t * (PI / 180.0);
  return new Vector(cos(theta) * p.x - sin(theta) * p.y, sin(theta) * p.x + cos(theta) * p.y);
}

class HitTest {
  static bool _pointAboveLine(Vector ap, Vector bp0, Vector bp1) => ((bp1.x - bp0.x) * (ap.y - bp0.y) - (bp1.y - bp0.y) * (ap.x - bp0.x)) >= 0;
  static bool pointBox(Vector ap, Vector bp, num bt, num bw, num bh) {
    Vector p0 = bp + _rot(new Vector(-bw, bh) * 0.5, bt);
    Vector p1 = bp + _rot(new Vector(-bw, -bh) * 0.5, bt);
    Vector p2 = bp + _rot(new Vector(bw, -bh) * 0.5, bt);
    Vector p3 = bp + _rot(new Vector(bw, bh) * 0.5, bt);
    return _pointAboveLine(ap, p0, p1) && _pointAboveLine(ap, p1, p2) && _pointAboveLine(ap, p2, p3) && _pointAboveLine(ap, p3, p0);
  }
  static bool pointCircle(Vector ap, Vector bp, num br) => (bp - ap).magnitude <= br;
  static bool pointTriangle(Vector ap, Vector bp, num bt, Vector bp0, Vector bp1, Vector bp2){
    Vector p0 = bp + _rot(bp0, bt);
    Vector p1 = bp + _rot(bp1, bt);
    Vector p2 = bp + _rot(bp2, bt);
    return _pointAboveLine(ap, p0, p1) && _pointAboveLine(ap, p1, p2) && _pointAboveLine(ap, p2, p0);
  }
  static bool pointHeart(Vector ap, Vector bp, num bt, num bs) {
    Vector lcp = Heart._lCirclePt(bs);
    Vector rcp = Heart._rCirclePt(bs);
    num cr = Heart._circleRad(bs);
    List<Vector> tps = Heart._tPts(bs);
    return pointCircle(ap, bp+_rot(lcp, bt), cr) || pointCircle(ap, bp+_rot(rcp, bt), cr) || pointTriangle(ap, bp, bt, tps[0], tps[1], tps[2]);
  }
  static bool pointPolygon(Vector ap, Vector bp, num bt, List<Vector> bps) {
    bool inside = true;
    for (int i = 0; i < bps.length; i ++) inside = inside && _pointAboveLine(ap, bp+_rot(bps[i], bt), bp+_rot(bps[(i+1)%bps.length], bt));
    return inside;
  }
  static bool boxBox(Vector ap, num at, num aw, num ah, Vector bp, num bt, num bw, num bh) {
    if (pointBox(ap, bp, bt, bw, bh) || pointBox(bp, ap, at, aw, ah)) return true;
    Vector p0 = new Vector(-bw, bh) * 0.5;
    Vector p1 = new Vector(-bw, -bh) * 0.5;
    Vector p2 = new Vector(bw, -bh) * 0.5;
    Vector p3 = new Vector(bw, bh) * 0.5;
    return lineBox(bp, bt, p0, p1, ap, at, aw, ah) || lineBox(bp, bt, p1, p2, ap, at, aw, ah) || lineBox(bp, bt, p2, p3, ap, at, aw, ah) || lineBox(bp, bt, p3, p0, ap, at, aw, ah);
  }
  static bool boxCircle(Vector ap, num at, num aw, num ah, Vector bp, num br) {
    if (pointBox(bp, ap, at, aw, ah)) return true;
    Vector p0 = new Vector(-aw, ah) * 0.5;
    Vector p1 = new Vector(-aw, -ah) * 0.5;
    Vector p2 = new Vector(aw, -ah) * 0.5;
    Vector p3 = new Vector(aw, ah) * 0.5;
    return lineCircle(ap, at, p0, p1, bp, br) || lineCircle(ap, at, p1, p2, bp, br) || lineCircle(ap, at, p2, p3, bp, br) || lineCircle(ap, at, p3, p0, bp, br);
  }
  static bool boxTriangle(Vector ap, num at, num aw, num ah, Vector bp, num bt, Vector bp0, Vector bp1, Vector bp2) {
    Vector p0 = new Vector(-aw, ah) * 0.5;
    Vector p1 = new Vector(-aw, -ah) * 0.5;
    Vector p2 = new Vector(aw, -ah) * 0.5;
    Vector p3 = new Vector(aw, ah) * 0.5;
    return lineTriangle(ap, at, p0, p1, bp, bt, bp0, bp1, bp2) || lineTriangle(ap, at, p1, p2, bp, bt, bp0, bp1, bp2) || lineTriangle(ap, at, p2, p3, bp, bt, bp0, bp1, bp2) || lineTriangle(ap, at, p3, p0, bp, bt, bp0, bp1, bp2);
  }
  static bool boxHeart(Vector ap, num at, num aw, num ah, Vector bp, num bt, num bs) {
    Vector lcp = Heart._lCirclePt(bs);
    Vector rcp = Heart._rCirclePt(bs);
    num cr = Heart._circleRad(bs);
    List<Vector> tps = Heart._tPts(bs);
    return boxCircle(ap, at, aw, ah, bp+_rot(lcp, bt), cr) || boxCircle(ap, at, aw, ah, bp+_rot(rcp, bt), cr) || boxTriangle(ap, at, aw, ah, bp, bt, tps[0], tps[1], tps[2]);
  }
  static bool boxPolygon(Vector ap, num at, num aw, num ah, Vector bp, num bt, List<Vector> bps) {
    for (int i = 0; i < bps.length; i++) if (pointBox(bp+_rot(bps[i], bt), ap, at, aw, ah)) return true;
    for (int i = 0; i < bps.length; i++) if (lineBox(bp, bt, bps[i], bps[(i+1)%bps.length], ap, at, aw, ah)) return true;
    return false;
  }
  static bool circleCircle(Vector ap, num ar, Vector bp, num br) => (bp - ap).magnitude <= ar + br;
  static bool circleHeart(Vector ap, num ar, Vector bp, num bt, num bs) {
    Vector lcp = Heart._lCirclePt(bs);
    Vector rcp = Heart._rCirclePt(bs);
    num cr = Heart._circleRad(bs);
    List<Vector> tps = Heart._tPts(bs);
    return circleCircle(ap, ar, bp+_rot(lcp, bt), cr) || circleCircle(ap, ar, bp+_rot(rcp, bt), cr) || triangleCircle(bp, bt, tps[0], tps[1], tps[2], ap, ar);
  }
  static bool circlePolygon(Vector ap, num ar, Vector bp, num bt, List<Vector> bps) {
    for (int i = 0; i < bps.length; i++) if (pointCircle(bp+_rot(bps[i], bt), ap, ar)) return true;
    for (int i = 0; i < bps.length; i++) if (lineCircle(bp, bt, bps[i], bps[(i+1)%bps.length], ap, ar)) return true;    
    return false;
  }
  static bool triangleCircle(Vector ap, num at, Vector ap0, Vector ap1, Vector ap2, Vector bp, num br) {
    if (pointTriangle(bp, ap, at, ap0, ap1, ap2)) return true;
    Vector p0 = ap+_rot(ap0, at);
    Vector p1 = ap+_rot(ap1, at);
    Vector p2 = ap+_rot(ap2, at);
    if (pointCircle(p0, bp, br) || pointCircle(p1, bp, br) || pointCircle(p2, bp, br)) return true;
    if (lineCircle(ap, at, ap0, ap1, bp, br) || lineCircle(ap, at, ap1, ap2, bp, br) || lineCircle(ap, at, ap2, ap0, bp, br)) return true;
    return false;
  }
  static bool triangleTriangle(Vector ap, num at, Vector ap0, Vector ap1, Vector ap2, Vector bp, num bt, Vector bp0, Vector bp1, Vector bp2) {
    return lineTriangle(bp, bt, bp0, bp1, ap, at, ap0, ap1, ap2) || lineTriangle(bp, bt, bp1, bp2, ap, at, ap0, ap1, ap2) || lineTriangle(bp, bt, bp2, bp0, ap, at, ap0, ap1, ap2);
  }
  static bool triangleHeart(Vector ap, num at, Vector ap0, Vector ap1, Vector ap2, Vector bp, num bt, num bs) {
    Vector lcp = Heart._lCirclePt(bs);
    Vector rcp = Heart._rCirclePt(bs);
    num cr = Heart._circleRad(bs);
    List<Vector> tps = Heart._tPts(bs);
    return triangleCircle(ap, at, ap0, ap1, ap2, bp+_rot(lcp, bt), cr) || triangleCircle(ap, at, ap0, ap1, ap2, bp+_rot(rcp, bt), cr) || triangleTriangle(ap, at, ap0, ap1, ap2, bp, bt, tps[0], tps[1], tps[2]);
  }
  static bool trianglePolygon(Vector ap, num at, Vector ap0, Vector ap1, Vector ap2, Vector bp, num bt, List<Vector> bps) {
    for (int i = 0; i < bps.length; i++) if (pointTriangle(bp+_rot(bps[i], bt), ap, at, ap0, ap1, ap2)) return true;
    for (int i = 0; i < bps.length; i++) if (lineTriangle(bp, bt, bps[i], bps[(i+1)%bps.length], ap, at, ap0, ap1, ap2)) return true;    
    return false;    
  }
  static bool heartHeart(Vector ap, num at, num as, Vector bp, num bt, num bs) {
    Vector lcp = Heart._lCirclePt(bs);
    Vector rcp = Heart._rCirclePt(bs);
    num cr = Heart._circleRad(bs);
    List<Vector> tps = Heart._tPts(bs);
    return circleHeart(bp+_rot(lcp, bt), cr, ap, at, as) || circleHeart(bp+_rot(rcp, bt), cr, ap, at, as) || triangleHeart(bp, bt, tps[0], tps[1], tps[2], ap, at, as);    
  }
  static bool heartPolygon(Vector ap, num at, num as, Vector bp, num bt, List<Vector> bps) {
    for (int i = 0; i < bps.length; i++) if (pointHeart(bp+_rot(bps[i], bt), ap, at, as)) return true;
    for (int i = 0; i < bps.length; i++) if (lineHeart(bp, bt, bps[i], bps[(i+1)%bps.length], ap, at, as)) return true;    
    return false;
  }
  static bool lineBox(Vector ap, num at, Vector ap0, Vector ap1, Vector bp, num bt, num bw, num bh) {
    if (pointBox(ap+_rot(ap0, at), bp, bt, bw, bh) || pointBox(ap+_rot(ap1, at), bp, bt, bw, bh)) return true;
    Vector p0 = new Vector(-bw, bh) * 0.5;
    Vector p1 = new Vector(-bw, -bh) * 0.5;
    Vector p2 = new Vector(bw, -bh) * 0.5;
    Vector p3 = new Vector(bw, bh) * 0.5;
    return lineLine(ap, at, ap0, ap1, bp, bt, p0, p1) || lineLine(ap, at, ap0, ap1, bp, bt, p1, p2) || lineLine(ap, at, ap0, ap1, bp, bt, p2, p3) || lineLine(ap, at, ap0, ap1, bp, bt, p3, p0);
  }
  static bool lineCircle(Vector ap, num at, Vector ap0, Vector ap1, Vector bp, num br) {
    if (pointCircle(ap+_rot(ap0, at), bp, br) || pointCircle(ap+_rot(ap1, at), bp, br)) return true;
    Vector e = (ap+_rot(ap1, at)) - (ap+_rot(ap0, at));
    Vector c = bp - (ap+_rot(ap0, at));
    num k = c.x * e.x + c.y * e.y;
    if (k > 0) {
      num len = e.x * e.x + e.y * e.y;
      if (k < len && ((c.x*c.x+c.y*c.y) - br*br) * len <= k*k) return true;
    }
    return false;
  }
  static bool lineTriangle(Vector ap, num at, Vector ap0, Vector ap1, Vector bp, num bt, Vector bp0, Vector bp1, Vector bp2) {
    if (pointTriangle(ap+_rot(ap0, at), bp, bt, bp0, bp1, bp2) || pointTriangle(ap+_rot(ap1, at), bp, bt, bp0, bp1, bp2)) return true;
    return lineLine(ap, at, ap0, ap1, bp, bt, bp0, bp1) || lineLine(ap, at, ap0, ap1, bp, bt, bp1, bp2) || lineLine(ap, at, ap0, ap1, bp, bt, bp2, bp0);
  }
  static bool lineHeart(Vector ap, num at, Vector ap0, Vector ap1, Vector bp, num bt, num bs) {
    Vector lcp = Heart._lCirclePt(bs);
    Vector rcp = Heart._rCirclePt(bs);
    num cr = Heart._circleRad(bs);
    List<Vector> tps = Heart._tPts(bs);
    return lineCircle(ap, at, ap0, ap1, bp+_rot(lcp, bt), cr) || lineCircle(ap, at, ap0, ap1, bp+_rot(rcp, bt), cr) || lineTriangle(ap, at, ap0, ap1, bp, bt, tps[0], tps[1], tps[2]);
  }
  static bool _colinear(Vector p, Vector q, Vector r) => (q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y));
  static int _orientation(Vector p, Vector q, Vector r) {
    num val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
    if (val == 0) return 0;
    return (val > 0) ? 1 : 2;
  }
  static bool lineLine(Vector ap, num at, Vector ap0, Vector ap1, Vector bp, num bt, Vector bp0, Vector bp1) {
    ap0 = ap+_rot(ap0, at);
    ap1 = ap+_rot(ap1, at);
    bp0 = bp+_rot(bp0, bt);
    bp1 = bp+_rot(bp1, bt);
    num o0 = _orientation(ap0, ap1, bp0);
    num o1 = _orientation(ap0, ap1, bp1);
    num o2 = _orientation(bp0, bp1, ap0);
    num o3 = _orientation(bp0, bp1, ap1);
    if (o0 != 01 && o2 != o3) return true;
    if (o0 == 0 && _colinear(ap0, bp0, ap1)) return true;
    if (o1 == 0 && _colinear(ap0, bp1, ap1)) return true;
    if (o2 == 0 && _colinear(bp0, ap0, bp1)) return true;
    if (o3 == 0 && _colinear(bp0, ap1, bp1)) return true;
    return false;
  }
  static bool linePolygon(Vector ap, num at, Vector ap0, Vector ap1, Vector bp, num bt, List<Vector> bps) {
    if (pointPolygon(ap+_rot(ap0, at), bp, bt, bps) || pointPolygon(ap+_rot(ap1, at), bp, bt, bps)) return true;
    for (int i = 0; i < bps.length; i++) {
      if (lineLine(ap, at, ap0, ap1, bp, bt, bps[i], bps[(i+1)%bps.length])) return true;
    }
    return false;
  }
  static bool polygonPolygon(Vector ap, num at, List<Vector> aps, Vector bp, num bt, List<Vector> bps) {
    for (int i = 0; i < bps.length; i++) if (pointPolygon(bp+_rot(bps[i], bt), ap, at, aps)) return true;
    for (int i = 0; i < bps.length; i++) if (linePolygon(bp, bt, bps[i], bps[(i+1)%bps.length], ap, at, aps)) return true;    
    return false;
  }
  static bool intersects(Shape a, Shape b) {
    if (a is Text || b is Text) return false;
    if (!circleCircle(a.position, a.getRadius(), b.position, b.getRadius())) return false;
    if (a is Box && b is Box) return boxBox(a.position, a.rotation, a.width, a.height, b.position, b.rotation, b.width, b.height);
    if (a is Box && b is Circle) return boxCircle(a.position, a.rotation, a.width, a.height, b.position, b.diameter * 0.5);
    if (a is Box && b is Triangle) return boxTriangle(a.position, a.rotation, a.width, a.height, b.position, b.rotation, b.p0, b.p1, b.p2);
    if (a is Box && b is Heart) return boxHeart(a.position, a.rotation, a.width, a.height, b.position, b.rotation, b.size);
    if (a is Box && b is Line) return lineBox(b.position, b.rotation, b.p0, b.p1, a.position, a.rotation, a.width, a.height);
    if (a is Box && b is Polygon) return boxPolygon(a.position, a.rotation, a.width, a.height, b.position, b.rotation, b.points);
    if (a is Circle && b is Box) return boxCircle(b.position, b.rotation, b.width, b.height, a.position, a.diameter * 0.5);
    if (a is Circle && b is Circle) return circleCircle(a.position, a.diameter * 0.5, b.position, b.diameter * 0.5);
    if (a is Circle && b is Triangle) return triangleCircle(b.position, b.rotation, b.p0, b.p1, b.p2, a.position, a.diameter * 0.5);
    if (a is Circle && b is Heart) return circleHeart(a.position, a.diameter * 0.5, b.position, b.rotation, b.size);
    if (a is Circle && b is Line) return lineCircle(b.position, b.rotation, b.p0, b.p1, a.position, a.diameter * 0.5);
    if (a is Circle && b is Polygon) return circlePolygon(a.position, a.diameter * 0.5, b.position, b.rotation, b.points);
    if (a is Triangle && b is Box) return boxTriangle(b.position, b.rotation, b.width, b.height, a.position, a.rotation, a.p0, a.p1, a.p2);
    if (a is Triangle && b is Circle) return triangleCircle(a.position, a.rotation, a.p0, a.p1, a.p2, b.position, b.diameter * 0.5);
    if (a is Triangle && b is Triangle) return triangleTriangle(a.position, a.rotation, a.p0, a.p1, a.p2, b.position, b.rotation, b.p0, b.p1, b.p2);
    if (a is Triangle && b is Heart) return triangleHeart(a.position, a.rotation, a.p0, a.p1, a.p2, b.position, b.rotation, b.size);
    if (a is Triangle && b is Line) return lineTriangle(b.position, b.rotation, b.p0, b.p1, a.position, a.rotation, a.p0, a.p1, a.p2);
    if (a is Triangle && b is Polygon) return trianglePolygon(a.position, a.rotation, a.p0, a.p1, a.p2, b.position, b.rotation, b.points);
    if (a is Heart && b is Box) return boxHeart(b.position, b.rotation, b.width, b.height, a.position, a.rotation, a.size);
    if (a is Heart && b is Circle) return circleHeart(b.position, b.diameter * 0.5, a.position, a.rotation, a.size);
    if (a is Heart && b is Triangle) return triangleHeart(b.position, b.rotation, b.p0, b.p1, b.p2, a.position, a.rotation, a.size);
    if (a is Heart && b is Heart) return heartHeart(a.position, a.rotation, a.size, b.position, b.rotation, b.size);
    if (a is Heart && b is Line) return lineHeart(b.position, b.rotation, b.p0, b.p1, a.position, a.rotation, a.size);
    if (a is Heart && b is Polygon) return heartPolygon(a.position, a.rotation, a.size, b.position, b.rotation, b.points);
    if (a is Line && b is Box) return lineBox(a.position, a.rotation, a.p0, a.p1, b.position, b.rotation, b.width, b.height);
    if (a is Line && b is Circle) return lineCircle(a.position, a.rotation, a.p0, a.p1, b.position, b.diameter * 0.5);
    if (a is Line && b is Triangle) return lineTriangle(a.position, a.rotation, a.p0, a.p1, b.position, b.rotation, b.p0, b.p1, b.p2);
    if (a is Line && b is Heart) return lineHeart(a.position, a.rotation, a.p0, a.p1, b.position, b.rotation, b.size);
    if (a is Line && b is Line) return lineLine(a.position, a.rotation, a.p0, a.p1, b.position, b.rotation, b.p0, b.p1);
    if (a is Line && b is Polygon) return linePolygon(a.position, a.rotation, a.p0, a.p1, b.position, b.rotation, b.points);
    if (a is Polygon && b is Box) return boxPolygon(b.position, b.rotation, b.width, b.height, a.position, a.rotation, a.points);
    if (a is Polygon && b is Circle) return circlePolygon(b.position, b.diameter * 0.5, a.position, a.rotation, a.points);
    if (a is Polygon && b is Triangle) return trianglePolygon(b.position, b.rotation, b.p0, b.p1, b.p2, a.position, a.rotation, a.points);
    if (a is Polygon && b is Heart) return heartPolygon(b.position, b.rotation, b.size, a.position, a.rotation, a.points);
    if (a is Polygon && b is Line) return linePolygon(b.position, b.rotation, b.p0, b.p1, a.position, a.rotation, a.points);
    if (a is Polygon && b is Polygon) return polygonPolygon(a.position, a.rotation, a.points, b.position, b.rotation, b.points);
    return false;
  }
  static bool contains(Shape s, Vector p) {
    if (s is Text || s is Line) return false;
    if (!pointCircle(p, s.position, s.getRadius())) return false;
    if (s is Box) return pointBox(p, s.position, s.rotation, s.width, s.height);
    if (s is Circle) return pointCircle(p, s.position, s.diameter * 0.5);
    if (s is Triangle) return pointTriangle(p, s.position, s.rotation, s.p0, s.p1, s.p2);
    if (s is Heart) return pointHeart(p, s.position, s.rotation, s.size);
    if (s is Polygon) return pointPolygon(p, s.position, s.rotation, s.points);
    return false;
  }
}