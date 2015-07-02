package terrylib;

import openfl.Assets;

class Data {
	public static function loadtext(textfile:String):Array<String> {
		tempstring = Assets.getText("data/text/" + textfile + ".txt");
		tempstring = replacechar(tempstring, "\r", "");
		
		return tempstring.split("\n");
	}
	
	public static function loadcsv(textfile:String):Array<Int> {
		tempstring = Assets.getText("data/text/" + textfile + ".csv");
		
		tempstring = replacechar(tempstring, "\r", "");
		tempstring = replacechar(tempstring, "\n", ",");
		
		var intarray:Array<Int> = [];
		var stringarray:Array<String> = tempstring.split(",");
		
		for (i in 0 ... stringarray.length) {
			intarray.push(Std.parseInt(stringarray[i]));
		}
		
		return intarray;
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