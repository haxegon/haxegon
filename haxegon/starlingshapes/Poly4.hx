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

import openfl.geom.Matrix;
import openfl.geom.Matrix3D;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;

import starling.display.Quad;
import starling.display.DisplayObject;

/** A Poly4 represents an abitrary quad with a uniform color or a color gradient.
 *
 *  <p>You can set one color per vertex. The colors will smoothly fade into each other over the area
 *  of the quad. To display a simple linear color gradient, assign one color to vertices 0 and 1 and 
 *  another color to vertices 2 and 3. </p>
 *
 *  <p>The indices of the vertices are arranged like this:</p>
 *
 *  <pre>
 *  0 - 1
 *  | / |
 *  2 - 3
 *  </pre>
 *
 *  @see Image
 */
class Poly4 extends Quad
{
	public var p1:Point = new Point(0, 0);
	public var p2:Point = new Point(0, 0);
	public var p3:Point = new Point(0, 0);
	public var p4:Point = new Point(0, 0);
	private var xmin:Float = 0;
	private var xmax:Float = 0;
	private var ymin:Float = 0;
	private var ymax:Float = 0;
	
	public function new(x1:Float = 0, y1:Float = 0, x2:Float = 0, y2:Float = 0, 
										  x3:Float = 0, y3:Float = 0, x4:Float = 0, y4:Float = 0, 
											color:Int = 0xffffff) {
		p1.setTo(x1, y1);
		p2.setTo(x2, y2);
		p3.setTo(x3, y3);
		p4.setTo(x4, y4);
		
		xmin = min4(p1.x, p2.x, p3.x, p4.x);
		ymin = min4(p1.y, p2.y, p3.y, p4.y);
		xmax = max4(p1.x, p2.x, p3.x, p4.x);
		ymax = max4(p1.y, p2.y, p3.y, p4.y);
		super(xmax - xmin, ymax - ymin, color);
		
		vertexData.setPoint(0, "position", p1.x - xmin, p1.y - ymin);
		vertexData.setPoint(1, "position", p2.x - xmin, p2.y - ymin);
		vertexData.setPoint(2, "position", p3.x - xmin, p3.y - ymin);
		vertexData.setPoint(3, "position", p4.x - xmin, p4.y - ymin);
		//onVertexDataChanged();
		x = xmin;
		y = ymin;
		_lowerRight.setTo(xmax - xmin, ymax - ymin);
	}
	
	
	public function setVertexPositions(x1:Float = 0, y1:Float = 0, x2:Float = 0, y2:Float = 0, 
										  x3:Float = 0, y3:Float = 0, x4:Float = 0, y4:Float = 0)
	{
		p1.setTo(x1, y1);
		p2.setTo(x2, y2);
		p3.setTo(x3, y3);
		p4.setTo(x4, y4);
		
		xmin = min4(p1.x, p2.x, p3.x, p4.x);
		ymin = min4(p1.y, p2.y, p3.y, p4.y);
		xmax = max4(p1.x, p2.x, p3.x, p4.x);
		ymax = max4(p1.y, p2.y, p3.y, p4.y);
		readjustSize(xmax - xmin, ymax - ymin);
		
		vertexData.setPoint(0, "position", p1.x - xmin, p1.y - ymin);
		vertexData.setPoint(1, "position", p2.x - xmin, p2.y - ymin);
		vertexData.setPoint(2, "position", p3.x - xmin, p3.y - ymin);
		vertexData.setPoint(3, "position", p4.x - xmin, p4.y - ymin);
		//onVertexDataChanged();
		x = xmin;
		y = ymin;
		_lowerRight.setTo(xmax - xmin, ymax - ymin);
		
		
	}
	
  private var _lowerRight:Point = new Point(0, 0);
		
	private inline function min4(a:Float, b:Float, c:Float, d:Float):Float {
		return Math.min(a, Math.min(b, Math.min(c, d)));	
	}
		
	private inline function max4(a:Float, b:Float, c:Float, d:Float):Float {
		return Math.max(a, Math.max(b, Math.max(c, d)));	
	}

	public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle{
		if (resultRect == null) resultRect = new Rectangle();
		
		if (targetSpace == this) // optimization
		{
				resultRect.setTo(0.0, 0.0, _lowerRight.x, _lowerRight.y);
		}
		else if (targetSpace == parent && rotation == 0.0) // optimization
		{
				var scaleX:Float = this.scaleX;
				var scaleY:Float = this.scaleY;
				resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
												 _lowerRight.x * scaleX, _lowerRight.y * scaleY);
				if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
				if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
		}
		else {
				resultRect = super.getBounds(targetSpace, resultRect);
		}

		return resultRect;
	}
}
