package haxegon;

import openfl.geom.Point;

@:access(haxegon.Data)
@:access(haxegon.Audio)
@:access(haxegon.Music)
class Sound{
	private static function init(){
	  soundassets = new Map<String, openfl.media.Sound>();
	  soundvolumeadjustment = new Map<String, Float>();
		soundoffsetindex = new Map<String, Point>();
		soundlengthindex = new Map<String, Float>();
		addtopool = true;
		audiopool = new AudioPool(64);
		addtopool = false;
		audiolist = new AudioList();
		
		_volume = 1.0;
		_panning = 0;
		typingsound = "";
		_mute = false;
		
		Music.init();
	}
	
	private static function update(){
		audiolist.foreachaudio(function(audio:Audio){
			audio.update();
		});
		
		audiolist.cleanup();
	}
	
	public static function load(soundname:String, adjustedvolume:Float = 1.0):Bool{
		soundname = soundname.toLowerCase();
		
		if (!soundassets.exists(soundname)){
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
				soundassets.set(soundname, soundasset);
				soundvolumeadjustment.set(soundname, adjustedvolume);
				soundoffsetindex.set(soundname, new Point(0, 0));
				soundlengthindex.set(soundname, soundasset.length / 1000);
			}
		}
		
		return true;
	}
	
	public static function offset(soundname:String, startoffsettime:Float = 0){ // To do: , endoffsettime:Float = 0){
		soundname = soundname.toLowerCase();
		soundoffsetindex.set(soundname, new Point(startoffsettime, 0)); // To do: , endoffsettime));
	}
	
	public static function play(soundname:String, fadeintime:Float = 0, loop:Bool = false, volume:Float = 1.0, panning:Float = 0){
		soundname = soundname.toLowerCase();
		
		if (!soundassets.exists(soundname)) {
			if (!load(soundname, 1)) return;
		}
		
		addtopool = true;
		var newaudio:Audio = audiopool.get();
		addtopool = false;
		newaudio._loop = loop;
		newaudio._volume = volume;
		newaudio._panning = panning;
		newaudio.offset(soundoffsetindex.get(soundname).x); //TO DO: End offsets
		newaudio.attachsound(soundname);
		newaudio.play(fadeintime);
	}
	
	public static function stop(?soundname:String = "", fadeout:Float = 0){
		soundname = soundname.toLowerCase();
		
		audiopool.foreachaudio(function(audio:Audio){
			if (audio.name == soundname || soundname == ""){
				audio.stop(fadeout);
			}
		});
	}
	
	public static function isplaying(soundname:String):Bool{
		var returnval:Bool = false;
		soundname = soundname.toLowerCase();
		
		audiopool.foreachaudio(function(audio:Audio){
			if (audio.name == soundname){
				if(audio.isplaying()){
					returnval = true;
				}
			}
		});
		
		return returnval;
	}
	
	public static var mute(get, set):Bool;
	private static var _mute:Bool = false;
	static function get_mute():Bool { return _mute; }
	static function set_mute(newmute:Bool):Bool{
		if (_mute != newmute){
			if (newmute){
				//Mute everything
				openfl.media.SoundMixer.soundTransform = new openfl.media.SoundTransform(0, 0);
			}else{
				//Unmute everything
				openfl.media.SoundMixer.soundTransform = new openfl.media.SoundTransform(1, 0);
			}
		}
		
		_mute = newmute;
		return _mute;
	}
	
	public static function length(soundname:String):Float{
		soundname = soundname.toLowerCase();
		if (soundlengthindex.exists(soundname)){
			return soundlengthindex.get(soundname);
		}
		
		return 0;
	}
	
	public static var volume(get, set):Float;
	private static var _volume:Float = 1.0;
	static function get_volume():Float { return _volume; }
	
	static function set_volume(newvol:Float):Float{
		_volume = newvol;
		
		audiopool.foreachaudio(function(audio:Audio){
			audio.updatetransform();
		});
		
		return _volume;
	}
	
	public static var panning(get, set):Float;
	private static var _panning:Float = 0;
	static function get_panning():Float { return _panning; }
	
	static function set_panning(newpanning:Float):Float{
		_panning = newpanning;
		
		audiopool.foreachaudio(function(audio:Audio){
			audio.updatetransform();
		});
		
		return _panning;
	}
	
	private static var soundassets:Map<String, openfl.media.Sound>;
	private static var soundvolumeadjustment:Map<String, Float>;
	private static var soundoffsetindex:Map<String, Point>;
	private static var soundlengthindex:Map<String, Float>;
	private static var audiopool:AudioPool;
	private static var audiolist:AudioList;
	private static var addtopool:Bool;
	
	public static var typingsound:String = "";
}

