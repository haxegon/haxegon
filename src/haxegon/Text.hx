package haxegon;

import haxegon.util.*;
import openfl.geom.Matrix;
import starling.display.*;

@:access(haxegon.Input)
@:access(haxegon.Gfx)
class Text {
	public static function init(stage:Stage) {
		gfxstage = stage;
		input_cursorglow = 0;
		inputmaxlength = 40;
	}
	
	public static function align(a:Int) {
	  textalign = a;	
	}
	
	public static function rotation(a:Float, xpivot:Int = -15000, ypivot:Int = -15000) {
	  textrotate = a;
		textrotatexpivot = xpivot;
		textrotateypivot = ypivot;
	}
	
	public static function input_checkfortext() {
		inputtext = Input.keybuffer;
	}
	
	/** Reverse a string. */
	private static function reverse(t:String):String {
		var reversedstring:String = "";
		
		for (i in 0 ... t.length) reversedstring += t.substr(t.length - i - 1, 1);
		return reversedstring;
	}
	
	public static function input(x:Float, y:Float, text:String, col:Int = 0xFFFFFF, responsecol:Int = 0xCCCCCC):Bool {
		input_show = 2;
		
		input_font = currentfont;
		input_textsize = currentsize;
		typeface[currentindex].tf.text = text + inputtext;
		x = alignx(x); y = aligny(y);
		input_textxp = x;
		input_textyp = y;
		
		typeface[currentindex].tf.text = text;
		input_responsexp = input_textxp + Math.floor(typeface[currentindex].width);
		input_responseyp = y;
		
		input_text = text;
		input_response = inputtext;
		input_textcol = col;
		input_responsecol = responsecol;
		input_checkfortext();
		
		if (Input.justpressed(Key.ENTER) && inputtext != "") {
			return true;
		}
		return false;
	}
	
	/** Returns the entered string, and resets the input for next time. */
	public static function getinput():String {
		var response:String = inputtext;
		lastentry = inputtext;
		inputtext = "";
		Input.keybuffer = "";
		input_show = 0;
		
		return response;
	}
	
	public static function drawstringinput() {
		if (input_show > 0) {
			setfont(input_font, input_textsize);
			input_cursorglow++;
			if (input_cursorglow >= 96) input_cursorglow = 0;
			
			display(input_textxp, input_textyp, input_text, input_textcol);
			if (input_text.length < inputmaxlength) {
				if (input_cursorglow % 48 < 24) {
					display(input_responsexp, input_responseyp, input_response, input_responsecol);
				}else {
					display(input_responsexp, input_responseyp, input_response + "_", input_responsecol);
				}
			}else{
				display(input_responsexp, input_responseyp, input_response, input_responsecol);
			}
		}
		
		input_show--;
		if (input_show < 0) input_show = 0;
	}
	
	//Text display functions
	public static function wordwrap(?textwidth:Int) {
		trace("warning: unimplemented function wordwrap");
	}
	
	/* Given a width in pixels and a long string, return an array on strings
	 * that wraps to the given width with the current font. */
	public static function dowordwrap(textwidth:Int, txt:String) {
		trace("warning: unimplemented function dowordwrap");
	}
	
	private static function currentwidth():Float {
		if (typeface.length == 0) defaultfont();
		return typeface[currentindex].width;
	}
	
	private static function currentheight():Float {
		if (typeface.length == 0) defaultfont();
		return typeface[currentindex].height;
	}
	
	public static function width(text:String):Float {
		if (typeface.length == 0) defaultfont();
		typeface[currentindex].tf.text = text;
		return typeface[currentindex].width;
	}
	
	public static function height(?text:String):Float {
		if (text == null || text == "") text = "?";
		if (typeface.length == 0) defaultfont();
		typeface[currentindex].tf.text = text;
		return typeface[currentindex].height;
	}
	
	private static var t1:Float;
	private static var t2:Float;
	private static var t3:Float;
	
