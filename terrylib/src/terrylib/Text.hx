package terrylib;

import terrylib.util.*;
import openfl.Assets;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import openfl.text.*;

class Text {
	public static function init(stage:Stage):Void {
		drawto = Gfx.backbuffer;
		gfxstage = stage;
		enabletextfield();
	}
	
	//Text Input functions
	
	private static function enabletextfield():Void {
		gfxstage.addChild(inputField);
		inputField.border = true;
		inputField.width = Gfx.screenwidth;
		inputField.height = 20;
		inputField.x = 0;
		inputField.y = Gfx.screenheight + 10;
		inputField.type = TextFieldType.INPUT;
		inputField.visible = false;
		
		inputField.maxChars = 80;
		
		resetinput("");
	}
	
	private static function input_checkfortext():Void {
		gfxstage.focus = inputField;
		#if flash
		inputField.setSelection(inputField.text.length, inputField.text.length);
		#else
		inputField.setSelection(inputField.text.length, inputField.text.length);
		#end
		inputtext = inputField.text;
	}
	
	/** Return characters from the middle of a string. */
	public static function Mid(s:String, start:Int = 0, length:Int = 1):String {
		return s.substr(start,length);
	}
	
	/** Reverse a string. */
	public static function reversetext(t:String):String {
		var t2:String = "";
		
		for (i in 0...t.length) {
			t2 += Mid(t, t.length-i-1, 1);
		}
		return t2;
	}
	
	public static function resetinput(t:String):Void {
		#if flash
		inputField.text = t; inputtext = t;
		#else
		inputField.text = reversetext(t); inputtext = reversetext(t);
		#end
		input_show = 0;
	}
	
	public static function input(x:Int, y:Int, text:String, col:Int = 0xFFFFFF, responsecol:Int = 0xCCCCCC):Bool {
		input_show = 2;
		
		input_font = currentfont;
		input_textsize = currentsize;
		typeface[currentindex].tf.text = text + inputtext;
		x = alignx(x); y = aligny(y);
		input_textxp = x;
		input_textyp = y;
		
		typeface[currentindex].tf.text = text;
		input_responsexp = input_textxp + Std.int(typeface[currentindex].tf.textWidth);
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
		inputField.text = "";
		input_show = 0;
		
		return response;
	}
	
	public static function drawstringinput():Void {
		if (input_show > 0) {
			Text.changefont(input_font);
			Text.changesize(input_textsize);
			input_cursorglow++;
			if (input_cursorglow >= 96) input_cursorglow = 0;
			
			print(input_textxp, input_textyp, input_text, input_textcol);
			if (input_cursorglow % 48 < 24) {
				print(input_responsexp, input_responseyp, input_response, input_responsecol);
			}else {
				print(input_responsexp, input_responseyp, input_response + "_", input_responsecol);
			}
		}
		
		input_show--;
		if (input_show < 0) input_show = 0;
	}
	
	//Text Print functions
	public static function rprint(x:Int, y:Int, text:String, col:Int):Void {
		x = Std.int(x - len(text));
		print(x, y, text, col);
	}
	
	public static function len(t:String):Int {
		typeface[currentindex].tf.text = t;
		return Std.int(typeface[currentindex].tf.textWidth);
	}
	
	public static function height():Int {
		typeface[currentindex].tf.text = "???";
		return Std.int(typeface[currentindex].tf.textHeight);
	}
	
