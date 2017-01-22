package haxegon;

import openfl.Assets;
import openfl.geom.Matrix;
import openfl.text.Font;
import starling.display.*;
import starling.utils.HAlign;
import starling.text.*;
import starling.textures.*;

@:access(haxegon.Text)
class Fontclass {
	public function new(_name:String, _size:Float) {
		autosize = true;
		type = Text.fontfile[Text.fontfileindex.get(_name)].type;
		if (type == "bitmap") {
			loadbitmapfont(_name, _size);
		}else if (type == "ttf") {
			loadbitmapfont(_name, _size);
		}
	}
	
	public function loadbitmapfont(_name:String, _size:Float) {
		name = _name;
		size = _size;
		
		fontfile = Text.fontfile[Text.fontfileindex.get(_name)];
		
		tf = new TextField(Gfx.screenwidth, Gfx.screenheight, "???", fontfile.typename, fontfile.sizescale * size);
		tf.vAlign = "top";
		tf.hAlign = "left";
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
	}
	
	public function updatewidth(v:Bool) {
		autosize = v;
		if (v) {
			tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		}else {
		  tf.autoSize = TextFieldAutoSize.VERTICAL;
			tf.width = Text.wordwrapwidth;		
		}
	}
	
	public var width(get, never):Float;
	
	function get_width():Float {
		if (autosize) {
			tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		}else {
		  tf.autoSize = TextFieldAutoSize.VERTICAL;
			tf.width = Text.wordwrapwidth;
		}
		return Std.int(tf.width);
	}
	
	public var height(get, never):Float;
	
	function get_height():Float {
		if (autosize) {
			tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		}else {
		  tf.autoSize = TextFieldAutoSize.VERTICAL;
			tf.width = Text.wordwrapwidth;
		}
		return Std.int(tf.height);
	}
	
	public var tf:TextField;
	public var fontfile:Fontfile;
	
	public var name:String;
	public var type:String;
	public var size:Float;
	
	public var autosize:Bool;
}

@:access(haxegon.Gfx)
@:access(haxegon.Text)
@:access(haxegon.Data)
class Fontfile {
	public function new(?_file:String) {
		if (_file == null) {
			type = "ttf";
			
			filename = "";
			typename = "Verdana";
			sizescale = 1;
		}else	if (Data.assetexists("data/graphics/fonts/" + _file + "/" + _file + ".fnt")) {
			type = "bitmap";
			
			var fontdata:String = Data.gettextasset("data/graphics/fonts/" + _file + "/" + _file + ".fnt");
			fontxml = Xml.parse(fontdata).firstElement();
			typename = fontxml.elementsNamed("info").next().get("face");
			pngname = Xml.parse(fontdata).firstElement()
			               .elementsNamed("pages").next().elementsNamed("page").next().get("file");
			if (pngname == null) {
				Debug.log("ERROR: Bitmap font XML file \"" + _file + ".fnt\" does not reference a .png file.");
			}
			if (S.right(pngname, 4) == ".png") {
				pngname = S.left(pngname, pngname.length - 4);
			}
			sizescale = Std.parseInt(fontxml.elementsNamed("info").next().get("size"));
			
			if (Gfx.imageindex.exists("fonts/" + _file + "/" + pngname)) {
			  //We've already loaded in the font png in a packed texture!	
				fonttex = Gfx.starlingassets.getTexture("fonts/" + _file + "/" + pngname);
			}else{
				fonttex = Texture.fromBitmapData(Data.getgraphicsasset("data/graphics/fonts/" + _file + "/" + pngname + ".png"), false);
			}
			bitmapfont = new BitmapFont(fonttex, fontxml);
			TextField.registerBitmapFont(bitmapfont);
		}else {
		  type = "ttf";
			
			filename = "data/graphics/fonts/" + _file + "/" + _file + ".ttf";
			try {
				font = Data.getfontasset(filename);
				typename = font.fontName;
			}catch (e:Dynamic) {
				Debug.log("ERROR: Cannot set font to \"" + _file + "\", no TTF or Bitmap Font found.");
			}
			sizescale = 1;
		}
	}
	
	public var typename:String;
	
	public var bitmapfont:BitmapFont;
	public var fontxml:Xml;
	public var fonttex:Texture;
	private var pngname:String;
	public var sizescale:Int;
	//public var fontimage:BitmapData;
	
	public var font:Font;
	public var filename:String;
	public var type:String;
}

@:access(haxegon.Input)
@:access(haxegon.Gfx)
class Text {
	private static function init(stage:Stage) {
		gfxstage = stage;
		input_cursorglow = 0;
		inputmaxlength = 40;
		wordwrapwidth = 0;
	}
	
	public static function align(a:Int) {
	  textalign = a;	
	}
	
	public static function rotation(a:Float, xpivot:Int = -15000, ypivot:Int = -15000) {
	  textrotate = a;
		textrotatexpivot = xpivot;
		textrotateypivot = ypivot;
	}
	
	private static function input_checkfortext() {
		inputtext = Input.keybuffer;
	}
	
