package haxegon;

import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.Assets;
import openfl.text.Font;
import haxe.Json;

class Data {
	public static var width:Int = 0;
	public static var height:Int = 0;
	
	public static function loadjson(jsonfile:String):Dynamic {
		jsonfile = normalizefilename(jsonfile, "data/text/", "json");
		
		var jfile:Dynamic;
		if (Assets.exists(jsonfile)) {
			jfile = Json.parse(Assets.getText(jsonfile));
		}else {
		  Debug.log("ERROR: In loadjson, cannot find \"" + jsonfile + "\"."); 
		  return null;
		}
		
		//Add helper "_fields" array to every node of the json file
		populatefields(jfile);
		sanitisefields(jfile);
		
		return jfile;
	}
	
	private static function sanitisefields(j:Dynamic){
		if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(j, Array)){
			for (i in 0 ... j.length){
				sanitisefields(j[i]);
			}
		}else if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(j, String)){
			j = S.replacechar(j, ":", "_");
			j = S.replacechar(j, ";", "_");
			j = S.replacechar(j, "-", "_");
		}else{
			if (Reflect.hasField(j, "_fields")){
				if (j._fields != null){
					for (i in 0 ... j._fields.length){
						var before:String = j._fields[i];
						j._fields[i] = S.replacechar(j._fields[i], ":", "_");
						j._fields[i] = S.replacechar(j._fields[i], ";", "_");
						j._fields[i] = S.replacechar(j._fields[i], "-", "_");
						Reflect.setField(j, j._fields[i], Reflect.getProperty(j, before)); 
						
						sanitisefields(Reflect.field(j, before));
					}
				}
			}
		}
	}
	
	private static function populatefields(j:Dynamic){
		if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(j, Array)){
			for (i in 0 ... j.length){
				populatefields(j[i]);
			}
		}else	if (!#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(j, String)){
			if (!Reflect.hasField(j, "_fields")){
				var jfields:Array<String> = Reflect.fields(j);
				if (jfields != null && jfields != []){
					if(jfields.length > 0){
						j._fields = jfields;
						if (j._fields != null){
							if(!#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(j._fields, String)){
								for (i in 0 ... j._fields.length){
									populatefields(Reflect.field(j, j._fields[i]));
								}
							}
						}
					}
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
				var attributename:String = attribute;
				attributename = S.replacechar(attributename, ":", "_");
				attributename = S.replacechar(attributename, ";", "_");
				attributename = S.replacechar(attributename, "-", "_");
				Reflect.setField(jsonbit, attributename, x.get(attribute));
			}
			if (attcount > 0) hasattributes = true;
		}
		
		for (xchild in x.iterator()){
			if (xchild.nodeType == Xml.Element){
				var nodename:String = xchild.nodeName;
				nodename = S.replacechar(nodename, ":", "_");
				nodename = S.replacechar(nodename, ";", "_");
				nodename = S.replacechar(nodename, "-", "_");
				if (Reflect.hasField(jsonbit, nodename)){
					//This is an array! Push elements onto it
					var currentnode:Dynamic = Reflect.field(jsonbit, nodename);
					if (#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(currentnode, Array)){
						var n:Dynamic = xmltojson(xchild);
						currentnode.push(n);
						Reflect.setField(jsonbit, nodename, currentnode);
					}else{
						var nodearray:Array<Dynamic> = [];
						nodearray.push(currentnode);
						nodearray.push(xmltojson(xchild));
						Reflect.setField(jsonbit, nodename, nodearray);
					}
				}else{
					Reflect.setField(jsonbit, nodename, xmltojson(xchild));
				}
			}else if (xchild.nodeType == Xml.PCData){
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
		
		xmlfile = normalizefilename(xmlfile, "data/text/", "xml");
		
		if (Assets.exists(xmlfile)) {
			xfile = xmltojson(Xml.parse(Assets.getText(xmlfile)));
		}else {
		  Debug.log("ERROR: In loadxml, cannot find \"" + xmlfile + "\".");
		  return null;
		}
		
		//Add helper "_fields" array to every node of the xml file
		populatefields(xfile);
		sanitisefields(xfile);
		
		return xfile;
	}
	
	public static function loadtext(textfile:String):Array<String> {
		textfile = normalizefilename(textfile, "data/text/", "txt");
		
		var tempstring:String = "";
		
		if (Assets.exists(textfile)) {
			tempstring = Assets.getText(textfile);
		}else {
		  Debug.log("ERROR: In loadtext, cannot find \"" + textfile + "\"."); 
		  return [""];
		}
		
		tempstring = S.replacechar(tempstring, "\r", "");
		
		return tempstring.split("\n");
	}
	
	@:generic
	public static function loadcsv<T>(csvfile:String, delimiter:String = ","):Array<T> {
		csvfile = normalizefilename(csvfile, "data/text/", "csv");
		var tempstring:String = "";
		
		if (Assets.exists( csvfile)) {
			tempstring = Assets.getText(csvfile);
		}else {
		  Debug.log("ERROR: In loadcsv, cannot find \"" + csvfile + "\"."); 
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
		csvfile = normalizefilename(csvfile, "data/text/", "csv");
		
		var tempstring:String = "";
		
		if (Assets.exists(csvfile)) {
			tempstring = Assets.getText(csvfile);
		}else {
		  Debug.log("ERROR: In load2dcsv, cannot find \"" + csvfile + "\"."); 
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
	private static function normalizefilename(filename:String, folder:String, ext:String):String{
		filename = filename.toLowerCase();
		filename = folder + filename;
		if (!S.isinstring(S.getlastbranch(filename, "/"), ".")) filename += "." + ext;
		filename = Path.normalize(filename);
		return filename;
	}
	 
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
	
	private static function getsoundasset(filename:String, useCache:Bool = true):Sound {
		filename = filename.toLowerCase();
		var realfilename:String = embeddedassets_original[embeddedassets.indexOf(filename)];
	  return Assets.getSound(realfilename, useCache);
	}
	
	private static function getgraphicsasset(filename:String, useCache:Bool = true):BitmapData {
		filename = filename.toLowerCase();
		var realfilename:String = embeddedassets_original[embeddedassets.indexOf(filename)];
	  return Assets.getBitmapData(realfilename, useCache);
	}
	
	private static function getfontasset(filename:String, useCache:Bool = true):Font {
		filename = filename.toLowerCase();
		var realfilename:String = embeddedassets_original[embeddedassets.indexOf(filename)];
	  return Assets.getFont(realfilename, useCache);
	}
	
	private static function gettextasset(filename:String):String {
		filename = filename.toLowerCase();
		var realfilename:String = embeddedassets_original[embeddedassets.indexOf(filename)];
	  return Assets.getText(realfilename);
	}
}