	private static function alignx(x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(Gfx.screenwidthmid - (currentwidth() / 2));
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + Math.floor(Gfx.screenwidth - currentwidth());
			}
		}
		
		return Math.floor(x);
	}
	
	private static function aligny(y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(Gfx.screenheightmid - currentheight() / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + Math.floor(Gfx.screenheight - currentheight());
			}
		}
		
		return Math.floor(y);
	}
	
	private static function aligntextx(t:String, x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(width(t) / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + width(t);
			}
		}
		
		return x;
	}
	
	private static function aligntexty(t:String, y:Float):Float {
		trace("warning: unimplemented function aligntexty");
		return 0;
	}
	
	public static function display(x:Float, y:Float, text:String, col:Int = 0xFFFFFF) {
		if (text == "") return;
		
		if (typeface.length == 0) defaultfont();
		
		typeface[currentindex].tf.color = col;
		typeface[currentindex].tf.text = text;
		
		x = alignx(x); y = aligny(y);
		x -= aligntextx(text, textalign);
		
		fontmatrix.identity();
		
		if (textrotate != 0) {
			if (textrotatexpivot != 0.0) tempxpivot = aligntextx(text, textrotatexpivot);
			if (textrotateypivot != 0.0) tempypivot = aligntexty(text, textrotateypivot);
			fontmatrix.translate( -tempxpivot, -tempypivot);
			fontmatrix.rotate((textrotate * 3.1415) / 180);
			fontmatrix.translate( tempxpivot, tempypivot);
		}
		
		fontmatrix.translate(x, y);
		Gfx.drawto.draw(typeface[currentindex].tf, fontmatrix);
		// Clumsy work around that isn't relavent for anything other than haxegon itself!
		if (typeface[currentindex].type == "ttf") {
		  Gfx.fillbox(-1, -1, 1, 1, Col.RED);	
		}
	}
	
	public static function defaultfont() {
		addfont(null, 16);
		setfont("Verdana", 16);
	}
	
	public static function setfont(fontname:String, size:Float = 1) {
		if (!fontfileindex.exists(fontname)) {
			addfont(fontname, size);
		}
		
		if (fontname != currentfont) {
			currentfont = fontname;
			if (typefaceindex.exists(currentfont + "_" + Std.string(currentsize))) {
				currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
			}else {
				addtypeface(currentfont, currentsize);
				currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
			}
		}
		
		changesize(size);
	}
	
	public static function changesize(t:Float) {
		if (t != currentsize){
			currentsize = t;
			if (currentfont != "null") {
				if (typefaceindex.exists(currentfont + "_" + Std.string(currentsize))) {
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}else {
					addtypeface(currentfont, currentsize);
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}
			}else {
			  addfont(null, t);
				setfont("Verdana", t);
			}
		}
	}
	
	private static function addfont(fontname:String, defaultsize:Float = 1) {
		fontfile.push(new Fontfile(fontname));
		if (fontname == null) fontname = "Verdana";
		fontfileindex.set(fontname, fontfile.length - 1);
		
		changesize(defaultsize);
	}
	
	private static function addtypeface(_name:String, _size:Float) {
		typeface.push(new Fontclass(_name, _size));
		typefaceindex.set(_name + "_" + Std.string(_size), typeface.length - 1);
	}
	
	/** Return a font's internal TTF name. Used for loading in fonts during setup. */
	public static function getfonttypename(fontname:String):String {
		trace("warning: unimplemented function getfonttypename");
		return "";
	}
	
	private static var fontfile:Array<Fontfile> = new Array<Fontfile>();
	private static var fontfileindex:Map<String,Int> = new Map<String,Int>();
	
	private static var typeface:Array<Fontclass> = new Array<Fontclass>();
	private static var typefaceindex:Map<String,Int> = new Map<String,Int>();
	
	private static var fontmatrix:Matrix = new Matrix();
	private static var currentindex:Int = -1;
	public static var currentfont:String = "null";
	public static var currentsize:Float = -1;

	private static var gfxstage:Stage;
	
	public static var LEFT:Int = -10000;
	public static var RIGHT:Int = -20000;
	public static var TOP:Int = -10000;
	public static var BOTTOM:Int = -20000;
	public static var CENTER:Int = -15000;
	
	private static var textalign:Int = -10000;
	private static var textrotate:Float = 0;
	private static var textrotatexpivot:Float = 0;
	private static var textrotateypivot:Float = 0;
	private static var tempxpivot:Float = 0;
	private static var tempypivot:Float = 0;
	
	//Text input variables
	public static var inputtext:String;
	private static var lastentry:String;
	#if haxegonweb
	public static var inputsound:Int;
	#end
	public static var inputmaxlength:Int;
	
	private static var input_textxp:Float;
	private static var input_textyp:Float;
	private static var input_responsexp:Float;
	private static var input_responseyp:Float;
	private static var input_textcol:Int;
	private static var input_responsecol:Int;
	private static var input_text:String;
	private static var input_response:String;
	private static var input_cursorglow:Int;
	private static var input_font:String;
	private static var input_textsize:Float;
	/** Non zero when an input string is being checked. So that I can use 
	 * the M and F keys without muting or changing to fullscreen.*/
	public static var input_show:Int;
}