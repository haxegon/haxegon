package haxegon;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.Assets;
import openfl.text.Font;
import haxe.Json;

class Data {
	public static var width:Int = 0;
	public static var height:Int = 0;
	
	public static function loadjson(jsonfile:String):Dynamic {
		jsonfile = jsonfile.toLowerCase();
		var jfile:Dynamic;
		if (Assets.exists("data/text/" + jsonfile + ".json")) {
			jfile = Json.parse(Assets.getText("data/text/" + jsonfile + ".json"));
		}else {
		  Debug.log("ERROR: In loadjson, cannot find \"data/text/" + jsonfile + ".json\"."); 
		  return null;
		}
		
		//Add helper "_fields" array to every node of the json file
		populatefields(jfile);
		
		return jfile;
	}
	
	private static function populatefields(j:Dynamic){
		if (!Std.is(j, String)){
			if (!Reflect.hasField(j, "_fields")){
				j._fields = Reflect.fields(j);
				for (i in 0 ... j._fields.length){
					populatefields(Reflect.field(j, j._fields[i]));
				}
			}
		}
	}
	
	private static function xmltojson(x:Xml):Dynamic{
		var jsonbit:Dynamic = {};
		var hasattributes:Bool = false;
		
		if (x.nodeType == Xml.Element){
			var attcount:Int = 0;
			for (attribute in x.attributes()){
				attcount++;
				Reflect.setField(jsonbit, attribute, x.get(attribute));
			}
			if (attcount > 0) hasattributes = true;
		}else if (x.nodeType == Xml.Comment){
			jsonbit = x.nodeValue;
		}
		
		for (xchild in x.iterator()){
			if (xchild.nodeType == Xml.Element){
				if (Reflect.hasField(jsonbit, xchild.nodeName)){
					//This is an array! Push elements onto it
					var currentnode:Dynamic = Reflect.field(jsonbit, xchild.nodeName);
					if (Std.is(currentnode, Array)){
						currentnode.push(xmltojson(xchild));
						Reflect.setField(jsonbit, xchild.nodeName, currentnode);
					}else{
						var nodearray:Array<Dynamic> = [];
						nodearray.push(currentnode);
						nodearray.push(xmltojson(xchild));
						Reflect.setField(jsonbit, xchild.nodeName, nodearray);
					}
				}else{
					Reflect.setField(jsonbit, xchild.nodeName, xmltojson(xchild));
				}
			}else if (xchild.nodeType == Xml.Comment || xchild.nodeType == Xml.PCData){
				var textval:String = xchild.nodeValue;
				textval = S.replacechar(textval, "\r", "");
				textval = S.replacechar(textval, "\n", "");
				textval = S.trimspaces(textval);
				if (textval != ""){
					if(hasattributes){
						jsonbit._text = textval;
					}else{
						jsonbit = textval;
					}
				}
			}
		}
		
		return jsonbit;
	}
	
	public static function loadxml(xmlfile:String):Dynamic {
		var xfile:Dynamic = {};
		if (Assets.exists("data/text/" + xmlfile + ".xml")) {
			xfile = xmltojson(Xml.parse(Assets.getText("data/text/" + xmlfile + ".xml")));
		}else {
		  Debug.log("ERROR: In loadxml, cannot find \"data/text/" + xmlfile + ".xml\".");
		  return null;
		}
		
		//Add helper "_fields" array to every node of the xml file
		populatefields(xfile);
		
		return xfile;
	}
	
	public static function loadtext(textfile:String):Array<String> {
		textfile = textfile.toLowerCase();
		var tempstring:String = "";
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
		var tempstring:String = "";
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
	
	@:generic
	public static function create2darray<T>(width:Int, height:Int, value:T):Array<Array<T>> {
		return [for (x in 0 ... width) [for (y in 0 ... height) value]];
	}
	
	@:generic
	public static function load2dcsv<T>(csvfile:String, delimiter:String = ","):Array<Array<T>> {
		var tempstring:String = "";
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
	
	/* Data.hx asset loading functions are used internally by haxegon
	 * to make sure case insensitive loading works ok */
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