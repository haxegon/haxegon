package haxegon;

import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

class Save {
	public static function savevalue(key:String, value:Dynamic) {
	  if (so == null) changesavefile("haxegongame");
		
		Reflect.setField(so.data, key, value);
		
		try { 
			so.flush();
		} catch (e:Dynamic) {
		  Debug.log("Error: Unable to save \"" + key + "\"."); 
		}
		
		keylistdirty = true;
	}
	
	public static function exists(key:String):Bool {
	  if (so == null) changesavefile("haxegongame");
		if (Reflect.field(so.data, key) == null) return false;
		return true;
	}
		
	public static function fileexists(savefile:String):Bool {
		var tempso:SharedObject = SharedObject.getLocal(savefile);
		
		if (Reflect.fields(tempso.data).length == 0) return false;
		return true;
	}
	
	public static function loadvalue(key:String):Dynamic {
	  if (so == null) changesavefile("haxegongame");
		
		var returnval:Dynamic = Reflect.field(so.data, key);
		if (returnval == null) {
			return 0;
		}
		
		return returnval;
	}
	
	public static function delete(?name:String) {
		if (name == null) name = "haxegongame";
		if (_filename != name) {
			var newso:SharedObject = SharedObject.getLocal(name);
			newso.clear();
		}else {
		  so.clear();	
		}
		
		keylistdirty = true;
	}
	
	public static var keys(get, never):Array<String>;
	
	static function get_keys():Array<String> {
	  if (so == null) changesavefile("haxegongame");
		
		if (keylistdirty) {
			var newkeylist:Array<String> = Reflect.fields(so.data);
			keylist = [];
			for(i in 0 ... newkeylist.length){
				keylist.push(newkeylist[i]);
			}
			keylistdirty = false;
		}
		
		return keylist;
	}
	
	private static function changesavefile(name:String) {
		_filename = name;
		so = SharedObject.getLocal(_filename);
		keylistdirty = true;
	}
	
  public static var filename(get, set):String;
	private static var _filename:String = "";
	
	static function get_filename():String {
		return _filename;
	}
	
	static function set_filename(newsavefile:String):String {
	  if(filename != newsavefile){
      changesavefile(newsavefile);
    }
		return _filename;
	}
	
	private static var so:SharedObject;	
	private static var keylist:Array<String>;
	private static var keylistdirty:Bool = true;
}