	private static function alignx(x:Int):Int {
		if (x == CENTER) return Gfx.screenwidthmid - Std.int(typeface[currentindex].tf.textWidth / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return Gfx.screenwidth - Std.int(typeface[currentindex].tf.textWidth);
		
		return x;
	}
	
	private static function aligny(y:Int):Int {
		if (y == CENTER) return Gfx.screenheightmid - Std.int(typeface[currentindex].tf.textHeight / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return Gfx.screenheight - Std.int(typeface[currentindex].tf.textHeight);
		
		return y;
	}
	
	private static function aligntextx(t:String, x:Int):Int {
		if (x == CENTER) return Std.int(len(t) / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return len(t);
		return x;
	}
	
	private static function aligntexty(y:Int):Int {
		if (y == CENTER) return Std.int(height() / 2);
		if (y == TOP || y == LEFT) return 0;
		if (y == BOTTOM || y == RIGHT) return height();
		return y;
	}
	
	public static function print(x:Int, y:Int, t:String, col:Int = 0xFFFFFF):Void {
		typeface[currentindex].tf.textColor = col;
		typeface[currentindex].tf.text = t;
		
		x = alignx(x); y = aligny(y);
		
		fontmatrix.identity();
		fontmatrix.translate(x, y);
		typeface[currentindex].tf.textColor = col;
		drawto.draw(typeface[currentindex].tf, fontmatrix);
	}
	
	public static function print_scale(x:Int, y:Int, t:String, col:Int, scale:Float, pivotx:Int, pivoty:Int):Void {
	  drawto = typeface[currentindex].tfbitmap;
		typeface[currentindex].clearbitmap();
		
		print(0, 0, t, col);
		
		x = alignx(x); y = aligny(y);
		pivotx = aligntextx(t, pivotx); pivoty = aligntexty(pivoty);
		
		fontmatrix.identity();
		fontmatrix.translate(-pivotx, -pivoty);
		fontmatrix.scale(scale, scale);
		fontmatrix.translate(x + pivotx, y + pivoty);
		drawto = Gfx.backbuffer;
		drawto.draw(typeface[currentindex].tfbitmap, fontmatrix);
	}
	
	public static function print_freescale(x:Int, y:Int, t:String, col:Int, xscale:Float, yscale:Float, pivotx:Int, pivoty:Int):Void {
	  drawto = typeface[currentindex].tfbitmap;
		typeface[currentindex].clearbitmap();
		
		print(0, 0, t, col);
		
		x = alignx(x); y = aligny(y);
		pivotx = aligntextx(t, pivotx); pivoty = aligntexty(pivoty);
		
		fontmatrix.identity();
		fontmatrix.translate(-pivotx, -pivoty);
		fontmatrix.scale(xscale, yscale);
		fontmatrix.translate(x + pivotx, y + pivoty);
		drawto = Gfx.backbuffer;
		drawto.draw(typeface[currentindex].tfbitmap, fontmatrix);
	}
	
	public static function print_rotate(x:Int, y:Int, t:String, col:Int, rotate:Int, pivotx:Int, pivoty:Int):Void {
	  drawto = typeface[currentindex].tfbitmap;
		typeface[currentindex].clearbitmap();
		
		print(0, 0, t, col);
		
		x = alignx(x); y = aligny(y);
		pivotx = aligntextx(t, pivotx); pivoty = aligntexty(pivoty);
		
		fontmatrix.identity();
		fontmatrix.translate(-pivotx, -pivoty);
		fontmatrix.rotate((rotate * 3.1415) / 180);
		fontmatrix.translate(x + pivotx, y + pivoty);
		drawto = Gfx.backbuffer;
		drawto.draw(typeface[currentindex].tfbitmap, fontmatrix);
	}
	
	public static function print_scale_rotate(x:Int, y:Int, t:String, col:Int, scale:Float, rotate:Int, pivotx:Int, pivoty:Int):Void {
	  drawto = typeface[currentindex].tfbitmap;
		typeface[currentindex].clearbitmap();
		
		print(0, 0, t, col);
		
		x = alignx(x); y = aligny(y);
		pivotx = aligntextx(t, pivotx); pivoty = aligntexty(pivoty);
		
		fontmatrix.identity();
		fontmatrix.translate(-pivotx, -pivoty);
		fontmatrix.scale(scale, scale);
		fontmatrix.rotate((rotate * 3.1415) / 180);
		fontmatrix.translate(x + pivotx, y + pivoty);
		drawto = Gfx.backbuffer;
		drawto.draw(typeface[currentindex].tfbitmap, fontmatrix);
	}
	
	public static function print_freescale_rotate(x:Int, y:Int, t:String, col:Int, xscale:Float, yscale:Float, rotate:Int, pivotx:Int, pivoty:Int):Void {
	  drawto = typeface[currentindex].tfbitmap;
		typeface[currentindex].clearbitmap();
		
		print(0, 0, t, col);
		
		x = alignx(x); y = aligny(y);
		pivotx = aligntextx(t, pivotx); pivoty = aligntexty(pivoty);
		
		fontmatrix.identity();
		fontmatrix.translate(-pivotx, -pivoty);
		fontmatrix.scale(xscale, yscale);
		fontmatrix.rotate((rotate * 3.1415) / 180);
		fontmatrix.translate(x + pivotx, y + pivoty);
		drawto = Gfx.backbuffer;
		drawto.draw(typeface[currentindex].tfbitmap, fontmatrix);
	}
	
	public static function changefont(t:String):Void {
		if(t != currentfont){
			currentfont = t;
			if (currentsize != -1) {
				if (typefaceindex.exists(currentfont + "_" + Std.string(currentsize))) {
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}else {
					addtypeface(currentfont, currentsize);
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}
			}
		}
	}
	
	public static function changesize(t:Int):Void {
		if (t != currentsize){
			currentsize = t;
			if (currentfont != "null") {
				if (typefaceindex.exists(currentfont + "_" + Std.string(currentsize))) {
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}else {
					addtypeface(currentfont, currentsize);
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}
			}
		}
	}
	
	public static function addfont(t:String, defaultsize:Int):Void {
		fontfile.push(new Fontfile(t));
		fontfileindex.set(t, fontfile.length - 1);
		currentfont = t;
		
		changesize(defaultsize);
	}
	
	private static function addtypeface(_name:String, _size:Int):Void {
		typeface.push(new Fontclass(_name, _size));
		typefaceindex.set(_name+"_" + Std.string(_size), typeface.length - 1);
	}
	
	/** Return a font's internal TTF name. Used for loading in fonts during setup. */
	public static function getfonttypename(fontname:String):String {
		return fontfile[Text.fontfileindex.get(fontname)].typename;
	}
	
	private static var fontfile:Array<Fontfile> = new Array<Fontfile>();
	private static var fontfileindex:Map<String,Int> = new Map<String,Int>();
	
	private static var typeface:Array<Fontclass> = new Array<Fontclass>();
	private static var typefaceindex:Map<String,Int> = new Map<String,Int>();
	
	private static var fontmatrix:Matrix = new Matrix();
	private static var currentindex:Int = -1;
	public static var currentfont:String = "null";
	public static var currentsize:Int = -1;
	private static var gfxstage:Stage;
	
	public static var drawto:BitmapData;
	
	public static var LEFT:Int = -20000;
	public static var RIGHT:Int = -20001;
	public static var TOP:Int = -20002;
	public static var BOTTOM:Int = -20003;
	public static var CENTER:Int = -20004;
	
	//Text input variables
	private static var inputField:TextField = new TextField();
	private static var inputtext:String;
	private static var lastentry:String;
	
	private static var input_textxp:Int;
	private static var input_textyp:Int;
	private static var input_responsexp:Int;
	private static var input_responseyp:Int;
	private static var input_textcol:Int;
	private static var input_responsecol:Int;
	private static var input_text:String;
	private static var input_response:String;
	private static var input_cursorglow:Int;
	private static var input_font:String;
	private static var input_textsize:Int;
	/** Non zero when an input string is being checked. So that I can use 
	 * the M and F keys without muting or changing to fullscreen.*/
	public static var input_show:Int;
}