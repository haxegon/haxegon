package terrylib;

import openfl.Assets;

class Data {
	public static var width:Int = 0;
	public static var height:Int = 0;
	
	public static function loadtext(textfile:String):Array<String> {
		tempstring = Assets.getText("data/text/" + textfile + ".txt");
		tempstring = replacechar(tempstring, "\r", "");
		
		return tempstring.split("\n");
	}
	
	public static function loadcsv_int(csvfile:String, delimiter:String = ","):Array<Int> {
		tempstring = Assets.getText("data/text/" + csvfile + ".csv");
		
		//figure out width
		width = 1;
		var i:Int = 0;
		while (i < tempstring.length) {
			if (mid(tempstring, i) == delimiter) width++;
			if (mid(tempstring, i) == "\n") {
				break;
			}
			i++;
		}
		
		tempstring = replacechar(tempstring, "\r", "");
		tempstring = replacechar(tempstring, "\n", delimiter);
		
		var intarray:Array<Int> = [];
		var stringarray:Array<String> = tempstring.split(delimiter);
		
		for (i in 0 ... stringarray.length) {
			intarray.push(Std.parseInt(stringarray[i]));
		}
		
		height = Std.int(intarray.length / width);
		return intarray;
	}
	
	public static function loadcsv_float(csvfile:String, delimiter:String = ","):Array<Float> {
		tempstring = Assets.getText("data/text/" + csvfile + ".csv");
		
		//figure out width
		width = 1;
		var i:Int = 0;
		while (i < tempstring.length) {
			if (mid(tempstring, i) == delimiter) width++;
			if (mid(tempstring, i) == "\n") {
				break;
			}
			i++;
		}
		
		tempstring = replacechar(tempstring, "\r", "");
		tempstring = replacechar(tempstring, "\n", delimiter);
		
		var floatarray:Array<Float> = [];
		var stringarray:Array<String> = tempstring.split(delimiter);
		
		for (i in 0 ... stringarray.length) {
			floatarray.push(Std.parseFloat(stringarray[i]));
		}
		
		height = Std.int(floatarray.length / width);
		return floatarray;
	}
	
	public static function loadcsv_string(csvfile:String, delimiter:String = ","):Array<String> {
		tempstring = Assets.getText("data/text/" + csvfile + ".csv");
		
		//figure out width
		width = 1;
		var i:Int = 0;
		while (i < tempstring.length) {
			if (mid(tempstring, i) == delimiter) width++;
			if (mid(tempstring, i) == "\n") {
				break;
			}
			i++;
		}
		
		tempstring = replacechar(tempstring, "\r", "");
		tempstring = replacechar(tempstring, "\n", delimiter);
		
		var stringarray:Array<String> = tempstring.split(delimiter);
		height = Std.int(stringarray.length / width);
		return stringarray;
	}
	
	/** Return characters from the middle of a string. */
	private static function mid(currentstring:String, start:Int = 0, length:Int = 1):String {
		return currentstring.substr(start,length);
	}
	
	private static function replacechar(currentstring:String, ch:String = "|", ch2:String = ""):String {
		var fixedstring:String = "";
		for (i in 0 ... currentstring.length) {
			if (mid(currentstring, i) == ch) {
				fixedstring += ch2;
			}else {
				fixedstring += mid(currentstring, i);
			}
		}
		return fixedstring;
	}
	
	private static var tempstring:String;
}