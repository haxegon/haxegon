package haxegon;

import flash.events.MouseEvent;
import haxe.Constraints.Function;
import haxe.Timer;
import lime.ui.Window;
import starling.events.*;
import starling.display.*;
import starling.core.Starling;
import starling.core.StatsDisplay;

@:access(Main)
@:access(haxegon.Data)
@:access(haxegon.Gfx)
@:access(haxegon.Text)
@:access(haxegon.Sound)
@:access(haxegon.Mouse)
@:access(haxegon.Input)
@:access(haxegon.Scene)
@:access(haxegon.Debug)
class Core extends Sprite {
	public static inline var version:String = "0.12.0";
	private static var installedplugins:Map<String, String>;
	
	private static inline var WINDOW_WIDTH:String = haxe.macro.Compiler.getDefine("windowwidth");
	private static inline var WINDOW_HEIGHT:String = haxe.macro.Compiler.getDefine("windowheight");
	
	public function new() {
		_fps = TARGETFRAMERATE = Math.round(Starling.current.nativeStage.frameRate);
		
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedtostage);
	}
	
	private static function registerplugin(pluginname:String, pluginversion:String){
		if (installedplugins == null){
			installedplugins = new Map<String, String>();
		}
		
		if (installedplugins.exists(pluginname)){
			throw("Error: Trying to register plugin \"" + pluginname + "\", but there is already a registered plugin with that name.");
		}else{
			installedplugins.set(pluginname, pluginversion);
		}
	}
	
	private static function checkrequirement(currentplugin:String, requiredplugin:String, requiredversion:String){
		currentplugin = currentplugin.toLowerCase();
		requiredplugin = requiredplugin.toLowerCase();
		var requiredmajor:Int = Std.parseInt(S.getroot(requiredversion, "."));
		var requiredminor:Int = Std.parseInt(S.getroot(S.getbranch(requiredversion, "."), "."));
		var requiredbugfix:Int = Std.parseInt(S.getlastbranch(requiredversion, "."));
		
		if (requiredplugin == "haxegon"){
			var haxegonmajor:Int = Std.parseInt(S.getroot(version, "."));
			var haxegonminor:Int = Std.parseInt(S.getroot(S.getbranch(version, "."), "."));
			var haxegonbugfix:Int = Std.parseInt(S.getlastbranch(version, "."));
			
			if (haxegonmajor >= requiredmajor){
				if (haxegonminor >= requiredminor){
					if (haxegonbugfix >= requiredbugfix){
						//Everything's ok!
						return;
					}
				}
			}
			
			throw("Error: \"" + currentplugin + "\" plugin requires at least version " + requiredversion 
			    + " of Haxegon, but this is version " + version 
					+ ". Please update your current version of haxegon to use this plugin!");
		}else {
			if (installedplugins.exists(requiredplugin)){
				var pluginversion:String = installedplugins.get(requiredplugin);
				var pluginmajor:Int = Std.parseInt(S.getroot(pluginversion, "."));
				var pluginminor:Int = Std.parseInt(S.getroot(S.getbranch(pluginversion, "."), "."));
				var pluginbugfix:Int = Std.parseInt(S.getlastbranch(pluginversion, "."));
				
				if (pluginmajor >= requiredmajor){
					if (pluginminor >= requiredminor){
						if (pluginbugfix >= requiredbugfix){
							//Everything's ok!
							return;
						}
					}
				}
				
				throw("Error: \"" + currentplugin + "\" plugin requires at least version " + requiredversion 
						+ " of \"" + requiredplugin + "\", but this is version " + pluginversion 
						+ ". Please update your current version of \"" + requiredplugin + "\" to use this plugin!");
			}else{
				throw("Error: \"" + currentplugin + "\" plugin requires the plugin \"" + requiredplugin 
			    + "\" to work correctly. If this plugin is installed, try to .enable() it first!");
			}
		}
	}
	
	private function addedtostage(e:Event = null) {
		removeEventListener(Event.ADDED_TO_STAGE, addedtostage);
		loaded();
	}
	
	public static function delaycall(f:Function, time:Float) {
	  Timer.delay(function() { f(); }, Std.int(time * 1000));	
	}
	
	private function loaded() {
		#if js
		untyped {
			document.oncontextmenu = document.body.oncontextmenu = function() {return false;}
		}
		#end
		//Init library classes
		Random.seed = 0;
		Input.init(this.stage, Starling.current.nativeStage);
		Mouse.init(this.stage, Starling.current.nativeStage);
		Data.initassets();
		Debug.init();
		Gfx.init(this.stage, Starling.current.nativeStage);
		Text.init();
		Text.defaultfont();
		Sound.init();
		
		//Create a fullscreen button region
		flash.Lib.current.stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){
			if(_fullscreenbutton){
				if (Geom.inbox(
					Gfx.getscreenx(flash.Lib.current.mouseX), Gfx.getscreeny(flash.Lib.current.mouseY),
					_fullscreenbuttonx, _fullscreenbuttony, _fullscreenbuttonw, _fullscreenbuttonh)){
					if (flash.Lib.current.stage.displayState == openfl.display.StageDisplayState.NORMAL){
						flash.Lib.current.stage.displayState = openfl.display.StageDisplayState.FULL_SCREEN_INTERACTIVE;
						Gfx._fullscreen = true;
					}else{
						flash.Lib.current.stage.displayState = openfl.display.StageDisplayState.NORMAL;
						Gfx._fullscreen = false;
					}
				}
			}
		});
		
		//Before we call Scene.init(), make sure we have some init values for our screen
		//in the event that we don't create one in Main.new():
		Gfx.screenwidth = Std.int(Std.parseInt(WINDOW_WIDTH));
		Gfx.screenheight = Std.int(Std.parseInt(WINDOW_HEIGHT));
		Gfx.screenwidthmid = Std.int(Gfx.screenwidth / 2); Gfx.screenheightmid = Std.int(Gfx.screenheight / 2);
		
		//Some stuff mysteriouly doesn't work correctly unless we wait for a millisecond first!
		Gfx.startframe();
		Timer.delay(continueloading, 1);
	}
	
  private function continueloading() {
		//Call Main.init()
		Scene.init();
		
		//Did Main.new() already call Gfx.resizescreen? Then we can skip this! Otherwise...
		if (!Gfx.gfxinit) {
			Gfx.resizescreen(Std.parseInt(WINDOW_WIDTH), Std.parseInt(WINDOW_HEIGHT));
			if (Gfx.fullscreen) {
				Gfx.fullscreen = true;
			}else {
				Gfx.fullscreen = false;	
			}
		}else {
			if (Gfx.fullscreen) {
				Gfx.fullscreen = true;
			}else {
				Gfx.fullscreen = false;	
			}
		}
		
		Gfx.endframe();
		
		// start game loop
		_rate3 = Math.round(3000 / TARGETFRAMERATE);
		_target3 = 3 * flash.Lib.getTimer() + _rate3;
		
		starttime = flash.Lib.getTimer();
    stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:Event) {
		if (!Scene.hasseperaterenderfunction) {
			//If we don't have a seperate render function, just fall back to onEnterFrame for now
			execute_extendedstartframe();
			doupdate(0, 1);
		  return;	
		}
		
		// Ready the time!
		// "_time3", "_target3" and "_rate3" all work in thirds of a millisecond. This is because
		// frame times use even thirds (30fps = 33 1/3 ms, 60fps = 16 2/3ms) and we want to track
		// them accurately, so we can't use floating point (which would start to lose precision 
		// after an hour or so).
		//
		// Keep this in mind when working with these values. Divide them by 3 to get milliseconds.
		var _time3:Int = 3 * flash.Lib.getTimer();
		
		// Frames too fast? If we got here too soon, quit now and come back next time.
		// This uses a 0.5 frame offset because we want the hard boundaries that decide frameskip/
		// delay to be as far as possible from our regular frame timings. This way, our game needs
		// to move an entire half a frame off course in either direction before it stutters.
		if (_time3 < _target3 - 0.5*_rate3) {
			return;
		}
		
		execute_extendedstartframe();
		
		// How many updates do we want?
		// Again, this uses a 0.5 frame offset before triggering frameskip.
		var frameupdates:Int = Math.ceil(Math.max(1.0, (_time3 - _target3 + 0.5 * _rate3) / _rate3));
		if (frameupdates > MAXFRAMESKIP) {
			_target3 += _rate3 * (frameupdates - MAXFRAMESKIP);
			frameupdates = MAXFRAMESKIP;
		}
		
		if (!frameskip) {
			frameupdates = 1;
		}
		
		if (frameupdates == 1) {
			// TIME TWEAK: That 0.5 frame offset only helps smoothness if we can line up _target
			// with our regular frame times from OpenFL. This does that, by sliding _target backwards
			// and forwards as necessary.
			// Sliding by 1/3 ms per frame amounts to a 1% timeslip; 30fps becomes 29.7 - 30.3fps.
			// Barely noticeable, and OpenFL will be feeding us a solid 30 most of the time anyway.
			if (_target3 - _time3 > 0.1*_rate3) {
				_target3 -= 1;
			} else if (_target3 - _time3 < -0.1*_rate3) {
				_target3 += 1;
			}
		}

		// Run our frames!
		for (upd in 0 ... frameupdates) {
			_target3 += _rate3;
			
			// update loop
			doupdate(upd, frameupdates);
		}
		
		// render loop
		dorender();
	}
	
	public static function mobilebrowser():Bool{
		#if html5
		return S.isinstring(js.Browser.navigator.userAgent, "Mobi");
		#else
		return false;
		#end
	}

	private static var currentupdateindex:Int;
	private static var currentupdatecount:Int;
	private function doupdate(updateindex:Int, updatecount:Int) {
		Mouse.update(Gfx.getscreenx(flash.Lib.current.mouseX), Gfx.getscreeny(flash.Lib.current.mouseY), updateindex == 0);
		Input.update();
		
		if (!Scene.hasseperaterenderfunction) {
			Gfx.startframe();
			
			Debug.update();
			Scene.update();
			Debug.render();
			
			if (hasextended_afterupdatebeforerender) {
				currentupdateindex = updateindex;
				currentupdatecount = updatecount;
				execute_extendedafterupdatebeforerender();
			}
			
			execute_extendedendframe();
			
			Gfx.endframe();
		}else {
			Debug.update();
		  Scene.update();	
			Debug.render();
			
			if (hasextended_afterupdatebeforerender) {
				currentupdateindex = updateindex;
				currentupdatecount = updatecount;
				execute_extendedafterupdatebeforerender();
			}
		}
		
		Sound.update();
	}
	
	private function dorender() {
		Gfx.startframe();
		
		Scene.render();
		Debug.render();
		execute_extendedendframe();
		
		Gfx.endframe();
	}
	
	public static function fullscreenbutton(?x:Float, ?y:Float, ?width:Float, ?height:Float){
		if (x == null || y == null || width == null || height == null){
			_fullscreenbutton = false;
		}else{
			_fullscreenbuttonx = x;
			_fullscreenbuttony = y;
			_fullscreenbuttonw = width;
			_fullscreenbuttonh = height;
		  _fullscreenbutton = true;
		}
	}
	
	
	private static var _fullscreenbutton:Bool = false;
	private static var _fullscreenbuttonx:Float = 0;
	private static var _fullscreenbuttony:Float = 0;
	private static var _fullscreenbuttonw:Float = 0;
	private static var _fullscreenbuttonh:Float = 0;
	
	public static var fps(get,set):Int;
	private static var _fps:Int;
	
	static function get_fps():Int {
		return _fps;
	}

	static function set_fps(_newfps:Int) {
		Starling.current.nativeStage.frameRate = _newfps;
		TARGETFRAMERATE = _newfps;
		return _newfps;
	}
	
	private static function extend_startframe(?f:Function) {
		hasextended_startframe = true;
		extended_startframe.push(f);
	}
	private static function execute_extendedstartframe(){
		if (hasextended_startframe){
			for (f in extended_startframe) f();
		}
	}
	private static var extended_startframe:Array<Dynamic> = [];
	private static var hasextended_startframe:Bool = false;
	
	private static function extend_afterupdatebeforerender(?f:Function) {
		hasextended_afterupdatebeforerender = true;
		extended_afterupdatebeforerender.push(f);
	}
	private static function execute_extendedafterupdatebeforerender(){
		if (hasextended_afterupdatebeforerender){
			for (f in extended_afterupdatebeforerender) f();
		}
	}
	private static var extended_afterupdatebeforerender:Array<Dynamic> = [];
	private static var hasextended_afterupdatebeforerender:Bool = false;
	
	private static function extend_endframe(?f:Function) {
		hasextended_endframe = true;
		extended_endframe.push(f);
	}
	private static function execute_extendedendframe(){
		if (hasextended_endframe){
			for (f in extended_endframe) f();
		}
	}
	private static var extended_endframe:Array<Dynamic> = [];
	private static var hasextended_endframe:Bool = false;
	
	// Timing information.
	private static var TARGETFRAMERATE:Int = 60;
	private static inline var MAXFRAMESKIP:Int = 4;
	public static var frameskip:Bool = false;
	
	private static var	_rate3:Int; // The time between frames, in thirds of a millisecond.
	private static var _target3:Int; // The ideal time to start the next frame, in thirds of a millisecond.
	private static var starttime:Int;
	
	public static var time(get, set):Float;
	static function get_time():Float {
	  return (flash.Lib.getTimer() - starttime) / 1000;
	}
	
	static function set_time(t:Float):Float {
		starttime = Std.int(flash.Lib.getTimer() - (t * 1000));
		return flash.Lib.getTimer() - starttime;
	}
	public static var showstats(get,set):Bool;
	private static var _showstats:Bool;
	private static var statsdisplay:StatsDisplay;

	static function get_showstats():Bool {
		return _showstats;
	}

	static function set_showstats(_b:Bool) {
		Starling.current.showStats = _b;
		return _b;
	}
	
	public static var window(get, never):Window;
	
	static function get_window():Window {
		#if html5
			Debug.log("ERROR: Core.window is not available in HTML5.");
			return null;
		#elseif flash
			Debug.log("ERROR: Core.window is not available in Flash.");
			return null;
		#else
		return flash.Lib.application.window;
		#end
	}

	public static function quit(?code:Int) {
		#if html5
			Debug.log("ERROR: Core.quit() has no effect in HTML5.");
		#elseif flash
			Debug.log("ERROR: Core.quit() has no effect in Flash.");
		#else
		  if (code == null) {
			  Sys.exit(0);
			}else{
				Sys.exit(code);
			}
		#end
	}
}