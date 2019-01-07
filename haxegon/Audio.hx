package haxegon;

import flash.geom.Point;
import openfl.events.Event;
import openfl.events.EventDispatcher;

private enum Soundfade{
	FADEIN;
	FADEOUT;
	DUCKIN;
	DUCKOUT;
	DUCKED;
	NONE;
}

@:access(Soundfade)
@:access(haxegon.Sound)
@:access(haxegon.Music)
class Audio extends EventDispatcher {

	public static inline var AUDIO_LOOP = "audio_loop";
	public static inline var AUDIO_PLAY = "audio_play";

	public function new(?soundname:String = ""){
		super();
		poolid = -1;
		if (soundname != null){
			attachsound(soundname);
		}else{
			_sound = null;
			_adjustedvolume = 1.0;
		}
		reset();
		
		_free = true;
		
		if(!Sound.addtopool){
			Sound.audiolist.add(this);
		}
	}
	
	private function reset(){
		_soundchannel = null;
		_volume = 1.0;
		_fadedvolume = 1.0;
		_duckedvolume = 1.0;
		_panning = 0;
		_fademode = Soundfade.NONE;
		_duckmode = Soundfade.NONE;
		if (soundoffset != null){
			soundoffset.setTo(0, 0);
		}else{
			soundoffset = new Point(0, 0);
		}
		loop = false;
	}
	
	public function oncomplete(e:Event){
		if (loop){
			play();
			dispatchEvent(new Event (AUDIO_LOOP));
		}else{
			free = true;
		}
	}
	
	private function updatefade():Bool{
		if (_fademode == Soundfade.NONE) return false;
		
		//Update fading
		var now:Float = flash.Lib.getTimer();
		var newvol:Float = ((_fadeendtime - _fadestarttime) - (now - _fadestarttime)) / (_fadeendtime - _fadestarttime);
		_fadedvolume = (_fademode == Soundfade.FADEOUT)?newvol:(1 - newvol);
		
		if (now >= _fadeendtime){
			if(_fademode == Soundfade.FADEOUT){
				stop();
			}else{
				_fadedvolume = 1.0;
				_fademode = Soundfade.NONE;
			}
		}
		
		return true;
	}
	
	private function updateduck():Bool{
		if (_duckmode == Soundfade.NONE) return false;
		
		//Update ducking
		var now:Float = flash.Lib.getTimer();
		
		if (now >= _duckendtime){
			if (_duckmode == Soundfade.DUCKED){
				//_duckedvolume += 0.15;
				//if(_duckedvolume >= 1.0){
					_duckedvolume = 1.0;
					_duckmode = Soundfade.NONE;
				//}
			}
		}
		
		return true;
	}
	
	private function update(){
		if (updatefade() || updateduck()){
			//Update transform
			updatetransform();
		}
	}
	
	private function updatetransform(){
		if (_soundchannel != null){
			_soundchannel.soundTransform = currenttransform();
		}
	}
	
	public function offset(startoffsettime:Float = 0){ // To do: , endoffsettime:Float = 0){
		if (soundoffset != null){
			soundoffset.setTo(startoffsettime, 0); //To do: , endoffsettime);
		}else{
			soundoffset = new Point(startoffsettime, 0); //To do: , endoffsettime);
		}
	}
	
	private function attachsound(soundname:String){
		name = soundname;
		_sound = Sound.soundassets.get(soundname);
		_adjustedvolume = Sound.soundvolumeadjustment.get(soundname);
	}
	
	public function play(_fadeintime:Float = 0){
		if (_sound == null){
			trace("Error: sound asset named \"" + name + "\" not found");
			return;
		}
		if (_soundchannel != null){
			//Immediately stop anything that's playing in this Audio object
			_soundchannel.stop();
		}
		
		if (_fadeintime != 0){
			_fadedvolume = 0.0;
			_fademode = Soundfade.FADEIN;
			_fadestarttime = flash.Lib.getTimer();
			_fadeendtime = _fadestarttime + (_fadeintime * 1000);
		}else{
			_fademode = Soundfade.NONE;
			_fadedvolume = 1.0;
		}
		
		_soundchannel = _sound.play(soundoffset.x * 1000, 0, currenttransform());
		if (Music.autoduck != 1.0 && Music.musicaudio != this && poolid != -1){
			Music.duck(Music.autoduck, length);
		}
		if (_soundchannel != null){
			_soundchannel.addEventListener(Event.SOUND_COMPLETE, oncomplete);
			dispatchEvent(new Event (AUDIO_PLAY));
			free = false;
		}else{
			free = true;
		}
	}
	
	public function stop(fadeout:Float = 0){
		if (fadeout <= 0){
			if(_soundchannel != null){
				_soundchannel.stop();
			}
			
			_fademode = Soundfade.NONE;
			free = true;
		}else{
			_fademode = Soundfade.FADEOUT;
			_fadestarttime = flash.Lib.getTimer();
			_fadeendtime = _fadestarttime + (fadeout * 1000);
		}
	}
	
