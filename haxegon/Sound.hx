package haxegon;

import openfl.media.*;
import openfl.events.*;

@:access(haxegon.Sound)
class HaxegonChannel{
	public function new(){
		free = true;
		fading = 0;
	}
	
	public function setto(_soundname:String, _offsettime:Float = 0, _fadeintime:Float = 0, _loop:Bool = false, _volume:Float = 1, _panning:Float = 0){
		free = false;
		fading = 0;
		soundname = _soundname;
		offsettime = _offsettime;
		fadeintime = _fadeintime;
		panning = _panning;
		looping = _loop;
		volume = _volume;
		
		play(soundname, offsettime, fadeintime, volume, panning);
		channel.addEventListener(Event.SOUND_COMPLETE, oncomplete);
	}
	
	public function play(_soundname:String, _offsettime:Float = 0, _fadeintime:Float = 0, _volume:Float = 1, _panning:Float = 0){
		var s:HaxegonSound = haxegon.Sound.soundfile[haxegon.Sound.soundindex.get(_soundname)];
		channel = s.asset.play(_offsettime * 1000);
		
		if (_fadeintime <= 0){
			channel.soundTransform = new SoundTransform(Geom.clamp(volume * haxegon.Sound._mastervolume, 0, 1), Geom.clamp(_panning, -1, 1));	
		}else{
			fading = -11;
			fadestarttime = flash.Lib.getTimer();
			fadeendtime = fadestarttime + (_fadeintime * 1000);
			changevolume(0);
			
			channel.soundTransform = new SoundTransform(Geom.clamp(volume * haxegon.Sound._mastervolume, 0, 1), Geom.clamp(_panning, -1, 1));			
		}
	}
	
	public function oncomplete(e:Event){
		if (looping){
			play(soundname, 0, 0, volume, panning);
			channel.addEventListener(Event.SOUND_COMPLETE, oncomplete);
		}else{
			free = true;
		}
	}
	
	public function changevolume(newvol:Float){
		volume = newvol;
		channel.soundTransform = new SoundTransform(Geom.clamp(volume * haxegon.Sound._mastervolume, 0, 1), Geom.clamp(panning, -1, 1));	
	}
	
	public function stop(fadeout:Float = 0){
		if(fadeout <= 0){
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, oncomplete);
			free = true;
			fading = 0;
		}else{
			fading = 1;
			fadestarttime = flash.Lib.getTimer();
			fadeendtime = fadestarttime + (fadeout * 1000);
		}
	}
	
	public function updatefade(){
		if (fading != 0){
			var now:Float = flash.Lib.getTimer();
			var newvol:Float = ((fadeendtime - fadestarttime) - (now - fadestarttime)) / (fadeendtime - fadestarttime);
			changevolume((fading == 1)?newvol:(1 - newvol));
			
			if (now >= fadeendtime){
				if(fading == 1){
					stop();
				}else{
					fading = 0;
				}
			}
		}
	}
	
	public var soundname:String;
	public var offsettime:Float;
	public var fadeintime:Float;
	public var panning:Float;
	public var volume:Float;
	public var looping:Bool;
	public var channel:SoundChannel;
	
	public var fadestarttime:Float;
	public var fadeendtime:Float;
	
	public var fading:Int;
	public var free:Bool;
}

class HaxegonSound{
	public function new(_s:openfl.media.Sound, _vol:Float){
		asset = _s;
		defaultvolume = _vol;
	}
	
	public var defaultvolume:Float;
	public var asset:openfl.media.Sound;
}

@:access(haxegon.Data)
@:access(haxegon.Music)
class Sound{
	public static function load(soundname:String, defaultvolume:Float = 1.0):Bool{
		soundname = soundname.toLowerCase();
		
		if (!soundindex.exists(soundname)){
			var soundasset:openfl.media.Sound = null;
			#if flash
			#else
			if (Data.assetexists("data/audio/" + soundname + ".ogg")) {
				soundasset = Data.getsoundasset("data/audio/" + soundname + ".ogg"); 
			}else {
				//To do: proper file checks and instructions on what to do on each platform:
				//e.g. on flash, say that you can't find the mp3 or wav. If we CAN detect the .ogg, give a warning about needing to convert the file
				//ditto for every other platform
				Debug.log("ERROR: In Sound.load(), cannot find \"data/audio/" + soundname + ".ogg\". (.ogg files are required on this platform.)"); 
				return false;
			}
			#end
			
			if (soundasset != null){
				soundfile.push(new HaxegonSound(soundasset, defaultvolume));
				soundindex.set(soundname, soundfile.length - 1); 
			}
		}
		
		return true;
	}
	
	public static function play(soundname:String, offsettime:Float = 0, fadeintime:Float = 0, loop:Bool = false, panning:Float = 0){
		soundname = soundname.toLowerCase();
		if (!soundindex.exists(soundname)) {
			if (!load(soundname)) return;
		}
		
		var freechannel:Int = -1;
		for (i in 0 ... channel.length){
			if (channel[i].free){
				freechannel = i;
				break;
			}
		}
		
		if (freechannel == -1){
			var h:HaxegonChannel = new HaxegonChannel();
			h.setto(soundname, offsettime, fadeintime, loop, soundfile[soundindex.get(soundname)].defaultvolume, panning);
			channel.push(h);
		}else{
			channel[freechannel].setto(soundname, offsettime, fadeintime, loop, soundfile[soundindex.get(soundname)].defaultvolume, panning);
		}
		
	}
	
	public static function stop(soundname:String = "", fadeout:Float = 0){
		soundname = soundname.toLowerCase();
		
		for (i in 0 ... channel.length){
			if (soundname == "" || channel[i].soundname == soundname){
				channel[i].stop(fadeout);
			}
		}
	}
	
	public static var typingsound:String = "";
	
	public static var mastervolume(get, set):Float;
	private static var _mastervolume:Float = 1.0;
	static function get_mastervolume():Float {
	  return _mastervolume;	
	}
	
	static function set_mastervolume(vol:Float):Float{
		_mastervolume = vol;
		
		return _mastervolume;
	}
	
	private static function init(){
		Music.crossfade = true;
		Music._currentsong = "";
		
		typingsound = "";
		_mastervolume = 1.0;
		
		soundfile = [];
		soundindex = new Map<String, Int>();
		channel = [];
	}
	
	private static function update(){
		for (i in 0 ... channel.length){
			if (channel[i].fading != 0){
				channel[i].updatefade();
			}
		}
	}
	
	private static var soundfile:Array<HaxegonSound>;
	private static var channel:Array<HaxegonChannel>;
	private static var soundindex:Map<String, Int>;
}