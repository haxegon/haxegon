package haxegon;

import openfl.Vector;
import haxegon.embeddedassets.DefaultFont;
import openfl.geom.Matrix;
import openfl.text.Font;
import starling.display.*;
import starling.utils.Align;
import starling.text.*;
import starling.textures.*;

class HighResTrueTypeCompositor extends TrueTypeCompositor{
  public function HighResTrueTypeCompositor(){}

  override public function fillMeshBatch(meshBatch:MeshBatch, width:Float, height:Float,
																				 text:String, format:TextFormat,
																				 options:TextOptions = null){
    options.textureScale *= 3;
    super.fillMeshBatch(meshBatch, width, height, text, format, options);
  }
}

@:access(haxegon.Text)
class Fontclass {
	public function new(_name:String, _size:Float) {
		type = Text.fontfile[Text.fontfileindex.get(_name.toLowerCase())].type;
		loadfont(_name, _size);
		nexttextfield();
	}
	
	public function loadfont(_name:String, _size:Float) {
		name = _name.toLowerCase();
		size = _size;
		
		fontfile = Text.fontfile[Text.fontfileindex.get(_name)];
		tflist = [];
		tflist.push(inittextfield());
	}
	
	private function inittextfield():TextField {
		var newtf:TextField = new TextField(1, 1, "XYZ");
		newtf.format.setTo(fontfile.typename, (fontfile.sizescale * size));
		newtf.format.horizontalAlign = Align.LEFT;
		newtf.format.verticalAlign = Align.TOP;
		
		return newtf;
	}
	
	private function reset() {
		currenttextfield = -1;
	}
	
	private function nexttextfield() {
	  currenttextfield++;
		if (currenttextfield >= tflist.length) tflist.push(inittextfield());
		
		tf = tflist[currenttextfield];
	}
	
	public function updatebounds() {
		tf.width = Gfx.screenwidth;
		tf.height = Gfx.screenheight;
		
		tf.wordWrap = (Text.wordwrapwidth > 0);
		tf.width = (Text.wordwrapwidth > 0)?Text.wordwrapwidth:Gfx.screenwidth;
	}
	
	public var width(get, never):Float;
	
	function get_width():Float {
		return tf.textBounds.width;
	}
	
	public var height(get, never):Float;
	
	function get_height():Float {
	  return tf.textBounds.height;
	}
	
	public var tf:TextField;
	
	private var tflist:Array<TextField>;
	private var currenttextfield:Int = -1;
	public var fontfile:Fontfile;
	
	public var name:String;
	public var type:String;
	public var size:Float;
}

