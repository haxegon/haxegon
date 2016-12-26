package haxegon;

import openfl.display.*;          
import openfl.media.*; 
import openfl.events.*;

@:access(haxegon.Data)
class Music {
	//Play a sound effect! There are 16 channels, which iterate
	public static function playsound(soundname:String, volume:Float = 1.0, offset:Float = 0.0) {
		if (!effectindex.exists(soundname)) {
			if (!loadsound(soundname)) return;
		}
		
		temptransform = new SoundTransform(volumelevels[Std.int(effectindex.get(soundname))] * volume * globalsound);
		efchannel[currentefchan] = efchan[Std.int(effectindex.get(soundname))].play(offset * 1000);
		efchannel[currentefchan].soundTransform = temptransform;
		currentefchan++;
		if (currentefchan > 15) currentefchan -= 16;
	}
	
	public static function stopsound() {
		temptransform = new SoundTransform(0);
		
		for (i in 0 ... 16) {
			if (efchannel[i] != null) efchannel[i].soundTransform = temptransform;
		}
	}
	
	public static function loadsound(soundname:String, volumelevel:Float = 1.0):Bool {
		#if flash
		if (Data.assetexists("data/sounds/" + soundname + ".mp3")) {
			efchan.push(Data.getsoundasset("data/sounds/" + soundname + ".mp3"));
		}else {
		  Debug.log("ERROR: In loadsound, cannot find \"data/sounds/mp3/" + soundname + ".mp3\". (.mp3 files are required for flash targets.)"); 
			return false;
		}
		#else
		if (Data.assetexists("data/sounds/" + soundname + ".ogg")) {
			efchan.push(Data.getsoundasset("data/sounds/" + soundname + ".ogg")); 
		}else {
		  Debug.log("ERROR: In loadsound, cannot find \"data/sounds/ogg/" + soundname + ".ogg\". (.ogg files are required on this platform.)"); 
			return false;
		}
		#end
		effectindex.set(soundname, numeffects);
		volumelevels.push(volumelevel);
		numeffects++;
		return true;
	}
	
	public static function loadsong(songname:String, volumelevel:Float = 1.0):Bool {	
		#if flash
		if (Data.assetexists("data/sounds/" + songname + ".mp3")) {
			musicchan.push(Data.getsoundasset("data/sounds/" + songname + ".mp3"));
		}else {
		  Debug.log("ERROR: In loadsong, cannot find \"data/sounds/mp3/" + songname + ".mp3\". (.mp3 files are required for flash targets.)"); 
			return false;
		}
		#else
		if (Data.assetexists("data/sounds/" + songname + ".ogg")) {
			musicchan.push(Data.getsoundasset("data/sounds/" + songname + ".ogg")); 
		}else {
		  Debug.log("ERROR: In loadsong, cannot find \"data/sounds/ogg/" + songname + ".ogg\". (.ogg files are required on this platform.)"); 
			return false;
		}
		#end
		songindex.set(songname, numsongs);
		songvolumelevels.push(volumelevel);
		numsongs++;
		return true;
	}
	
	public static function playsong(songname:String, ?time:Float = 0.0, ?loop:Bool = true) {
		if (!songindex.exists(songname)) {
			if(!loadsong(songname)) return;
		}
		
		if (currentsong != songname) {
			if (currentsong != "nothing") {
				//Stop the old song first
				musicchannel.stop();
				musicchannel.removeEventListener(Event.SOUND_COMPLETE, loopmusic);
			}
			
			musicfade = 0;
			musicfadein = 0;
			
			if (songname != "nothing") {
				currentsong = songname;
				
				if (loop) {
					if (time == 0) {
						musicchannel = musicchan[Std.int(songindex.get(songname))].play(0, 999999);
					} else {
						musicchannel = musicchan[Std.int(songindex.get(songname))].play((time * 1000) % musicchan[Std.int(songindex.get(songname))].length);
						musicchannel.addEventListener(Event.SOUND_COMPLETE, loopmusic);
					}
				} else {
					musicchannel = musicchan[Std.int(songindex.get(songname))].play((time * 1000) % musicchan[Std.int(songindex.get(songname))].length);
				}
				musicchannel.soundTransform = new SoundTransform(songvolumelevels[Std.int(songindex.get(songname))] * globalsound);
			}else {	
				currentsong = "nothing";
			}
		}
	}   
	
