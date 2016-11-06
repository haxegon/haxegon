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

/** A Disk represents a circle filled with a uniform color. */
class Disk extends Ring
{
	public function new(radius:Float, color:Int = 0xffffff, premultipliedAlpha:Bool = true, nsides:Int = -1, ?startangle:Float){
		super(0, radius, color, premultipliedAlpha, nsides, startangle);
	}
}
