// =================================================================================================
//
//	Starling Shapes
//	Copyright 2014 Fovea. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package haxegon.starlingshapes;

import flash.geom.Point;
import starling.display.Sprite;

class EllipseRing extends Sprite {
  private var _innerRadiusx:Float;
  private var _innerRadiusy:Float;
  private var _outerRadiusx:Float;
  private var _outerRadius2x:Float;
  private var _outerRadiusy:Float;
  private var _outerRadius2y:Float;
  public var _polygons:Array<Poly4>;

  public function new(xoff:Float, yoff:Float, innerRadiusx:Float, innerRadiusy:Float, outerRadiusx:Float, outerRadiusy:Float, color:Int=0xffffff, alpha:Float = 1.0, nsides:Int = -1, ?startangle:Float) {
		super();
    setto(xoff, yoff, innerRadiusx, innerRadiusy, outerRadiusx, outerRadiusy, color, alpha, nsides, startangle); 
  }
	
	public function setto(xoff:Float, yoff:Float, innerRadiusx:Float, innerRadiusy:Float, outerRadiusx:Float, outerRadiusy:Float, color:Int=0xffffff, alpha:Float = 1.0, nsides:Int = -1, ?startangle:Float) {
		_polygons = new Array<Poly4>();
    _innerRadiusx = innerRadiusx;
		_innerRadiusy = innerRadiusy;
    _outerRadiusx = outerRadiusx;
    _outerRadius2x = outerRadiusx * outerRadiusx;
    _outerRadiusy = outerRadiusy;
    _outerRadius2y = outerRadiusy * outerRadiusy;
    var c0:Point = new Point();
    var c1:Point = new Point();
    var p0:Point = new Point();
    var p1:Point = new Point();
    var nParts:Int = Std.int(Math.min(Math.max(Math.round((outerRadiusx + outerRadiusy) * 0.25), 8), 75));
		if (nsides > -1) nParts = nsides;
    var angle:Float = 0;
		if (startangle != null) angle = startangle;
    for (i in 0 ... nParts) {
      var a0:Float = angle + ((i + 0.0) * 2.0 * Math.PI / nParts);
      var a1:Float = angle + ((i + 1.0) * 2.0 * Math.PI / nParts);
      var ca0:Float = Math.cos(a0);
      var sa0:Float = Math.sin(a0);
      var ca1:Float = Math.cos(a1);
      var sa1:Float = Math.sin(a1);
      c0.x = xoff + (outerRadiusx + ca0 * innerRadiusx);
      c0.y = yoff + (outerRadiusy + sa0 * innerRadiusy);
      c1.x = xoff + (outerRadiusx + ca1 * innerRadiusx);
      c1.y = yoff + (outerRadiusy + sa1 * innerRadiusy);
      p0.x = xoff + (outerRadiusx + ca0 * outerRadiusx);
      p0.y = yoff + (outerRadiusy + sa0 * outerRadiusy);
      p1.x = xoff + (outerRadiusx + ca1 * outerRadiusx);
      p1.y = yoff + (outerRadiusy + sa1 * outerRadiusy);
      var q:Poly4 = new Poly4(c0.x, c0.y, p0.x, p0.y, c1.x, c1.y, p1.x, p1.y, color);
			if(alpha != 1.0) q.alpha = alpha;
      _polygons.push(q);
      addChild(q);
    }
	}

	public function setpolycolor(value:Int) {
    for (i in 0 ... _polygons.length) {
      _polygons[i].color = value;
    }
  }
}