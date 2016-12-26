package haxegon;

import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;
import openfl.Assets;

class Data {
	public static var width:Int = 0;
	public static var height:Int = 0;
	
	public static function loadtext(textfile:String):Array<String> {
		if (Assets.exists("data/text/" + textfile + ".txt")) {
			tempstring = Assets.getText("data/text/" + textfile + ".txt");
		}else {
		  Debug.log("ERROR: In loadtext, cannot find \"data/text/" + textfile + ".txt\"."); 
		  return [""];
		}
		
		tempstring = S.replacechar(tempstring, "\r", "");
		
		return tempstring.split("\n");
	}
	
	@:generic
	public static function loadcsv<T>(csvfile:String, delimiter:String = ","):Array<T> {
		if (Assets.exists("data/text/" + csvfile + ".csv")) {
			tempstring = Assets.getText("data/text/" + csvfile + ".csv");
		}else {
		  Debug.log("ERROR: In loadcsv, cannot find \"data/text/" + csvfile + ".csv\"."); 
		  tempstring = "";
		}
		
		//figure out width
		width = 1;
		var i:Int = 0;
		while (i < tempstring.length) {
			if (S.mid(tempstring, i) == delimiter) width++;
			if (S.mid(tempstring, i) == "\n") {
				break;
			}
			i++;
		}
		
		tempstring = S.replacechar(tempstring, "\r", "");
		tempstring = S.replacechar(tempstring, "\n", delimiter);
		
		var returnedarray:Array<T> = new Array<T>();
		var stringarray:Array<String> = tempstring.split(delimiter);
		
		for (i in 0 ... stringarray.length) {
			returnedarray.push(cast stringarray[i]);
		}
		
		height = Std.int(returnedarray.length / width);
		return returnedarray;
	}
	
	public static function blank2darray(width:Int, height:Int):Array<Array<Int>> {
		var returnedarray2d:Array<Array<Int>> = [for (x in 0 ... width) [for (y in 0 ... height) 0]];
		return returnedarray2d;
	}
	
	@:generic
	public static function load2dcsv<T>(csvfile:String, delimiter:String = ","):Array<Array<T>> {
		if (Assets.exists("data/text/" + csvfile + ".csv")) {
			tempstring = Assets.getText("data/text/" + csvfile + ".csv");
		}else {
		  Debug.log("ERROR: In load2dcsv, cannot find \"data/text/" + csvfile + ".csv\"."); 
		  tempstring = "";
		}
		
		//figure out width
		width = 1;
		var i:Int = 0;
		while (i < tempstring.length) {
			if (S.mid(tempstring, i) == delimiter) width++;
			if (S.mid(tempstring, i) == "\n") {
				break;
			}
			i++;
		}
		
		tempstring = S.replacechar(tempstring, "\r", "");
		tempstring = S.replacechar(tempstring, "\n", delimiter);
		
		var returnedarray:Array<T> = new Array<T>();
		var stringarray:Array<String> = tempstring.split(delimiter);
		
		for (i in 0 ... stringarray.length) {
			returnedarray.push(cast stringarray[i]);
		}
		
		height = Std.int(returnedarray.length / width);
		
		var returnedarray2d:Array<Array<T>> = [for (x in 0 ... width) [for (y in 0 ... height) returnedarray[x + (y * width)]]];
		return returnedarray2d;
	}
	
	public static var savefile(get, set):String;
	private static var _savefile:String = "";
	
	static function get_savefile():String {
		return _savefile;
	}
	
	static function set_savefile(newsavefile:String):String {
	  if(savefile != newsavefile){
      changesavefile(newsavefile);
    }
		return _savefile;
	}
	
	private static function changesavefile(name:String) {
		_savefile = name;
		so = SharedObject.getLocal(_savefile);
	}
	
	public static function save(key:String, value:Dynamic) {
	  if (so == null) changesavefile("haxegongame");
		
		Reflect.setField(so.data, key, value);
		
		try { 
			so.flush();
		} catch (e:Dynamic) {
		  Debug.log("Error: Unable to save \"" + key + "\"."); 
		}
	}
	
	public static function load(key:String):Dynamic {
	  if (so == null) changesavefile("haxegongame");
		
		var returnval:Dynamic = Reflect.field(so.data, key);
		if (returnval == null) {
			if (_savefile == "haxegongame") {
				Debug.log("Error: There is no value stored for \"" + key + "\"");
			}else{
				Debug.log("Error: Savefile + \"" + _savefile + "\" has no value stored for \"" + key + "\"");
			}
		}
		
		return returnval;
	}
	
	public static function deletesave(name:String) {
		if (_savefile != name) {
			var newso:SharedObject = SharedObject.getLocal(name);
			newso.clear();
		}else {
		  so.clear();	
		}
	}
	
	public static function flagset(key:String, value:Dynamic) {
		_flaglistdirty = true;
	  flags.set(key, value);
	}
	
	public static function flagget(key:String):Dynamic {
	  return flags.get(key);
	}
	
	public static function flagexists(key:String):Bool {
	  return flags.exists(key);
	}
	
	public static function flagremove(key:String) {
		_flaglistdirty = true;
	  flags.remove(key);
	}
	
	public static var flaglist(get, never):Array<String> ;
	private static var _flaglist:Array<String> = [];
	private static var _flaglistdirty:Bool = true;
	
	static function get_flaglist():Array<String> {
		if (_flaglistdirty) {
			_flaglist = [];
			for (f in flags.keys()) {
				_flaglist.push(f);
			}
			
			_flaglistdirty = false;
		}
		
		return _flaglist;
	}
	
	private static var so:SharedObject;
	private static var flags:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	private static var tempstring:String;
}