	public static function input(x:Float, y:Float, prompt:String, questioncolor:Int = 0xFFFFFF, answercolor:Int  = 0xCCCCCC):Bool {
		input_show = 2;
		
		input_font = currentfont;
		input_textsize = currentsize;
		typeface[currentindex].tf.text = prompt + inputtext;
		x = alignx(x); y = aligny(y);
		input_textxp = x;
		input_textyp = y;
		
		typeface[currentindex].tf.text = prompt;
		input_responsexp = input_textxp + Math.floor(typeface[currentindex].width);
		input_responseyp = y;
		
		input_text = prompt;
		input_response = inputtext;
		input_textcol = questioncolor;
		input_responsecol = answercolor;
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
	
	private static function drawstringinput() {
		Gfx.endquadbatch();
		//if (Gfx.drawstate != Gfx.DRAWSTATE_TEXT) Gfx.endquadbatch();
		//Gfx.updatequadbatch();
		//Gfx.drawstate = Gfx.DRAWSTATE_TEXT;
		
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
	public static var wordwrap(get, set):Int;
	
	static function get_wordwrap():Int {
	  return wordwrapwidth;	
	}
	
	static function set_wordwrap(textwidth:Int) {
		if (textwidth < 0) {
			Debug.log("Error: Text.wordwrap must be a number greater than 0.");	
			wordwrapwidth = 0;
		}else{
			wordwrapwidth = textwidth;
		}
		
		return wordwrapwidth;
	}
	
	private static function currentwidth():Float {
		return typeface[currentindex].width;
	}
	
	private static function currentheight():Float {
		return typeface[currentindex].height;
	}
	
	public static function width(text:String):Float {
		if (wordwrapwidth > 0) {
			typeface[currentindex].updatewidth(false);
		}else {
			typeface[currentindex].updatewidth(true);
		}
		
		typeface[currentindex].tf.text = text;
		return typeface[currentindex].width;
	}
	
	public static function height(?text:String):Float {
		if (text == null) text = "?";
		if (wordwrapwidth > 0) {
			typeface[currentindex].updatewidth(false);
		}else {
			typeface[currentindex].updatewidth(true);
		}
		
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
	
	public static function display(x:Float, y:Float, text:String, color:Int = 0xFFFFFF) {
		if (text == "") return;
		Gfx.endquadbatch();
		//Future developments!
		//if (Gfx.drawstate != Gfx.DRAWSTATE_TEXT) Gfx.endquadbatch();
		//Gfx.updatequadbatch();
		//Gfx.drawstate = Gfx.DRAWSTATE_TEXT;
		
		if (typeface.length == 0) {
		  defaultfont();	
		}
		
		typeface[currentindex].tf.color = color;
		typeface[currentindex].tf.text = text;
		
		if (textalign == LEFT) typeface[currentindex].tf.hAlign = HAlign.LEFT;
		if (textalign == CENTER) typeface[currentindex].tf.hAlign = HAlign.CENTER;
		if (textalign == RIGHT)	typeface[currentindex].tf.hAlign = HAlign.RIGHT;
		if (wordwrapwidth > 0) {
			typeface[currentindex].updatewidth(false);
		}else {
			typeface[currentindex].updatewidth(true);
		}
		
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
		// Clumsy work around to force haxegon to change to the next draw call on TTF fonts.
		// to do: implement a pooling system for ttf fonts so that this isn't required.
		if (typeface[currentindex].type == "ttf") {
			Gfx.drawto.draw(typeface[currentindex].tf, fontmatrix);
		  Gfx.fillbox(-1, -1, 1, 1, Col.RED);	
		}else {			
			Gfx.drawto.draw(typeface[currentindex].tf, fontmatrix);
			//Gfx.quadbatch.addQuadBatch(typeface[currentindex].tf.mQuadBatch, 1.0, fontmatrix);	
		}
	}
	
	private static function defaultfont() {
		addfont(null, 24);
		setfont("Verdana", 24);
	}
	
	private static function setfont(fontname:String, size:Float = 1) {
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
	
	private static function changesize(t:Float) {
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
	
	public static var font(get, set):String;
	
	static function get_font():String {
		return currentfont;
	}
	
	static function set_font(fontname:String):String {
		if (fontname == "" || fontname.toLowerCase() == "verdana") fontname = "Verdana";
		if (fontname == currentfont) return currentfont;
		
		//if (Gfx.drawstate != Gfx.DRAWSTATE_TEXT) Gfx.endquadbatch();
		setfont(fontname, 1);
		return currentfont;
	}
	
	public static var size(get, set):Float;
	
	static function get_size():Float {
		return currentsize;
	}
	
	static function set_size(fontsize:Float):Float {
	  if (currentsize != fontsize) {
			//if (Gfx.drawstate != Gfx.DRAWSTATE_TEXT) Gfx.endquadbatch();	
      changesize(fontsize);
    }
		return currentsize;
	}
	
	private static var fontfile:Array<Fontfile> = new Array<Fontfile>();
	private static var fontfileindex:Map<String,Int> = new Map<String,Int>();
	
	private static var typeface:Array<Fontclass> = new Array<Fontclass>();
	private static var typefaceindex:Map<String,Int> = new Map<String,Int>();
	
	private static var fontmatrix:Matrix = new Matrix();
	private static var currentindex:Int = -1;
	private static var currentfont:String = "null";
	private static var currentsize:Float = -1;

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
	
	private static var wordwrapwidth:Int = 0;
}