@:access(haxegon.Gfx)
@:access(haxegon.Text)
@:access(haxegon.Data)
class Fontfile {
	public function new(?_file:String, usehighrescompositor:Bool = false) {
		if (_file == null) {
			//Use the embeded "default" pixel font
			type = "bitmap";
			
			fontxml = Xml.parse(DefaultFont.xmlstring).firstElement();
			typename = fontxml.elementsNamed("info").next().get("face");
			sizescale = Std.parseInt(fontxml.elementsNamed("info").next().get("size"));
			fonttex = Texture.fromBitmapData(DefaultFont.bitmapdata, false);
			bitmapfont = new BitmapFont(fonttex, fontxml);
			TextField.registerCompositor(bitmapfont, bitmapfont.name);
			
			filename = "";
			typename = "default";
			sizescale = Std.parseInt(fontxml.elementsNamed("info").next().get("size"));
		}else	if (Data.assetexists("data/fonts/" + _file + ".fnt")) {
			type = "bitmap";
			
			var fontdata:String = Data.gettextasset("data/fonts/" + _file + ".fnt");
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
			
			if (Gfx.imageindex.exists("fonts/" + pngname)) {
			  //We've already loaded in the font png in a packed texture!	
				fonttex = Gfx.starlingassets.getTexture("fonts/" + pngname);
			}else{
				fonttex = Texture.fromBitmapData(Data.getgraphicsasset("data/fonts/" + pngname + ".png"), false);
			}
			bitmapfont = new BitmapFont(fonttex, fontxml);
			TextField.registerCompositor(bitmapfont, bitmapfont.name);
		}else {
			//Use ttf font
		  type = "ttf";
			filename = "data/fonts/" + _file + ".ttf";
			try {
				font = Data.getfontasset(filename);
				typename = font.fontName;
				if (usehighrescompositor){
					TextField.registerCompositor(new HighResTrueTypeCompositor(), typename);
				}
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
	
	public var font:Font;
	public var filename:String;
	public var type:String;
}

@:access(haxegon.Input)
@:access(haxegon.Fontclass)
@:access(haxegon.Gfx)
@:access(starling.text.TextField)
class Text {
	private static function setstage(stage:Stage) {
		gfxstage = stage;
	}
	
	private static function init(){
		inputfocus = false;
		wordwrapwidth = 0;
		inputmaxlength = 0;
	}
	
	public static function rotation(a:Float, xpivot:Int = 0, ypivot:Int = 0) {
	  textrotate = a;
		textrotatexpivot = xpivot;
		textrotateypivot = ypivot;
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
		typeface[currentindex].updatebounds();
		
		if (typeface[currentindex].type == "bitmap"){
			var realwidth:Float = 0;
			
			var bitmapcharlocations:Vector<BitmapCharLocation> = 
			typeface[currentindex].fontfile.bitmapfont.arrangeChars(Gfx.screenwidth, Gfx.screenheight, text, typeface[currentindex].tf.format, null);
			
			for (i in 0 ... bitmapcharlocations.length){
			  realwidth += bitmapcharlocations[i].char.xAdvance * currentsize;
			}
			
			BitmapCharLocation.rechargePool();
			return realwidth;
		}else{
			typeface[currentindex].tf.text = text;
			return typeface[currentindex].width;
		}
	}
	
	public static function height(?text:String):Float {
		if (text == null) text = "?";
		typeface[currentindex].updatebounds();
		
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
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(height(t) / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + height(t);
			}
		}
		
		return y;
	}
	
	private static function defaultfont() {
		addfont(null, 1);
		setfont("default", 1);
	}
	
	public static function setfont(fontname:String, size:Float = 1, highres:Bool = false) {
		if (!fontfileindex.exists(fontname)) {
			addfont(fontname, size, highres);
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
		if (t != currentsize) {
			if (t == -1) {
			  t = 1;
				if (fontfileindex.exists(currentfont)) {
				  if (fontfile[fontfileindex.get(currentfont)].type == "ttf") {
					  t = 24;	
					}
				}else {
				  Debug.log("Error: changesize called on a font that hasn't been loaded yet");	
				}
			}
			
			fontlastsize.set(currentfont, t);	
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
				setfont("default", t);
			}
		}
	}
	
	private static function resettextfields() {
	  for (i in 0 ... typeface.length) {
		  typeface[i].reset();	
		}
	}
	
	private static function addfont(fontname:String, defaultsize:Float = -1, highres:Bool = false) {
		fontfile.push(new Fontfile(fontname, highres));
		if (fontname == null) fontname = "default";
		fontfileindex.set(fontname, fontfile.length - 1);
		
		if (defaultsize == -1) {
			if (fontfile[fontfile.length - 1].type == "ttf") {
				defaultsize = 24;	
			}else {
				defaultsize = 1;
			}
		}
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
		fontname = fontname.toLowerCase();
		if (fontname == "") fontname = "default";
		if (fontname == currentfont) return currentfont;
		
		setfont(fontname, fontlastsize.exists(fontname)?fontlastsize.get(fontname): -1);
		return currentfont;
	}
	
	public static var size(get, set):Float;
	
	static function get_size():Float {
		return currentsize;
	}
	
	static function set_size(fontsize:Float):Float {
		if (currentsize != fontsize) {
      changesize(fontsize);
    }
		return currentsize;
	}
	
	public static function input(x:Float, y:Float, col:Int = 0xFFFFFF, alpha:Float = 1.0):Bool{
		if (!inputfocus){
			inputfocus = true;
			inputbuffer = "";
		}
		
		if (inputmaxlength > 0){
			if (inputbuffer.length > inputmaxlength){
				inputbuffer = S.left(inputbuffer, inputmaxlength);
			}
		}
		
		if(flash.Lib.getTimer() % 400 > 200 && (inputmaxlength == 0)?true:(inputbuffer.length < inputmaxlength)){
			Text.display(x, y, inputbuffer, col, alpha);
			var oldalign:Int = align;
			align = LEFT;
			var underscoreoffset:Float = alignx(x) - aligntextx(inputbuffer, oldalign);
			Text.display(underscoreoffset + width(inputbuffer), y, "_", col, alpha);
			align = oldalign;
		}else{
			Text.display(x, y, inputbuffer, col, alpha);
		}
		
		if (Input.justpressed(Key.ENTER) && inputbuffer != "") {
			return true;
		}
		return false;
	}
	
	public static var inputresult(get, null):String;
	
	static function get_inputresult():String {
		var returnval:String = (inputmaxlength == 0)?inputbuffer:S.left(inputbuffer, inputmaxlength);
		inputbuffer = "";
		inputfocus = false;
		return returnval;
	}
	
	public static var inputbuffer:String = "";
	
	private static var fontfile:Array<Fontfile> = new Array<Fontfile>();
	private static var fontfileindex:Map<String,Int> = new Map<String,Int>();
	private static var fontlastsize:Map<String,Float> = new Map<String,Float>();
	
	private static var typeface:Array<Fontclass> = new Array<Fontclass>();
	private static var typefaceindex:Map<String,Int> = new Map<String,Int>();
	
	private static var fontmatrix:Matrix = new Matrix();
	private static var currentindex:Int = -1;
	private static var currentfont:String = "null";
	private static var currentsize:Float = -1;

	private static var gfxstage:Stage;
	
	public static var LEFT:Int = 0;
	public static var TOP:Int = 0;
	public static var CENTER:Int = -200000;
	public static var RIGHT:Int = -300000;
	public static var BOTTOM:Int = -300000;
	
	public static var align:Int = 0;
	private static var textrotate:Float = 0;
	private static var textrotatexpivot:Float = 0;
	private static var textrotateypivot:Float = 0;
	private static var tempxpivot:Float = 0;
	private static var tempypivot:Float = 0;
	
	private static var wordwrapwidth:Int = 0;
	private static var inputfocus:Bool;
	public static var inputmaxlength:Int;
	
	#if neko
	public static function display(x:Float, y:Float, text:Dynamic, color:Int = 0xFFFFFF, alpha:Float = 1.0) {
		if (Std.is(text, Array)){
			text = text.toString();
		}else if (!Std.is(text, String)){
			text = Std.string(text);
		}
	#elseif html5
	public static function display(x:Float, y:Float, text:Dynamic, color:Int = 0xFFFFFF, alpha:Float = 1.0) {
		if (!Std.is(text, String)){
			text = Std.string(text);
		}
	#else
	public static function display(x:Float, y:Float, text:String, color:Int = 0xFFFFFF, alpha:Float = 1.0) {
	#end
		if (text == "") return;
		Gfx.endmeshbatch(); // We don't use Gfx.meshbatch, so ensure it's finished rendering before we draw any text
		
		x = Math.ffloor(x);
		y = Math.ffloor(y);
		
		if (typeface.length == 0) {
		  defaultfont();	
		}
		
		typeface[currentindex].nexttextfield();
		typeface[currentindex].tf.format.color = color;
		typeface[currentindex].tf.text = text;
		
		typeface[currentindex].updatebounds();
		
		x = alignx(x); y = aligny(y);
		x -= aligntextx(text, align);
		
		fontmatrix.identity();
		
		if (textrotate != 0) {
			if (textrotatexpivot != 0.0) tempxpivot = aligntextx(text, textrotatexpivot);
			if (textrotateypivot != 0.0) tempypivot = aligntexty(text, textrotateypivot);
			fontmatrix.translate( -tempxpivot, -tempypivot);
			fontmatrix.rotate((textrotate * 3.1415) / 180);
			fontmatrix.translate( tempxpivot, tempypivot);
		}
		
		fontmatrix.translate(x, y);
		if (typeface[currentindex].type == "ttf") {
			Gfx.drawto.draw(typeface[currentindex].tf, fontmatrix, alpha);
		}else {
			if (alpha != 1.0){
				Gfx.drawto.draw(typeface[currentindex].tf, fontmatrix, alpha);
			}else{
				/* TO DO */
			  //typeface[currentindex].tf.createComposedContents();
			  //Gfx.meshbatch.addQuadBatch(typeface[currentindex].tf.mQuadBatch, 1.0, fontmatrix);
				Gfx.drawto.draw(typeface[currentindex].tf, fontmatrix, alpha);
			}
		}
	}
}
