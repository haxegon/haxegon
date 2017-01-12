package haxegon;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.Assets;
import openfl.text.Font;

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
	
	private static var tempstring:String;
	
	/* Data.hx asset loading functions are used internally by haxegon
	 * to make sure case in-insensitive loading works ok */
	private static var embeddedassets_original:Array<String>;
	private static var embeddedassets:Array<String>;
	private static function initassets() {
		embeddedassets_original = Assets.list();
		embeddedassets = [];
		for (i in 0 ... embeddedassets_original.length) embeddedassets.push(embeddedassets_original[i].toLowerCase());		
	}
	 
	private static function assetexists(filename:String):Bool {
		filename = filename.toLowerCase();
		return embeddedassets.indexOf(filename) >= 0;
	}
	
	private static function assetexists_infolder(folder:String, filename:String):Bool {
		filename = filename.toLowerCase();
		folder = folder.toLowerCase();
		//We look through the assets list for at one that contains the folder name and the filename
		var folderlength:Int = folder.length;
		var filenamelength:Int = filename.length;
		for (i in 0 ... embeddedassets.length) {
		  if (S.left(embeddedassets[i], folderlength) == folder) {
				if (S.right(embeddedassets[i], filenamelength) == filename) {
					return true;
				}
			}
		}
		return false;
	}
	
	private static function getsoundasset(filename:String):Sound {
		filename = filename.toLowerCase();
		var realfilename:String = embeddedassets_original[embeddedassets.indexOf(filename)];
	  return Assets.getSound(realfilename);
	}
	
	private static function getgraphicsasset(filename:String):BitmapData {
		filename = filename.toLowerCase();
		var realfilename:String = embeddedassets_original[embeddedassets.indexOf(filename)];
	  return Assets.getBitmapData(realfilename);
	}
	
	private static function getfontasset(filename:String):Font {
		filename = filename.toLowerCase();
		var realfilename:String = embeddedassets_original[embeddedassets.indexOf(filename)];
	  return Assets.getFont(realfilename);
	}
	
	private static function gettextasset(filename:String):String {
		filename = filename.toLowerCase();
		var realfilename:String = embeddedassets_original[embeddedassets.indexOf(filename)];
	  return Assets.getText(realfilename);
	}
}