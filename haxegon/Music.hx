package haxegon;

@:access(haxegon.Sound)
class Music{
	public static function play(soundname:String, fadeintime:Float = 0, loop:Bool = true, volume:Float = 1.0, panning:Float = 0){
		soundname = soundname.toLowerCase();
		
		if (_currentsong == ""){
			Sound.play(soundname, fadeintime, loop, volume * _musicvolume, panning);
			_currentsong = soundname;
		}else	if (Sound.isplaying(_currentsong)){
			Sound.stop(_currentsong, crossfade);
			Sound.play(soundname, Std.int(Math.max(fadeintime, crossfade)), loop, volume * _musicvolume, panning);
			_currentsong = soundname;
		}else if (!Sound.isplaying(soundname)){
			Sound.play(soundname, fadeintime, loop, volume * _musicvolume, panning);
			_currentsong = soundname;
		}
	}
	
	public static function stop(fadeout:Float = 0){
		if (_currentsong != ""){
			Sound.stop(_currentsong, fadeout);
			_currentsong = "";
		}
	}
	
	public static var currentposition(get, null):Float;
	static function get_currentposition():Float{
		if (_currentsong != ""){
			if (haxegon.Sound.isplaying(_currentsong)){
				for (i in 0 ... haxegon.Sound.channel.length){
					if (haxegon.Sound.channel[i].soundname == _currentsong){
						return haxegon.Sound.channel[i].position;
					}
				}
		  }
		}
		return 0;
	}
	
	static function set_currentposition(newposition:Float):Float{
		if (_currentsong != ""){
			if (haxegon.Sound.isplaying(_currentsong)){
				for (i in 0 ... haxegon.Sound.channel.length){
					if (haxegon.Sound.channel[i].soundname == _currentsong){
						haxegon.Sound.channel[i].position = newposition;
					}
				}
		  }
		}
		return newposition;
	}
	
	public static var crossfade:Float = 0;
	public static var currentsong(get, set):String;
	private static var _currentsong:String;
	static function get_currentsong():String {
		if (Sound.isplaying(_currentsong)) return _currentsong;
		
		_currentsong = "";
	  return _currentsong;
	}
	
	static function set_currentsong(newsong:String):String{
		play(newsong);
		
		return newsong;
	}
	
	public static var volume(get, set):Float;
	private static var _musicvolume:Float = 1.0;
	static function get_volume():Float {
	  return _musicvolume;	
	}
	
	static function set_volume(vol:Float):Float{
		_musicvolume = vol;
		
		for (i in 0 ... Sound.channel.length){
			if(Sound.channel[i].soundname == _currentsong){
				Sound.channel[i].changevolume(_musicvolume);
			}
		}
		
		return _musicvolume;
	}
}