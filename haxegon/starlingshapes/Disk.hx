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
class Disk extends Ring
{
	public function new(xoff:Float, yoff:Float, radius:Float, color:Int = 0xffffff, alpha:Float = 1.0, nsides:Int = -1, ?startangle:Float){
		super(xoff, yoff, 0, radius, color, alpha, nsides, startangle);
	}
}
