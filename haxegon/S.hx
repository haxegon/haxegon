package haxegon;

class S {
	/* Returns the ASCII value of the character. If character is a string, returns the ASCII
	 * code of the first character in the string. */
	public static inline function asciicode(character:String):Int {
	  return character.charCodeAt(0);
	}
	
	/* Converts an ascii code to a string. E.g. fromascii(65) == "A" */
	public static inline function fromascii(asciicode:Int):String {
	  return String.fromCharCode(asciicode);	
	}
	
	/* Joins up an array into a single string. */
	public static inline function join(array:Array<Dynamic>, seperator:String):String {
		return array.join(seperator);
	}
	
	/* Seperates a string into an array of strings. */
	public static function seperate(currentstring:String, delimiter:String):Array<String> {
		return currentstring.split(delimiter);
	}
	
	/** Returns an uppercase version of the string. */
	public static inline function uppercase(currentstring:String):String {
		return currentstring.toUpperCase();
	}
	
	/** Returns an lowercase version of the string. */
	public static inline function lowercase(currentstring:String):String {
		return currentstring.toLowerCase();
	}
	
	/** Splits a string into an array, divided by a given delimiter character (e.g. ",")*/
	public static inline function split(currentstring:String, delimiter:String):Array<String> {
		return currentstring.split(delimiter);
	}
	
	/** Removes substring from the fullstring. */
	public static function removefromstring(fullstring:String, substring:String):String {
		var t:Int = positioninstring(fullstring, substring);
		if (t == -1) {
			return fullstring;
		}else {
			return removefromstring(getroot(fullstring, substring) + getbranch(fullstring, substring), substring);
		}
	}
	
	/** Returns true if the given stringtocheck is in the given fullstring. */
	public static function isinstring(fullstring:String, stringtocheck:String):Bool {
		if (positioninstring(fullstring, stringtocheck) != -1) return true;
		return false;
	}
	
	/** Return the position of a substring in a given string. -1 if not found. */
	public static inline function positioninstring(fullstring:String, substring:String, start:Int = 0):Int {
		return (fullstring.indexOf(substring, start));
	}
	
	/** Return character at given position */
	public static inline function letterat(currentstring:String, position:Int = 0):String {
		return currentstring.substr(position, 1);
	}
	
	/** Return characters from the middle of a string. */
	public static inline function mid(currentstring:String, start:Int = 0, length:Int = 1):String {
		return currentstring.substr(start,length);
	}
	
	/** Return characters from the left of a string. */
	public static inline function left(currentstring:String, length:Int = 1):String {
		return currentstring.substr(0,length);
	}
	
	/** Return characters from the right of a string. */
	public static inline function right(currentstring:String, length:Int = 1):String {
		return currentstring.substr(currentstring.length - length, length);
	}
	
	/** Return string with N characters removed from the left. */
	public static inline function removefromleft(currentstring:String, length:Int = 1):String {
		return right(currentstring, currentstring.length - length);
	}
	
	/** Return string with N characters removed from the right. */
	public static inline function removefromright(currentstring:String, length:Int = 1):String {
		return left(currentstring, currentstring.length - length);
	}
	
	/** Reverse a string. */
	public static function reversetext(currentstring:String):String {
		var reversedstring:String = "";
		
		for (i in 0 ... currentstring.length) reversedstring += currentstring.substr(currentstring.length - i - 1, 1);
		return reversedstring;
	}
	
	/** Given a string currentstring, replace all occurances of string ch with ch2. Useful to remove characters. */
	public static function replacechar(currentstring:String, ch:String = "|", ch2:String = ""):String {
		return StringTools.replace(currentstring, ch, ch2);
	}
	
	/** Given a string currentstring, return everything after the LAST occurance of the "ch" character */
	public static function getlastbranch(currentstring:String, ch:String):String {
		var i:Int = currentstring.length - 1;
		while (i >= 0) {
			if (mid(currentstring, i, 1) == ch) {
				return mid(currentstring, i + 1, currentstring.length - i - 1);
			}
			i--;
		}
		return currentstring;
	}
	
	/** Given a string currentstring, return everything before the first occurance of the "ch" character */
	public static function getroot(currentstring:String, ch:String):String {
		for (i in 0 ... currentstring.length) {
			if (mid(currentstring, i, 1) == ch) {
				return mid(currentstring, 0, i);
			}
		}
		return currentstring;
	}
	
	/** Given a string currentstring, return everything after the FIRST occurance of the "ch" character */
	public static function getbranch(currentstring:String, ch:String):String {
		for (i in 0 ... currentstring.length) {
			if (mid(currentstring, i, 1) == ch) {
				return mid(currentstring, i + 1, currentstring.length - i - 1);
			}
		}
		return currentstring;
	}
	
	/** Given a string currentstring, return everything between the first and the last bracket (). */
	public static function getbetweenbrackets(currentstring:String):String {
		while (mid(currentstring, 0, 1) != "(" && currentstring.length > 0)	currentstring = mid(currentstring, 1, currentstring.length - 1);
		while (mid(currentstring, currentstring.length-1, 1) != ")" && currentstring.length > 0) currentstring = mid(currentstring, 0, currentstring.length - 1);
		
		if (currentstring.length <= 0) return "";
		return mid(currentstring, 1, currentstring.length - 2);
	}
	
	/** Given a string currentstring, return a string without spaces around it. */
	public static function trimspaces(currentstring:String):String {
		while (mid(currentstring, 0, 1) == " " && currentstring.length > 0)	currentstring = mid(currentstring, 1, currentstring.length - 1);
		while (mid(currentstring, currentstring.length - 1, 1) == " " && currentstring.length > 0) currentstring = mid(currentstring, 0, currentstring.length - 1);
		
		while (mid(currentstring, 0, 1) == "\t" && currentstring.length > 0) currentstring = mid(currentstring, 1, currentstring.length - 1);
		while (mid(currentstring, currentstring.length - 1, 1) == "\t" && currentstring.length > 0) currentstring = mid(currentstring, 0, currentstring.length - 1);
		
		if (currentstring.length <= 0) return "";
		return currentstring;
	}
	
	/** True if string currentstring is some kind of number; false if it's something else. */
	public static function isnumber(currentstring:String):Bool {
		if (Math.isNaN(Std.parseFloat(currentstring))) {
			return false;
		}else{
			return true;
		}	
		return false;
	}
}