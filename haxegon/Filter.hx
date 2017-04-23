package haxegon;

import haxegon.filters.*;
import starling.filters.*;

@:access(haxegon.Gfx)
class Filter {
	/* Turn all filter effects off */
	public static function reset() {
	  Gfx.screen.filter = null;
		
		_blur = false;
		_bloom = 0;
	}
	
	public static var blur(get, set):Bool;
	private static var _blur:Bool;
	private static var blurfilter:BlurFilter;
	static function get_blur():Bool { return _blur; }
	static function set_blur(_b:Bool):Bool {
		_blur = _b;
		updatefilters();
		
	  return _blur;
	}
	
	public static var bloom(get, set):Float;
	private static var _bloom:Float;
	private static var bloomfilter:BloomFilter;
	static function get_bloom():Float { return _bloom; }
	static function set_bloom(_b:Float):Float {
		_bloom = _b;
		updatefilters();
		
	  return _bloom;
	}
	
	private static function init() {
		_blur = false; blurfilter = new BlurFilter();
		_bloom = 0;    bloomfilter = new BloomFilter();
		
		reset();
	}
	
	private static function updatefilters() {
	  //When a filter changes, call this function internally to update the currently active filter	
		Gfx.screen.filter = null;
		
		//Currently only one filter at a time is supported!
		if (_blur) {
		  Gfx.screen.filter = blurfilter;
			return;
		}
		
		if (_bloom > 0) {
			bloomfilter.red = (_bloom / 2) + 0.5;
			bloomfilter.green = (_bloom / 2) + 0.5;
			bloomfilter.blue = (_bloom / 2) + 0.5;
			bloomfilter.blur = Geom.clamp((_bloom + 0.5) * 2, 0, 2.5);
			
			Gfx.screen.filter = bloomfilter;
			return;
		}
	}
}	