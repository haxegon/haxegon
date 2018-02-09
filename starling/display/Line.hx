// =================================================================================================
//
//	Starling Shapes
//	Copyright 2014 Fovea. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display;

import flash.geom.Point;

/** A Line represents a segment with a thickness and uniform color or a color gradient.
 *
 * <p>It inherit from the Poly4 class which means you can setup per-vertex color.
 * The first two points of the Poly4 are those associated with the `from` point of the Line.
 * The last two points are associated with the `to` point of the Line.</p>
 *
 *  @see Poly4
 */
class Line extends Poly4 
{
	public var from:Point = new Point(0, 0);
	public var to:Point = new Point(0, 0);
	public var l1:Point = new Point(0, 0);
	public var l2:Point = new Point(0, 0);
	public var l3:Point = new Point(0, 0);
	public var l4:Point = new Point(0, 0);
	
	public var thickness:Float;
	
	public function new(x1:Float, y1:Float, x2:Float, y2:Float, thickness:Float, color:Int) {
		from.setTo(x1, y1);
		to.setTo(x2, y2);
		this.thickness = thickness;
		
		var dx:Float = to.x - from.x;
		var dy:Float = to.y - from.y;
		var l:Float = Math.sqrt(dx*dx + dy*dy);
		var u:Point = new Point(dx/l, dy/l);
		var v:Point = new Point(u.y, -u.x);
		var halfT:Float = thickness * 0.5;

		l1 = from.clone();
		l1.offset(v.x * halfT, v.y * halfT);
		l1.offset(-u.x * halfT, -u.y * halfT);

		l2 = from.clone();
		l2.offset(-v.x * halfT, -v.y * halfT);
		l2.offset(-u.x * halfT, -u.y * halfT);

		l3 = to.clone();
		l3.offset(v.x * halfT, v.y * halfT);
		l3.offset(u.x * halfT, u.y * halfT);

		l4 = to.clone();
		l4.offset(-v.x * halfT, -v.y * halfT);
		l4.offset(u.x * halfT, u.y * halfT);

		super(l1.x, l1.y, l2.x, l2.y, l3.x, l3.y, l4.x, l4.y, color);
	}
	
	
	public function setPosition(x1:Float, y1:Float, x2:Float, y2:Float)
	{
		from.setTo(x1, y1);
		to.setTo(x2, y2);
		
		var dx:Float = to.x - from.x;
		var dy:Float = to.y - from.y;
		var l:Float = Math.sqrt(dx*dx + dy*dy);
		var u:Point = new Point(dx/l, dy/l);
		var v:Point = new Point(u.y, -u.x);
		var halfT:Float = thickness * 0.5;

		l1 = from.clone();
		l1.offset(v.x * halfT, v.y * halfT);
		l1.offset(-u.x * halfT, -u.y * halfT);

		l2 = from.clone();
		l2.offset(-v.x * halfT, -v.y * halfT);
		l2.offset(-u.x * halfT, -u.y * halfT);

		l3 = to.clone();
		l3.offset(v.x * halfT, v.y * halfT);
		l3.offset(u.x * halfT, u.y * halfT);

		l4 = to.clone();
		l4.offset(-v.x * halfT, -v.y * halfT);
		l4.offset(u.x * halfT, u.y * halfT);

		setVertexPositions(l1.x, l1.y, l2.x, l2.y, l3.x, l3.y, l4.x, l4.y);
	}
}