//Audiolist is for keeping track of sounds that we need full control over. It's slightly more
//expensive than using Audiopool, because we need to clean it up every frame, but it's
//needed for music and custom audio objects so that we can call update functions
@:access(haxegon.Audio)
private class AudioList{
	public function new() {
		audiolist = [];
	}
	
	public function add(audio:Audio){
		//push this audio object onto the list
		audiolist.push(audio);
	}
	
	public function get():Audio {
		//create a new Audio object, add it to the end of the list
		audiolist.push(new Audio());
		return audiolist[audiolist.length - 1];
	}
	
	public function foreachaudio(_f:Audio-> Void) {
		var i:Int = 0;
		while (i < audiolist.length) {
			if(audiolist[i] != null){
				_f(audiolist[i]);
			}
			i++;
		}
	}
	
	public function remove(a:Audio){
		var ind:Int = audiolist.indexOf(a);
		if (ind > -1){
			a.dispose();
			a = null;
			audiolist[ind] = null;
		}
	}
	
	public function cleanup(){
		var i:Int = 0;
		while (i < audiolist.length){
			if (audiolist[i] == null){
				audiolist.splice(i, 1);
			}else{
				i++;
			}
		}
	}
	
	public var audiolist:Array<Audio> = [];
}

//Audiopool is the general use sound effect channel assign system: it's quick to use, but
//it doesn't work for tracking specific audio over time
@:access(haxegon.Audio)
@:access(haxegon.Sound)
private class AudioPool {
	public function new(_initsize:Int) {
		for (i in 0 ... _initsize) {
		  audiolist.push(new Audio());
			audiolist[i].poolid = i;
		}
		
		totalinuse = 0;
	}
	
	public function get():Audio {
		//firstfree points to the first available free object in the pool
		//if it's null, then we need to create a new object
		if (totalinuse == audiolist.length) {
			Sound.addtopool = true;
			audiolist.push(new Audio());
			Sound.addtopool = false;
			audiolist[totalinuse].poolid = totalinuse;
			//Do this silently, probably?
			//trace("Warning: Pool size was initalised too small. New size is " + audiolist.length);
		}
		
		return audiolist[totalinuse++];
	}
	
	public function recycle(a:Audio) {
		a.dispose();
		
		for (i in 0 ... audiolist.length) {
			if (i != audiolist[i].poolid) {
				trace("Pool corruption!");
			}
		}

		if (a.poolid <= totalinuse - 1) {
			// Given audio is in use.
			if (totalinuse > 0) {
				var dyingaudio:Audio = a;
				var swapaudio:Audio = audiolist[totalinuse - 1];
				
				// Swap the recycling audio with the one at the end of the array's in-use section
				audiolist[dyingaudio.poolid] = swapaudio;
				audiolist[totalinuse - 1] = dyingaudio;

				// Fix up pool indices.
				audiolist[dyingaudio.poolid].poolid = dyingaudio.poolid;
				audiolist[totalinuse - 1].poolid = totalinuse - 1;
				
				for (i in 0 ... audiolist.length) {
					if (i != audiolist[i].poolid) {
						trace("Pool corruption!");
					}
				}
			}
			
			--totalinuse;
		}
	}
	
	public function foreachaudio(_f:Audio-> Void) {
		var i:Int = totalinuse;
		while (--i >= 0) {
			_f(audiolist[i]);
		}
	}
	
	public var audiolist:Array<Audio> = [];
	public var totalinuse:Int;
}	