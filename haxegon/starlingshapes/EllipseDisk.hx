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

/** A Disk represents a circle filled with a uniform color. */
class EllipseDisk extends EllipseRing
{
	public function new(xoff:Float, yoff:Float, xradius:Float, yradius:Float, color:Int = 0xffffff, alpha:Float = 1.0, nsides:Int = -1, ?startangle:Float){
		super(xoff, yoff, 0, 0, xradius, yradius, color, alpha, nsides, startangle);
	}
}
