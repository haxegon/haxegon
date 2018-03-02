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
			fading = -1; fadevolume = _volume;
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
	
	public function changepan(newpan:Float){
		panning = newpan;
		channel.soundTransform = new SoundTransform(Geom.clamp(volume * haxegon.Sound._mastervolume, 0, 1), Geom.clamp(panning, -1, 1));
	}
	
	public var position(get, set):Float;
	private var _position:Float;
	function get_position():Float {
		if (free){
			return 0;
		}else{
			return channel.position / 1000;
		}
	}
	
	function set_position(newposition:Float):Float {
		if (!free){
			_position = newposition * 1000;
			#if flash
			stop();
			play(soundname, newposition, 0, volume, panning);
			#else
			channel.position = _position;
			#end
		}
		return _position;
	}
	
	public var length(get, null):Float;
	private var _length:Float;
	function get_length():Float {
		if (free){
			return 0;
		}else{
			return haxegon.Sound.soundfile[haxegon.Sound.soundindex.get(soundname)].asset.length / 1000;
		}
		return 0;
	}
	
	public function stop(fadeout:Float = 0){
		if(fadeout <= 0){
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, oncomplete);
			free = true;
			fading = 0;
		}else{
			fading = 1; fadevolume = volume;
			fadestarttime = flash.Lib.getTimer();
			fadeendtime = fadestarttime + (fadeout * 1000);
		}
	}
	
	public function updatefade(){
		if (fading != 0){
			var now:Float = flash.Lib.getTimer();
			var newvol:Float = ((fadeendtime - fadestarttime) - (now - fadestarttime)) / (fadeendtime - fadestarttime);
			changevolume((fading == 1)?newvol * fadevolume:((1 - newvol) * fadevolume));
			
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
	public var fadevolume:Float;
	
	public var fading:Int;
	public var free:Bool;
}

class HaxegonSound{
	public function new(_s:openfl.media.Sound, _vol:Float){
		asset = _s;
		adjustedvolume = _vol;
	}
	
	public var adjustedvolume:Float;
	public var asset:openfl.media.Sound;
}

@:access(haxegon.Data)
@:access(haxegon.Music)
class Sound{
	public static function load(soundname:String, adjustvolume:Float = 1.0):Bool{
		soundname = soundname.toLowerCase();
		
		if (!soundindex.exists(soundname)){
			var soundasset:openfl.media.Sound = null;
			#if flash
			if (Data.assetexists("data/sounds/" + soundname + ".mp3")) {
				soundasset = Data.getsoundasset("data/sounds/" + soundname + ".mp3"); 
			}else if (Data.assetexists("data/sounds/" + soundname + ".wav")) {
				soundasset = Data.getsoundasset("data/sounds/" + soundname + ".wav"); 
			}else{
				Debug.log("ERROR: In Sound.load(), cannot find \"data/sounds/" + soundname + ".mp3\" or \"data/sounds/" + soundname + ".wav\". (either .mp3 or .wav files are required for flash.)");
				return false;
			}
			#elseif (cpp || neko)
			if (Data.assetexists("data/sounds/" + soundname + ".ogg")) {
				soundasset = Data.getsoundasset("data/sounds/" + soundname + ".ogg"); 
			}else if (Data.assetexists("data/sounds/" + soundname + ".wav")) {
				soundasset = Data.getsoundasset("data/sounds/" + soundname + ".wav"); 
			}else {
				Debug.log("ERROR: In Sound.load(), cannot find \"data/sounds/" + soundname + ".ogg\" or \"data/sounds/" + soundname + ".wav\". (either .ogg or .wav files are required for native builds.)");
				return false;
			}
			#else
			if (Data.assetexists("data/sounds/" + soundname + ".mp3")) {
				soundasset = Data.getsoundasset("data/sounds/" + soundname + ".mp3"); 
			}else	if (Data.assetexists("data/sounds/" + soundname + ".ogg")) {
				soundasset = Data.getsoundasset("data/sounds/" + soundname + ".ogg"); 
			}else if (Data.assetexists("data/sounds/" + soundname + ".wav")) {
				soundasset = Data.getsoundasset("data/sounds/" + soundname + ".wav"); 
			}else {
				Debug.log("ERROR: In Sound.load(), cannot find \"data/sounds/" + soundname + ".mp3\", \"data/sounds/" + soundname + ".ogg\" or \"data/sounds/" + soundname + ".wav\".");
				return false;
			}
			#end
			
			if (soundasset != null){
				soundfile.push(new HaxegonSound(soundasset, adjustvolume));
				soundindex.set(soundname, soundfile.length - 1); 
			}
		}
		
		return true;
	}
	
	public static function offset(soundname:String, offsettime:Float = 0){
		soundname = soundname.toLowerCase();
		offsetindex.set(soundname, offsettime);
	}
	
	public static function play(soundname:String, fadeintime:Float = 0, loop:Bool = false, volume:Float = 1.0, panning:Float = 0){
		soundname = soundname.toLowerCase();
		if (!soundindex.exists(soundname)) {
			if (!load(soundname)) return;
		}
		
		var offsettime:Float = 0;
		if (offsetindex.exists(soundname)){
			offsettime = offsetindex.get(soundname);
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
			h.setto(soundname, offsettime, fadeintime, loop, volume * soundfile[soundindex.get(soundname)].adjustedvolume, panning);
			channel.push(h);
		}else{
			channel[freechannel].setto(soundname, offsettime, fadeintime, loop, volume * soundfile[soundindex.get(soundname)].adjustedvolume, panning);
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
		
		for (i in 0 ... channel.length){
			channel[i].changevolume(channel[i].volume);
		}
		
		return _mastervolume;
	}
	
	public static function length(soundname:String):Float {
		soundname = soundname.toLowerCase();
		
		if (haxegon.Sound.soundindex.exists(soundname)){
			return haxegon.Sound.soundfile[haxegon.Sound.soundindex.get(soundname)].asset.length / 1000;
		}else{
			return 0;
		}
	}
	
	private static function init(){
		Music.crossfade = 0;
		Music._currentsong = "";
		
		typingsound = "";
		_mastervolume = 1.0;
		
		soundfile = [];
		soundindex = new Map<String, Int>();
		offsetindex = new Map<String, Float>();
		channel = [];
	}
	
	private static function update(){
		for (i in 0 ... channel.length){
			if (channel[i].fading != 0){
				channel[i].updatefade();
			}
		}
	}
	
	private static function isplaying(soundname:String):Bool{
		for (i in 0 ... channel.length){
			if (!channel[i].free){
				if (channel[i].soundname == soundname) return true;
			}
		}
		return false;
	}
	
	private static var soundfile:Array<HaxegonSound>;
	private static var channel:Array<HaxegonChannel>;
	private static var soundindex:Map<String, Int>;
	private static var offsetindex:Map<String, Float>;
}