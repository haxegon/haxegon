// =================================================================================================
//
//	ported to haxe from https://github.com/StarlingGraphics/Starling-Extension-Graphics
//  by @terrycavanagh 
//
// =================================================================================================
package starling.textures;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Matrix;
import starling.textures.Texture;
	
class GradientTexture {
	static public function create(width:Float, height:Float, type:String, colors:Array<UInt>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Float = 0):Texture {
		var shape:Shape = new Shape();
		shape.graphics.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio );
		shape.graphics.drawRect(0, 0, width, height);
		
		var bitmapData:BitmapData = new BitmapData(width, height, true);
		bitmapData.draw(shape);
		
		return Texture.fromBitmapData(bitmapData);
	}
}