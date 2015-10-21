package haxegon;

import haxe.Timer;
import openfl.display.*;
import openfl.events.*;
import openfl.Lib;

@:access(Main)
@:access(haxegon.Gfx)
@:access(haxegon.Music)
@:access(haxegon.Mouse)
@:access(haxegon.Input)
@:access(haxegon.Scene)
class Core extends Sprite {
	public function new() {
		super();
		
		Gfx.initrun = true;
		#if haxegonweb
		Webscript.corecontrol = this;
		#end
		init();
	}
	
	public function init() {
		maxelapsed = 0.0333;
		maxframeskip = 5;
		tickrate = 20;
		_delta = 0;
		
		// on-stage event listener
		if (Gfx.initrun) {
			addEventListener(Event.ADDED_TO_STAGE, addedtostage);
			Lib.current.addChild(this);
		}else {
			loaded();
		}
	}
	
	private function addedtostage(e:Event = null) {
		removeEventListener(Event.ADDED_TO_STAGE, addedtostage);
		loaded();
	}
	
	#if haxegonweb
	public function reset() {
	  Random.setseed(Std.int(Math.random() * 233280));
		Gfx.init(this.stage);
		Gfx.resizescreen(240, 150, 1);
		Text.setfont(Webfont.DEFAULT, 1);
		Text.cleartextcache();
		Input.keybuffer = "";
	}
	#end
	
	private function loaded() {
		//Init library classes
		Random.setseed(Std.int(Math.random() * 233280));
		
		if (Gfx.initrun) {
			Input.init(this.stage);
			Mouse.init(this.stage);
		}
		
		Gfx.init(this.stage);
		
		#if haxegonweb
		#else
		Music.init();
		#end
		
		//Default setup
		#if haxegonweb
			Gfx.resizescreen(240, 150, 1);
			Text.setfont("default", 1);
			Text.cleartextcache();
			Input.keybuffer = "";
		#else
			Gfx.resizescreen(768, 480);
			Text.setfont("opensans", 24);
		#end
		
		#if haxegonweb
		if (Gfx.initrun) {
			if (haxegonmain == null) haxegonmain = new Main();
		}
		#else
		Scene.init();
		#end
		
		// start game loop
		_rate = 1000 / TARGETFRAMERATE;
    // fixed framerate
    _skip = _rate * (maxframeskip + 1);
    _last = _prev = Lib.getTimer();
		if(_timer != null) _timer.stop();
    _timer = new Timer(tickrate);
    _timer.run = ontimer;
		Gfx.update_fps = 0;
		Gfx.render_fps = 0;
		_framesthissecond_counter = -1;
		
		Gfx.initrun = false;
	}
	
	private function ontimer(){
		Gfx.skiprender = false;
		_skipedupdate = 0;
		
		// update timer
		_time = Lib.getTimer();
		_delta += (_time - _last);
		_last = _time;
		
		if (_framesthissecond_counter == -1) {
			_framesthissecond_counter = _time;
		}
		
		// quit if a frame hasn't passed
		if (_delta < _rate) return;
		
		// update timer
		_gametime = Std.int(_time);
		
		// update loop
		if (_delta > _skip) _delta = _skip;
		while (_delta >= _rate) {
			//HXP.elapsed = _rate * HXP.rate * 0.001;
			// update timer
			_updatetime = _time;
			_delta -= _rate;
			_prev = _time;
			
			// update loop
			if (Gfx.clearscreeneachframe) Gfx.skiprender = true;
			_skipedupdate++; //Skip one update now; we catch it later at render
			if (_skipedupdate > 1) doupdate();
			
			// update timer
			_time = Lib.getTimer();
		}
		
		// update timer
		_rendertime = _time;
		
		// render loop
		Gfx.skiprender = false;	doupdate();
		Gfx.render_fps++;
		
		if (_rendertime-_framesthissecond_counter > 1000) {
			//trace("Update calls: " + Gfx.update_fps +", Render calls: " + Gfx.render_fps);
			_framesthissecond_counter = Lib.getTimer();
			Gfx.update_fps_max = Gfx.update_fps;
			Gfx.render_fps_max = Gfx.render_fps;
			Gfx.render_fps = 0;
			Gfx.update_fps = 0;
		}
		
		// update timer
		_time = Lib.getTimer();
	}
	
	public function doupdate() {
		Gfx.update_fps++;
		Mouse.update(Std.int(Lib.current.mouseX / Gfx.screenscale), Std.int(Lib.current.mouseY / Gfx.screenscale));
		Input.update();
		
		if (!Gfx.skiprender) {
			Gfx.drawto.lock();			
			if (Gfx.clearscreeneachframe) Gfx.clearscreen();
		}
		#if haxegonweb
		haxegonmain.update();
		#else
		Scene.update();
		#end
		if(!Gfx.skiprender) {
			Text.drawstringinput();
			Debug.showlog();
			
			Gfx.drawto.unlock();
		}
		
		Mouse.mousewheel = 0;
	}
	
	#if haxegonweb
	public var haxegonmain:Main; //No scene control in online version
	#end
	
	//NEW FRAMERATE CODE - From HaxePunk fixed FPS implementation
	private var maxelapsed:Float;
	private var maxframeskip:Int;
	private var tickrate:Int;
	
	// Timing information.
	private var TARGETFRAMERATE:Int = 30;
	private var _delta:Float;
	private var _time:Float;
	private var _last:Float;
	private var _timer:Timer;
	private var	_rate:Float;
	private var	_skip:Float;
	private var _prev:Float;
	private var _skipedupdate:Int;

	// Debug timing information.
	private var _updatetime:Float;
	private var _rendertime:Float;
	private var _gametime:Float;
	private var _framesthissecond_counter:Float;
}