	public static function stopsong() { 
		if (musicchannel != null) {
			musicchannel.removeEventListener(Event.SOUND_COMPLETE, stopmusic);
			musicchannel.stop();
		}
		currentsong = "nothing";
	}
	
	public static function fadeout() { 
		if (musicfade == 0) {
			musicfade = 31;
		}
	}
	
	private static function init(){
		currentsong = "nothing"; musicfade = 0;//no music, no amb
		currentefchan = 0;
		usingtickertext = false;
		
		globalsound = 1; muted = false;
		
		numplays = 0;
		numeffects = 0;
		numsongs = 0;
	}
	
	private static function loopmusic(e:Event) { 
		musicchannel.removeEventListener(Event.SOUND_COMPLETE, loopmusic);
		if (currentsong != "nothing") {
			musicchannel = musicchan[Std.int(songindex.get(currentsong))].play(0, 999999);
			musicchannel.soundTransform = new SoundTransform(songvolumelevels[Std.int(songindex.get(currentsong))] * globalsound);
		}
	}
	
	private static function stopmusic(e:Event) { 
		musicchannel.removeEventListener(Event.SOUND_COMPLETE, stopmusic);
		musicchannel.stop();
		currentsong = "nothing";
	}
	
	private static function processmusicfade() {
		musicfade--;
		if (musicchannel != null) {
			if (musicfade > 0) {
				musicchannel.soundTransform = new SoundTransform((musicfade / 30) * globalsound);
			}else {
				musicchannel.stop();
				currentsong = "nothing";
			}
		}
	}
	
	private static function processmusicfadein() {
		musicfadein--;
		if (musicchannel != null) {
			if (musicfadein > 0) {
				musicchannel.soundTransform = new SoundTransform(((60-musicfadein) / 60 )*globalsound);
			}else {
				musicchannel.soundTransform = new SoundTransform(1.0 * globalsound);
			}
		}
	}
	
	private static function processmusic() {
		if (musicfade > 0) processmusicfade();
		if (musicfadein > 0) processmusicfadein();
	}
	
	private static function updateallvolumes() {
		//Update the volume levels of all currently playing sounds.
		//Music:
		if(currentsong!="nothing"){
			musicchannel.soundTransform = new SoundTransform(songvolumelevels[Std.int(songindex.get(currentsong))] * globalsound);
		}
		//Sound effects
		//Figure this out someday I guess?
	}
	
	private static function processmute() {
		if (Text.input_show == 0) {
			if (Input.justpressed(Key.M) && mutebutton <= 0) {
				mutebutton = 2; if (muted) { muted = false; }else { muted = true;}
			}
			if (mutebutton > 0 && !Input.pressed(Key.M)) mutebutton--;
		}
		
		if (muted) {
			if (globalsound == 1) {
			  globalsound = 0;
				updateallvolumes();
			}
		}
		
		if (!muted && globalsound < 1) {
			globalsound += 0.05; 
			if (globalsound > 1.0) globalsound = 1.0;
			updateallvolumes();
		}
	}
	
	public static var musicchan:Array<Sound> = new Array<Sound>();	
	public static var musicchannel:SoundChannel;
	public static var currentsong:String;
	public static var musicfade:Int;
	public static var musicfadein:Int;
	
	public static var effectindex:Map<String, Int> = new Map<String, Int>();
	public static var volumelevels:Array<Float> = new Array<Float>();
	public static var numeffects:Int;
	
	public static var songindex:Map<String, Int> = new Map<String, Int>();
	public static var songvolumelevels:Array<Float> = new Array<Float>();
	public static var numsongs:Int;
	
	public static var currentefchan:Int;
	public static var efchannel:Array<SoundChannel> = new Array<SoundChannel>();
	public static var efchan:Array<Sound> = new Array<Sound>();
	public static var numplays:Int;
	
	public static var usingtickertext:Bool;
	
	public static var temptransform:SoundTransform;
	public static var globalsound:Float;
	public static var muted:Bool; 
	public static var mutebutton:Int;
}