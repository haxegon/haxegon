package haxegon;

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
	
	public static function flagset(key:String, value:Dynamic) {
	  flags.set(key, value);	
	}
	
	public static function flagget(key:String):Dynamic {
	  return flags.get(key);	
	}
	
	public static function flagexists(key:String):Bool {
	  return flags.exists(key);
	}
	
	public static function flagremove(key:String) {
	  flags.remove(key);
	}
	
	public static function flaglist():Array<String> {
	  var returnval:Array<String> = [];
		for (f in flags.keys()) {
			returnval.push(f);
		}
		return returnval;
	}
	
	private static var flags:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	private static var tempstring:String;
}