	public function duck(ducklevel:Float, ducktime:Float){
		if (_duckmode == Soundfade.NONE){
			_duckmode = Soundfade.DUCKED;
			_duckedvolume = Geom.clamp(ducklevel, 0, 1);
			_duckstarttime = flash.Lib.getTimer();
			_duckendtime = _duckstarttime + (ducktime * 1000);
		}else{
			//If we're already ducked, then just extend time
			_duckendtime += (ducktime * 1000);
			_duckedvolume = Geom.clamp(ducklevel, 0, 1);
		}
	}
	
	private function twodigits(f:Float):Float{
		return Math.floor(f * 100) / 100;
	}
	
	public override function toString():String{
		if (!free){
			var returnstring:String = name + " (vol: " + twodigits(_volume * _fadedvolume * _duckedvolume);
			if (_fademode == Soundfade.FADEIN){
				returnstring += ", fading in";
			}else if (_fademode == Soundfade.FADEOUT){
				returnstring += ", fading out";
			}
			if (_duckmode != Soundfade.NONE){
				returnstring += ", ducked for " + twodigits((_duckendtime - flash.Lib.getTimer()) / 1000);
			}
			returnstring += ", pan: " + twodigits(_panning) + ")";
			return returnstring;
		}
		return "(free)";
	}
	
	public function isplaying():Bool{
		if (!free){
			return true;
		}
		return false;
	}
	
	public var name:String;
	
	private var _fademode:Soundfade;
	private var _fadestarttime:Float;
	private var _fadeendtime:Float;
	
	private var _duckmode:Soundfade;
	private var _duckstarttime:Float;
	private var _duckendtime:Float;
	
	private var _sound:openfl.media.Sound;
	private var _soundchannel:openfl.media.SoundChannel;
	
	private var soundoffset:Point;
	
	public var length(get, null):Float;
	function get_length():Float { return _sound.length / 1000; }
	
	public var position(get, set):Float;
	function get_position():Float { return _soundchannel.position / 1000; }
	function set_position(newposition:Float):Float {
		#if flash
		_soundchannel.stop();
		_soundchannel = _sound.play(Geom.wrap(newposition * 1000, 0, _sound.length), 0, currenttransform());
		if (_soundchannel != null){
			_soundchannel.addEventListener(Event.SOUND_COMPLETE, oncomplete);
			
			free = false;
		}else{
			free = true;
		}
		#else
		_soundchannel.position = Geom.wrap(newposition * 1000, 0, _sound.length);
		#end
		return newposition;
	}
	
	public var loop(get, set):Bool;
	private var _loop:Bool = false;
	function get_loop():Bool { return _loop; }
	
	function set_loop(newloop:Bool):Bool{
		_loop = newloop;
		return _loop;
	}
	
	private var _adjustedvolume:Float;
	private var _fadedvolume:Float;
	private var _duckedvolume:Float;
	
	public var volume(get, set):Float;
	private var _volume:Float = 1.0;
	function get_volume():Float { return _volume; }
	
	function set_volume(newvol:Float):Float{
		_volume = newvol;
		
		if(_soundchannel != null){
			_soundchannel.soundTransform = currenttransform();	
		}
		return _volume;
	}
	
	public var panning(get, set):Float;
	private var _panning:Float = 0;
	function get_panning():Float { return _panning; }
	
	function set_panning(newpanning:Float):Float{
		_panning = newpanning;
		
		if(_soundchannel != null){
			_soundchannel.soundTransform = currenttransform();	
		}
		return _panning;
	}
	
	private function currenttransform():openfl.media.SoundTransform{
		//If we're in the sound pool, then everything is adjusted by the Sound variables. Otherwise, it's not
		if (poolid != -1){
			return new openfl.media.SoundTransform(
			  Geom.clamp(_volume * _adjustedvolume * _fadedvolume * _duckedvolume * Sound.volume, 0, 1), 
				Geom.clamp(_panning + Sound.panning, -1, 1));
		}
		return new openfl.media.SoundTransform(
		  Geom.clamp(_volume * _adjustedvolume * _fadedvolume * _duckedvolume, 0, 1), 
			Geom.clamp(_panning, -1, 1));
	}
	
	private var free(get, set):Bool;
	private var _free:Bool;
	function get_free():Bool { return _free; }
	function set_free(newfree:Bool):Bool{
		if (!_free && newfree){
			if (poolid != -1){
				//Recycle this audio object if it's in the pool
				Sound.audiopool.recycle(this);
			}
		}
		
		_free = newfree;
		
		return _free;
	}
	
	//Pool management
	private function dispose(){
		if(_soundchannel != null){
			_soundchannel.stop();
		}
		_soundchannel = null;
		_sound = null;
		_adjustedvolume = 1.0;
		reset();
	}
	
	private var poolid:Int;
}