package haxegon;

import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

class Save {
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
	
	private static function changesavefile(name:String) {
		_filename = name;
		so = SharedObject.getLocal(_filename);
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
	
	public static function exists(key:String):Bool {
	  if (so == null) changesavefile("haxegongame");
		if (Reflect.field(so.data, key) == null) return false;
		return true;
	}
	
	public static function load(key:String):Dynamic {
	  if (so == null) changesavefile("haxegongame");
		
		var returnval:Dynamic = Reflect.field(so.data, key);
		if (returnval == null) {
			return 0;
		}
		
		return returnval;
	}
	
	public static function deletesave(?name:String) {
		if (name == null) name = "haxegongame";
		if (_savefile != name) {
			var newso:SharedObject = SharedObject.getLocal(name);
			newso.clear();
		}else {
		  so.clear();	
		}
	}
	
	private static var so:SharedObject;	
}