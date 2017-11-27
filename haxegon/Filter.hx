package haxegon;

import haxegon.filters.*;
import starling.filters.*;

@:access(haxegon.Gfx)
class Filter {
	/* Turn all filter effects off */
	public static function reset() {
		if(Gfx.screen != null) Gfx.screen.filter = null;
		
		_blur = 0;
		_bloom = 0;
	}
	
	public static var blur(get, set):Float;
	private static var _blur:Float;
	static function get_blur():Float { return _blur; }
	static function set_blur(_b:Float):Float {
		_blur = _b;
		updatefilters();
		
	  return _blur;
	}
	
	public static var bloom(get, set):Float;
	private static var _bloom:Float;
	private static var bloomfilter:Bloomfilter;
	static function get_bloom():Float { return _bloom; }
	static function set_bloom(_b:Float):Float {
		_bloom = _b;
		updatefilters();
		
	  return _bloom;
	}
	
	private static function init() {
		_blur = 0;
		_bloom = 0;
		bloomfilter = new Bloomfilter();
		
		reset();
	}
	
	private static function updatefilters() {
	  //When a filter changes, call this function internally to update the currently active filter	
		if (Gfx.screen != null){
			Gfx.screen.filter = null;
			
			if (_bloom > 0) {
				bloomfilter.red = (_bloom / 2) + 0.5;
				bloomfilter.green = (_bloom / 2) + 0.5;
				bloomfilter.blue = (_bloom / 2) + 0.5;
				bloomfilter.blur = Geom.clamp((_bloom + 0.5) * 2, 0, 2.5) + _blur;
				
				Gfx.screen.filter = bloomfilter;
				return;
			}
			
			//Currently only one filter at a time is supported, but since we only have blur and bloom
			//for now we can just set it up to use bloom's build in blur instead
			if (_blur > 0) {
				bloomfilter.red = 0.5;
				bloomfilter.green = 0.5;
				bloomfilter.blue = 0.5;
				bloomfilter.blur = _blur;
				
				Gfx.screen.filter = bloomfilter;
				return;
			}
		}
	}
}	