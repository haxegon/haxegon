package terrylib;
	
import terrylib.util.*;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import openfl.text.*;
import openfl.Assets;
import openfl.Lib;
import openfl.system.Capabilities;

class Debug {
	/** Clear the debug buffer */
	public static function clearlog():Void {
		debuglog = new Array<String>();
	}
	
	/** Outputs a string to the screen for testing. */
	public static function log(t:String):Void {
		debuglog.push(t);
		test = true;
		if (debuglog.length > 20) {
			debuglog.reverse();
			debuglog.pop();
			debuglog.reverse();
		}
	}
	
	/** Shows a single test string. */
	public static function teststring(t:String):Void {
		debuglog[0] = t;
		test = true;
	}
	
	public static function showlog():Void {
		if (test) {
			for (k in 0 ... debuglog.length) {
				for (j in -1 ... 2) {
					for (i in -1 ... 2) {
						Text.print(2 + i, j + Std.int(2 + ((debuglog.length - 1 - k) * (Text.height() + 2))), debuglog[k], Gfx.RGB(0, 0, 0));
					}
				}
				Text.print(2, Std.int(2 + ((debuglog.length-1-k) * (Text.height() + 2))), debuglog[k], Gfx.RGB(255, 255, 255));
			}
		}
	}
	
	public static var test:Bool;
	public static var debuglog:Array<String> = new Array<String>();
}