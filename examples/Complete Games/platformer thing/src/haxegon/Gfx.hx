package haxegon;

#if haxegon3D
import haxegon3D.*;
#end

import haxegon.util.*;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import openfl.text.*;
import openfl.Assets;
import openfl.Lib;
import openfl.system.Capabilities;

#if haxegon3D
@:access(haxegon3D.Gfx3D)
#end
class Gfx {
	public static var LEFT:Int = -10000;
	public static var RIGHT:Int = -20000;
	public static var TOP:Int = -10000;
	public static var BOTTOM:Int = -20000;
	public static var CENTER:Int = -15000;
	
	public static var screenwidth:Int;
	public static var screenheight:Int;
	public static var screenwidthmid:Int;
	public static var screenheightmid:Int;
	public static var clearscreeneachframe:Bool;
	
	public static var screenscale:Int;
	public static var devicexres:Int;
	public static var deviceyres:Int;
	public static var fullscreen:Bool;
	
	public static var currenttilesetname:String;
	public static var backbuffer:BitmapData;
	public static var drawto:BitmapData;
	
	/** Create a screen with a given width, height and scale. Also inits Text. */
	public static function resizescreen(width:Float, height:Float, scale:Int = 1) {
		initgfx(Std.int(width), Std.int(height), scale);
		#if haxegonweb
		#if (js || html5)
			onresize(null);
		#end
		#end
		Text.init(gfxstage);
		showfps = false;
		gfxstage.addChild(screen);
		
		updategraphicsmode();
	}
	
	public static function setfullscreen(fs:Bool) {
		fullscreen = fs;
		updategraphicsmode();
	}
	
	public static function getscreenx(_x:Float) : Int {
		return Math.floor((_x - screen.x) * screenwidth / screen.width);
	}

	public static function getscreeny(_y:Float) : Int {
		return Math.floor((_y - screen.y) * screenheight / screen.height);
	}
	
	public static var showfps:Bool;
	private static var render_fps:Int;
	private static var render_fps_max:Int = -1;
	private static var update_fps:Int;
	private static var update_fps_max:Int = -1;
	public static function fps():Int {
		return render_fps_max;
	}
	public static function updatefps():Int {
		return update_fps_max;
	}
	
	//** Clear all rotations, scales and image colour changes */
	private static function reset() {
		transform = false;
		imagerotate = 0; 
		imagerotatexpivot = 0; imagerotateypivot = 0;
		imagexscale = 1.0; imageyscale = 1.0;
		imagescalexpivot = 0; imagescaleypivot = 0;
		
		coltransform = false;
		imagealphamult = 1.0;	imageredmult = 1.0;	imagegreenmult = 1.0;	imagebluemult = 1.0;
		imageredadd = 0.0; imagegreenadd = 0.0; imageblueadd = 0.0;
	}
	
	/** Called when a transform takes place to check if any transforms are active */
	private static function reset_ifclear() {
	  if (imagerotate == 0) {
		  if (imagexscale == 1.0) {
				if (imageyscale == 1.0) {
					transform = false;
				}
			}
		}
		
		if (imagealphamult == 1.0) {
		  if (imageredmult == 1.0 && imagegreenmult == 1.0 && imagebluemult == 1.0 && imageredadd == 0.0 && imagegreenadd == 0.0 && imageblueadd == 0.0) {
			  coltransform = false;	
			}
		}
	}
	
	/** Rotates image drawing functions. */
	public static function rotation(angle:Float, xpivot:Float = -15000, ypivot:Float = -15000) {
	  imagerotate = angle;
		imagerotatexpivot = xpivot;
		imagerotateypivot = ypivot;
		transform = true;
		reset_ifclear();
	}
	
	/** Scales image drawing functions. Optionally takes a second argument 
	 * to scale X and Y seperately. */
	public static function scale(xscale:Float, yscale:Float, xpivot:Float = -10000, ypivot:Float = -10000) {
		imagexscale = xscale;
		imageyscale = yscale;
		imagescalexpivot = xpivot;
		imagescaleypivot = ypivot;
		
		transform = true;
		reset_ifclear();
	}
	
	/** Set an alpha multipler for image drawing functions. */
	public static function imagealpha(a:Float) {
	  imagealphamult = a;
		coltransform = true;
		reset_ifclear();
	}
	
	/** Set a colour multipler and offset for image drawing functions. */
	public static function imagecolor(c:Int = 0xFFFFFF, add:Int = 0x000000) {
		#if flash
		if (getred(c) > 0) {
			imageredmult = getred(c) / 254.94;
			imageredadd = getred(add) + 1;
		} else {
			imageredmult = 0;
			imageredadd = getred(add);
		}
		if (getgreen(c) > 0) {
			imagegreenmult = getgreen(c) / 254.94;
			imagegreenadd = getgreen(add) + 1;
		} else {
			imagegreenmult = 0;
			imagegreenadd = getgreen(add);
		}
		if (getblue(c) > 0) {
			imagebluemult = getblue(c) / 254.94;
			imageblueadd = getblue(add) + 1;
		} else {
			imagebluemult = 0;
			imageblueadd = getblue(add);
		}
		#else
		imageredmult = getred(c) / 255;
		imagegreenmult = getgreen(c) / 255;
		imagebluemult = getblue(c) / 255;
		imageredadd = getred(add);
		imagegreenadd = getgreen(add);
		imageblueadd = getblue(add);
		#end
		coltransform = true;
		reset_ifclear();
	}
	
	/** Change the tileset that the draw functions use. */
	#if !haxegonweb
	public static function changetileset(tilesetname:String) {
		if (currenttilesetname != tilesetname) {
			if(tilesetindex.exists(tilesetname)){
				currenttileset = tilesetindex.get(tilesetname);
				currenttilesetname = tilesetname;
			}else {
				throw("ERROR: Cannot change to tileset \"" + tilesetname + "\", no tileset with that name found.");
			}
		}
	}
	#else
	public static function changetileset(tilesetname:String) {
		//Do nothing in web version
	}
	#end
	
	#if !haxegonweb
	public static function numberoftiles():Int {
		return tiles[currenttileset].tiles.length;
	}
	#end
		
	/** Makes a tile array from a given image. */
	#if haxegonweb
	public static function loadtiles(imagename:String, width:Int, height:Int, altlabel:String = "") {
		Webdebug.log("Error: \"loadtiles\" function not available in webscript version.");
	}
	#else
	public static function loadtiles(imagename:String, width:Int, height:Int, altlabel:String = "") {
		buffer = new Bitmap(Assets.getBitmapData("data/graphics/" + imagename + ".png")).bitmapData;
		if (buffer == null) {
			throw("ERROR: In loadtiles, cannot find data/graphics/" + imagename + ".png.");
			return;
		}
		if (altlabel != "") imagename = altlabel;
		
		var tiles_rect:Rectangle = new Rectangle(0, 0, width, height);
		tiles.push(new haxegon.util.Tileset(imagename, width, height));
		tilesetindex.set(imagename, tiles.length - 1);
		currenttileset = tiles.length - 1;
		
		var tilerows:Int;
		var tilecolumns:Int;
		tilecolumns = Std.int((buffer.width - (buffer.width % width)) / width);
		tilerows = Std.int((buffer.height - (buffer.height % height)) / height);
		
		for (j in 0 ... tilerows) {
			for (i in 0 ... tilecolumns) {
				var t:BitmapData = new BitmapData(width, height, true, 0x000000);
				settrect(i * width, j * height, width, height);
				t.copyPixels(buffer, trect, tl);
				tiles[currenttileset].tiles.push(t);
			}
		}
		
		changetileset(imagename);
	}
	
	/* Add some blank tiles to the end of a tileset*/ 
	public static function addblanktiles(imagename:String, num:Int) {
		var w:Int = tiles[tilesetindex.get(imagename)].tiles[0].width;
		var h:Int = tiles[tilesetindex.get(imagename)].tiles[0].height;
		for(i in 0 ... num){
			tiles[tilesetindex.get(imagename)].tiles.push(new BitmapData(w, h, true, 0x000000));
		}
	}
	#end
	
	#if !haxegonweb
	/** Creates a blank tileset, with the name "imagename", with each tile a given width and height, containing "amount" tiles. */
	public static function createtiles(imagename:String, width:Float, height:Float, amount:Int) {
		var exindex:Null<Int> = tilesetindex.get(imagename);
		if (exindex == null) {
			tiles.push(new haxegon.util.Tileset(imagename, Std.int(width), Std.int(height)));
			tilesetindex.set(imagename, tiles.length - 1);
			currenttileset = tiles.length - 1;
			
			for (i in 0 ... amount) {
				var t:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0x000000);
				tiles[currenttileset].tiles.push(t);
			}
			
			changetileset(imagename);
		}else {
			changetileset(imagename);
			for (i in 0 ... amount) {
			  tiles[currenttileset].tiles[i].dispose();
			}
			
			tiles[currenttileset] = new haxegon.util.Tileset(imagename, Std.int(width), Std.int(height));
			
			for (i in 0 ... amount) {
				var t:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0x000000);
				tiles[currenttileset].tiles.push(t);
			}
		}
	}
	
	/** Returns the width of a tile in the current tileset. */
	public static function tilewidth():Int {
		return tiles[currenttileset].width;
	}
	
	/** Returns the height of a tile in the current tileset. */
	public static function tileheight():Int {
		return tiles[currenttileset].height;
	}
	#end
	
	/** Loads an image into the game. */
	#if haxegonweb
	private static var BASE64:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZàáâäæãåøèéöü";
	public static var KEEPCOL:Int = -1;
	
	private static function convertobinary(t:Int, len:Int):String {
		var endstring:String = "";
		var currentbit:Int;
		
		while (t > 0) {
			currentbit = t % 2;
			endstring = Convert.tostring(currentbit) + endstring;
			t = t - currentbit;
			t = Std.int(t / 2);
		}
		
		while (endstring.length < len) endstring = "0" + endstring;
		return endstring;
	}
	
	private static function convertbase64tobinary(t:String):String {
		var endstring:String = "";
		var currentval:Int = 0;
		
		for (i in 0 ... t.length) {
			currentval = BASE64.indexOf(t.substr(i, 1));
			endstring += convertobinary(currentval, 6);
		}
		return endstring;
	}
	
	private static function convertbinarytoint(binarystring:String):Int {
		var returnval:Int = 0;
		for (i in -binarystring.length ... 0) {
			if (binarystring.substr( -i - 1, 1) == "1"){
				returnval += Std.int(Math.pow(2, binarystring.length + i));
			}
		}
		return returnval;
	}
	
	/** Return characters from the middle of a string. */
	private static function mid(currentstring:String, start:Int = 0, length:Int = 1):String {
		if (start < 0) return "";
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
	
	public static function clearimages() {
		imageindex = new Map<String, Int>();
		for(i in 0 ... images.length){
		  images[i].dispose();
		}
		
		images = [];
	}
	
	private static function unmakerle(s:String):String {
		var result:String = "";
		var lastInt:Int = 0;
		var i:Int = 0;
		
		while (i < s.length) {
			var c:String = s.substr(i, 1);
			while (c == "0" || c == "1" || c == "2" || c == "3" || c == "4" ||
			       c == "5" || c == "6" || c == "7" || c == "8" || c == "9") {
				lastInt = lastInt * 10 + Convert.toint(c);
				i++;
				c = s.substr(i, 1);
			}
			
			if (lastInt == 0) {
				lastInt = 1;
			}
			
			for (i in 0 ... lastInt) {
				result = result + c;
			}
			i++;
			c = s.substr(i, 1);
			lastInt = 0;
		}
		
		return result;
	}
	
	public static function loadimagestring(imagename:String, inputstring:String, col1:Int = -1, col2:Int = -1, col3:Int = -1, col4:Int = -1) {
		inputstring = replacechar(inputstring, " ", "");
		inputstring = replacechar(inputstring, "\n", "");
		inputstring = replacechar(inputstring, "\t", "");
		var currentchunk:String = "";
		function getnextchunk(size:Int) {
			currentchunk = inputstring.substr(0, size);
			inputstring = inputstring.substr(size);
		}
		
		inputstring = unmakerle(inputstring);
		inputstring = convertbase64tobinary(inputstring);
		
		//Get image width:
		getnextchunk(4);
		var imgwidth:Int = convertbinarytoint(currentchunk) + 1;
		
		//Get image height:
		getnextchunk(4);
		var imgheight:Int = convertbinarytoint(currentchunk) + 1;
		
		getnextchunk(1);
		var imgformat:Int = Convert.toint(currentchunk);
		if (imgformat == 0) imgformat = 2;
		
		var t:BitmapData = new BitmapData(imgwidth, imgheight, true, 0x000000);
		
		//Load the palette
		var r:Int; var g:Int; var b:Int;
		var imgpal:Array<Int> = [col1, col2, col3, col4];
		
		//Four colour format
		for (i in 0 ... (imgformat * 2)) {
			getnextchunk(8);
			r = convertbinarytoint(currentchunk);
			getnextchunk(8);
			g = convertbinarytoint(currentchunk);
			getnextchunk(8);
			b = convertbinarytoint(currentchunk);
			if (imgpal[i] == KEEPCOL) imgpal[i] = Gfx.rgb(r, g, b);
		}
		
		//Clear the image before starting
		var pixel:Int = 0;
		for (j in 0 ... imgheight) {
			for (i in 0 ... imgwidth) {
				getnextchunk(imgformat);
				pixel = convertbinarytoint(currentchunk);
				pixel = imgpal[pixel];
				
				if(pixel != Col.TRANSPARENT){
					settrect(i, j, 1, 1);
					t.fillRect(trect, (0xFF << 24) + pixel);
				}
			}
		}
			
		imageindex.set(imagename, images.length);
		images.push(t);
	}
	
	
	public static function loadimage(imagename:String) {
		Webdebug.log("Error: \"loadimage\" function not available in webscript version.");
		Webdebug.log("Try loadimagestring, using the sprite editor tool.");
	}
	#else
	public static function loadimage(imagename:String) {
		buffer = new Bitmap(Assets.getBitmapData("data/graphics/" + imagename + ".png")).bitmapData;
		if (buffer == null) {
			throw("ERROR: In loadimage, cannot find data/graphics/" + imagename + ".png.");
			return;
		}
		
		imageindex.set(imagename, images.length);
		
		var t:BitmapData = new BitmapData(buffer.width, buffer.height, true, 0x000000);
		settrect(0, 0, buffer.width, buffer.height);			
		t.copyPixels(buffer, trect, tl);
		images.push(t);
	}
	#end
	
	/** Creates a blank image, with the name "imagename", with given width and height. */
	public static function createimage(imagename:String, width:Float, height:Float) {
		var t:BitmapData = new BitmapData(Math.floor(width), Math.floor(height), true, 0);
		
		var exindex:Null<Int> = imageindex.get(imagename);
		if (exindex == null) {
			imageindex.set(imagename, images.length);
			images.push(t);
		} else {
			images[exindex].dispose();
			images[exindex] = t;
		}
	}
	
	/** Resizes an image to a new size and stores it with the same label. */
	public static function resizeimage(imagename:String, scale:Float) {
		var oldindex:Int = imageindex.get(imagename);
		var newbitmap:BitmapData = new BitmapData(Std.int(images[oldindex].width * scale), Std.int(images[oldindex].height * scale), true, 0);
		var pixelalpha:Int;
		var pixel:Int;
		
		images[oldindex].lock();
		newbitmap.lock();
		
		for (j in 0 ... images[oldindex].height) {
			for (i in 0 ... images[oldindex].width) {
				pixel = images[oldindex].getPixel(i, j);
				pixelalpha = images[oldindex].getPixel32(i, j) >> 24 & 0xFF;
				settrect(Math.ceil(i * scale), Math.ceil(j * scale), Math.ceil(scale), Math.ceil(scale));
				newbitmap.fillRect(trect, (pixelalpha << 24) + pixel);
			}
		}
		
		images[oldindex].unlock();
		newbitmap.unlock();
		
		images[oldindex].dispose();
		images[oldindex] = newbitmap;
	}
	
	/** Returns the width of the image. */
	public static function imagewidth(imagename:String):Int {
		if(imageindex.exists(imagename)){
			imagenum = imageindex.get(imagename);
		}else {
			throw("ERROR: In imagewidth, cannot find image \"" + imagename + "\".");
			return 0;
		}
		
		return images[imagenum].width;
	}
	
	/** Returns the height of the image. */
	public static function imageheight(imagename:String):Int {
		if(imageindex.exists(imagename)){
			imagenum = imageindex.get(imagename);
		}else {
			throw("ERROR: In imageheight, cannot find image \"" + imagename + "\".");
			return 0;
		}
		
		return images[imagenum].height;
	}
	
	/** Tell draw commands to draw to the actual screen. */
	public static function drawtoscreen() {
		drawingtoscreen = true;
		drawto.unlock();
		drawto = backbuffer;
		drawto.lock();
		
		Text.drawto = Gfx.drawto;
	}
	
	/** Tell draw commands to draw to the given image. */
	public static function drawtoimage(imagename:String) {
		drawingtoscreen = false;
		imagenum = imageindex.get(imagename);
		
		drawto.unlock();
		drawto = images[imagenum];
		drawto.lock();
		
		Text.drawto = Gfx.drawto;
	}
	
	#if !haxegonweb
	/** Tell draw commands to draw to the given tile in the current tileset. */
	public static function drawtotile(tilenumber:Int) {
		drawingtoscreen = false;
		drawto.unlock();
		drawto = tiles[currenttileset].tiles[tilenumber];
		drawto.lock();
		
		Text.drawto = Gfx.drawto;
	}
	#end
	
	/** Helper function for image drawing functions. */
	private static var t1:Float;
	private static var t2:Float;
	private static var t3:Float;
	private static function imagealignx(x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Gfx.screenwidthmid - Std.int(images[imagenum].width / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + images[imagenum].width;
			}
		}
		
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealigny(y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Gfx.screenheightmid - Std.int(images[imagenum].height / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + images[imagenum].height;
			}
		}
		
		return y;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagex(x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Std.int(images[imagenum].width / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + images[imagenum].width;
			}
		}
		
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagey(y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Std.int(images[imagenum].height / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + images[imagenum].height;
			}
		}
		
		return y;
	}
	
	/** Draws image by name. 
	 * Parameters can be: rotation, scale, xscale, yscale, xpivot, ypivoy, alpha
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * */
	public static function drawimage(x:Float, y:Float, imagename:String) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		if (!imageindex.exists(imagename)) {
			throw("ERROR: In drawimage, cannot find image \"" + imagename + "\".");
			return;
		}
		imagenum = imageindex.get(imagename);
		x = imagealignx(x); y = imagealigny(y);
		
		if (!transform && !coltransform) {
			settpoint(Std.int(x), Std.int(y));
			drawto.copyPixels(images[imagenum], images[imagenum].rect, tpoint, null, null, true);
		}else {		
			tempxalign = 0;	tempyalign = 0;
			
			shapematrix.identity();
			
			if (imagexscale != 1.0 || imageyscale != 1.0) {
				if (imagescalexpivot != 0.0) tempxalign = imagealignonimagex(imagescalexpivot);
				if (imagescaleypivot != 0.0) tempyalign = imagealignonimagey(imagescaleypivot);
				shapematrix.translate( -tempxalign, -tempyalign);
				shapematrix.scale(imagexscale, imageyscale);
				shapematrix.translate( tempxalign, tempyalign);
			}
			
			if (imagerotate != 0) {
				if (imagerotatexpivot != 0.0) tempxalign = imagealignonimagex(imagerotatexpivot);
				if (imagerotateypivot != 0.0) tempyalign = imagealignonimagey(imagerotateypivot);
				shapematrix.translate( -tempxalign, -tempyalign);
				shapematrix.rotate((imagerotate * 3.1415) / 180);
				shapematrix.translate( tempxalign, tempyalign);
			}
			
			shapematrix.translate(x, y);
			if (coltransform) {
				alphact.alphaMultiplier = imagealphamult;
				alphact.redMultiplier = imageredmult;
				alphact.greenMultiplier = imagegreenmult;
				alphact.blueMultiplier = imagebluemult;
				alphact.redOffset = imageredadd;
				alphact.greenOffset = imagegreenadd;
				alphact.blueOffset = imageblueadd;
				drawto.draw(images[imagenum], shapematrix, alphact);	
			}else {
				drawto.draw(images[imagenum], shapematrix);
			}
			shapematrix.identity();
		}
	}
	
	#if !haxegonweb
	public static function grabtilefromscreen(tilenumber:Int, x:Float, y:Float) {
		if (currenttileset == -1) {
			throw("ERROR: In grabtilefromscreen, there is no tileset currently set. Use Gfx.changetileset(\"tileset name\") to set the current tileset.");
			return;
		}
		
		settrect(x, y, tilewidth(), tileheight());
		tiles[currenttileset].tiles[tilenumber].copyPixels(backbuffer, trect, tl);
	}
	
	public static function grabtilefromimage(tilenumber:Int, imagename:String, x:Float, y:Float) {
		if (!imageindex.exists(imagename)) {
			throw("ERROR: In grabtilefromimage, \"" + imagename + "\" does not exist.");
			return;
		}
		
		if (currenttileset == -1) {
			throw("ERROR: In grabtilefromimage, there is no tileset currently set. Use Gfx.changetileset(\"tileset name\") to set the current tileset.");
			return;
		}
		
		imagenum = imageindex.get(imagename);
		
		settrect(x, y, tilewidth(), tileheight());
		tiles[currenttileset].tiles[tilenumber].copyPixels(images[imagenum], trect, tl);
	}
	#end
	
	public static function grabimagefromscreen(imagename:String, x:Float, y:Float) {
		if (!imageindex.exists(imagename)) {
			throw("ERROR: In grabimagefromscreen, \"" + imagename + "\" does not exist. You need to create an image label first before using this function.");
			return;
		}
		imagenum = imageindex.get(imagename);
		
		settrect(x, y, images[imagenum].width, images[imagenum].height);
		images[imagenum].copyPixels(backbuffer, trect, tl);
	}
	
	public static function grabimagefromimage(imagename:String, imagetocopyfrom:String, x:Float, y:Float, w:Float = 0, h:Float = 0) {
		if (!imageindex.exists(imagename)) {
			throw("ERROR: In grabimagefromimage, \"" + imagename + "\" does not exist. You need to create an image label first before using this function.");
			return;
		}
		
		imagenum = imageindex.get(imagename);
		if (!imageindex.exists(imagetocopyfrom)) {
			trace("ERROR: No image called \"" + imagetocopyfrom + "\" found.");
		}
		var imagenumfrom:Int = imageindex.get(imagetocopyfrom);
		
		if(w == 0 && h == 0){
			settrect(x, y, images[imagenum].width, images[imagenum].height);
		}else {
			settrect(x, y, w, h);	
		}
		images[imagenum].copyPixels(images[imagenumfrom], trect, tl);
	}
	
	#if !haxegonweb
	public static function copytile(totilenumber:Int, fromtileset:String, fromtilenumber:Int) {
		if (tilesetindex.exists(fromtileset)) {
			if (tiles[currenttileset].width == tiles[tilesetindex.get(fromtileset)].width && tiles[currenttileset].height == tiles[tilesetindex.get(fromtileset)].height) {
				tiles[currenttileset].tiles[totilenumber].copyPixels(tiles[tilesetindex.get(fromtileset)].tiles[fromtilenumber], tiles[tilesetindex.get(fromtileset)].tiles[fromtilenumber].rect, tl);		
			}else {
				trace("ERROR: Tilesets " + currenttilesetname + " (" + Std.string(tilewidth()) + "x" + Std.string(tileheight()) + ") and " + fromtileset + " (" + Std.string(tiles[tilesetindex.get(fromtileset)].width) + "x" + Std.string(tiles[tilesetindex.get(fromtileset)].height) + ") are different sizes. Maybe try just drawing to the tile you want instead with Gfx.drawtotile()?");
				return;
			}
		}else {
			trace("ERROR: Tileset " + fromtileset + " hasn't been loaded or created.");
			return;
		}
	}
	#end
	
	/** Draws tile number t from current tileset.
	 * Parameters can be: rotation, scale, xscale, yscale, xpivot, ypivoy, alpha
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * */
	#if !haxegonweb
	public static function drawtile(x:Float, y:Float, tilesetname:String, t:Int) {
		if (currenttilesetname != tilesetname) {
		  changetileset(tilesetname);	
		}
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		if (currenttileset == -1) {
			throw("ERROR: No tileset currently set. Use Gfx.changetileset(\"tileset name\") to set the current tileset.");
			return;
		}
		if (t >= numberoftiles()) {
			if (t == numberoftiles()) {
			  throw("ERROR: Tried to draw tile number " + Std.string(t) + ", but there are only " + Std.string(numberoftiles()) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(t) + " is not a valid tile.)");
				return;
			}else{
				throw("ERROR: Tried to draw tile number " + Std.string(t) + ", but there are only " + Std.string(numberoftiles()) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
				return;
			}
		}
		
		x = tilealignx(x); y = tilealigny(y);
		
		if (!transform && !coltransform) {
			settpoint(Std.int(x), Std.int(y));
			drawto.copyPixels(tiles[currenttileset].tiles[t], tiles[currenttileset].tiles[t].rect, tpoint, null, null, true);
		}else {		
			tempxalign = 0;	tempyalign = 0;
			
			shapematrix.identity();
			
			if (imagexscale != 1.0 || imageyscale != 1.0) {
				if (imagescalexpivot != 0.0) tempxalign = tilealignontilex(imagescalexpivot);
				if (imagescaleypivot != 0.0) tempyalign = tilealignontiley(imagescaleypivot);
				shapematrix.translate( -tempxalign, -tempyalign);
				shapematrix.scale(imagexscale, imageyscale);
				shapematrix.translate( tempxalign, tempyalign);
			}
			
			if (imagerotate != 0) {
				if (imagerotatexpivot != 0.0) tempxalign = tilealignontilex(imagerotatexpivot);
				if (imagerotateypivot != 0.0) tempyalign = tilealignontiley(imagerotateypivot);
				shapematrix.translate( -tempxalign, -tempyalign);
				shapematrix.rotate((imagerotate * 3.1415) / 180);
				shapematrix.translate( tempxalign, tempyalign);
			}
			
			shapematrix.translate(x, y);
			if (coltransform) {
				alphact.alphaMultiplier = imagealphamult;
				alphact.redMultiplier = imageredmult;
				alphact.greenMultiplier = imagegreenmult;
				alphact.blueMultiplier = imagebluemult;
				alphact.redOffset = imageredadd;
				alphact.greenOffset = imagegreenadd;
				alphact.blueOffset = imageblueadd;
				drawto.draw(tiles[currenttileset].tiles[t], shapematrix, alphact);	
			}else {
				drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
			}
			shapematrix.identity();
		}
	}
	
	/** Returns the current animation frame of the current tileset. */
	public static function currentframe():Int {
		return tiles[currenttileset].currentframe;
	}
	
	/** Resets the animation. */
	public static function stopanimation(animationname:String) {
		animationnum = animationindex.get(animationname);
		animations[animationnum].reset();
	}
	
	public static function defineanimation(animationname:String, tileset:String, startframe:Int, endframe:Int, delayperframe:Int) {
		if (delayperframe < 1) {
			throw("ERROR: Cannot have a delay per frame of less than 1.");
			return;
		}
		animationindex.set(animationname, animations.length);
		animations.push(new AnimationContainer(animationname, tileset, startframe, endframe, delayperframe));
	}
	
	public static function drawanimation(x:Float, y:Float, animationname:String) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		oldtileset = currenttilesetname;
		if (!animationindex.exists(animationname)) {
			throw("ERROR: No animated named \"" +animationname+"\" is defined. Define one first using Gfx.defineanimation!");
			return;
		}
		animationnum = animationindex.get(animationname);
		changetileset(animations[animationnum].tileset);
		
		animations[animationnum].update();
		tempframe = animations[animationnum].currentframe;
		/*
		if (parameters != null) {
		  drawtile(x, y, tempframe, parameters);
		}else {
			drawtile(x, y, tempframe);
		}*/
		
		changetileset(oldtileset);
	}
	
	private static function tilealignx(x:Float):Float {
		if (x == CENTER) return Gfx.screenwidthmid - Std.int(tiles[currenttileset].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return tiles[currenttileset].width;
		return x;
	}
	
	private static function tilealigny(y:Float):Float {
		if (y == CENTER) return Gfx.screenheightmid - Std.int(tiles[currenttileset].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return tiles[currenttileset].height;
		return y;
	}
	
	private static function tilealignontilex(x:Float):Float {
		if (x == CENTER) return Std.int(tiles[currenttileset].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return tiles[currenttileset].width;
		return x;
	}
	
	private static function tilealignontiley(y:Float):Float {
		if (y == CENTER) return Std.int(tiles[currenttileset].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return tiles[currenttileset].height;
		return y;
	}
	#end
	
	#if haxegonweb
	public static var bresx1:Array<Int> = new Array<Int>();
	public static var bresy1:Array<Int> = new Array<Int>();
	//public static var bresswap1:Array<Int> = new Array<Int>();
	public static var bresx2:Array<Int> = new Array<Int>();
	public static var bresy2:Array<Int> = new Array<Int>();
	//public static var bresswap2:Array<Int> = new Array<Int>();
	//public static var bressize:Int;
	public static inline function fastAbs(v:Int) : Int {
		return (v ^ (v >> 31)) - (v >> 31);
	}
	 
	public static inline function fastFloor(v:Float) : Int {
		return Std.int(v); // actually it's more "truncate" than "round to 0"
	}
	
	public static function bresenhamline(x0:Int, y0:Int, x1:Int, y1:Int, linenum:Int):Void {
		var startx1:Int = x1;
		var starty1:Int = y1;
		var swapXY = Math.abs(y1 - y0) > Math.abs(x1 - x0);
		var tmp:Int;
		
		if (linenum == 0) {
			bresx1 = []; bresy1 = [];
		}else {
			bresx2 = []; bresy2 = [];
		}
		if (swapXY) {
			// swap x and y
			tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
			tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
		}
		
		if(x0 > x1) {
			// make sure x0 < x1
			tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
			tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
		}
		
		var deltax = x1 - x0;
		var deltay = Std.int( Math.abs(y1 - y0));
		var error = Std.int( deltax / 2 );
		var y = y0;
		var ystep = if ( y0 < y1 ) 1 else -1;
		
			// Y / X
		for (x in x0 ... x1 + 1 ) {	
			if(linenum==0){
				if (swapXY) {
					bresx1.push(y); bresy1.push(x);
				}else {
					bresx1.push(x); bresy1.push(y);
				}
			}else {
				if (swapXY) {
					bresx2.push(y); bresy2.push(x);
				}else {
					bresx2.push(x); bresy2.push(y);
				}
			}
			error -= deltay;
			if ( error < 0 ) {
				y = y + ystep;
				error = error + deltax;
			}
		}
	}
	
	public static function drawbresenhamline(x0:Int, y0:Int, x1:Int, y1:Int, col:Int, alpha:Float):Void {
		var startx1:Int = x1;
		var starty1:Int = y1;
		var swapXY = Math.abs(y1 - y0) > Math.abs(x1 - x0);
		var tmp:Int;
		
		if (swapXY) {
			// swap x and y
			tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
			tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
		}
		
		if(x0 > x1) {
			// make sure x0 < x1
			tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
			tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
		}
		
		var deltax = x1 - x0;
		var deltay = Std.int( Math.abs(y1 - y0));
		var error = Std.int( deltax / 2 );
		var y = y0;
		var ystep = if ( y0 < y1 ) 1 else -1;
		
			// Y / X
		for (x in x0 ... x1 + 1 ) {	
			if (swapXY) {
				setpixel(y, x, col, alpha);
			}else {
				setpixel(x, y, col, alpha);
			}
			error -= deltay;
			if ( error < 0 ) {
				y = y + ystep;
				error = error + deltax;
			}
		}
	}
	#end
	
	public static function drawline(_x1:Float, _y1:Float, _x2:Float, _y2:Float, col:Int, alpha:Float = 1.0) {
    if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		#if haxegonweb
		if (_x1 == _x2) {
			if (_y2 > _y1) {
				fillbox(_x1 - linethickness + 1, _y1, 1 + linethickness - 1, _y2 - _y1, col, alpha);
			}else {
				fillbox(_x1 - linethickness + 1, _y2, 1 + linethickness - 1, _y1 - _y2, col, alpha);
			}
		}else if (_y1 == _y2) {
			if(_x2>_x1){
				fillbox(_x1, _y1 - linethickness + 1, _x2 - _x1, 1 + linethickness - 1, col, alpha);
			}else {
				fillbox(_x2, _y1 - linethickness + 1, _x1 - _x2, 1 + linethickness - 1, col, alpha);
			}
		}else{
			drawbresenhamline(Std.int(_x1), Std.int(_y1), Std.int(_x2), Std.int(_y2), col, alpha);
		}
		#else
    tempshape.graphics.clear();
		tempshape.graphics.lineStyle(_linethickness, col, alpha);
		tempshape.graphics.moveTo(_x1, _y1);
    tempshape.graphics.lineTo(_x2, _y2);
		shapematrix.identity();
    drawto.draw(tempshape, shapematrix);
		#end
	}

	public static function drawhexagon(x:Float, y:Float, radius:Float, angle:Float, col:Int, alpha:Float = 1.0) {
		#if haxegonweb alpha = 1.0; #end
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb
		temprotate = ((Math.PI * 2) / 6);
		
		tx = (Math.cos(angle) * radius) + x;
		ty = (Math.sin(angle) * radius) + y;
		for (i in 0 ... 6) {
			tx2 = (Math.cos(angle + (temprotate * (i+1))) * radius) + x;
		  ty2 = (Math.sin(angle + (temprotate * (i+1))) * radius) + y;
			
			drawline(tx, ty, tx2, ty2, col, alpha);
			tx = tx2; ty = ty2;
		}
		#else
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(_linethickness, col, alpha);
		
		temprotate = ((Math.PI * 2) / 6);
		
		tx = (Math.cos(angle) * radius);
		ty = (Math.sin(angle) * radius);
		
		tempshape.graphics.moveTo(tx, ty);
		for (i in 0 ... 7) {
			tx = (Math.cos(angle + (temprotate * i)) * radius);
		  ty = (Math.sin(angle + (temprotate * i)) * radius);
			
			tempshape.graphics.lineTo(tx, ty);
		}
		
		shapematrix.identity();
		shapematrix.translate(x, y);
		drawto.draw(tempshape, shapematrix);
		#end
	}
	
	public static function fillhexagon(x:Float, y:Float, radius:Float, angle:Float, col:Int, alpha:Float = 1.0) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		#if haxegonweb
		temprotate = ((Math.PI * 2) / 6);
		if (angle == 0) angle = Math.PI;
		
		tx = (Math.cos(angle) * radius) + x;
		ty = (Math.sin(angle) * radius) + y;
		for (i in 0 ... 6) {
			tx2 = (Math.cos(angle + (temprotate * (i+1))) * radius) + x;
		  ty2 = (Math.sin(angle + (temprotate * (i+1))) * radius) + y;
			
			filltri(tx, ty, tx2, ty2, x, y, col, alpha);
			tx = tx2; ty = ty2;
		}
		#else
		tempshape.graphics.clear();
		temprotate = ((Math.PI * 2) / 6);
		
		tx = (Math.cos(angle) * radius);
		ty = (Math.sin(angle) * radius);
		
		tempshape.graphics.moveTo(tx, ty);
		tempshape.graphics.beginFill(col, alpha);
		for (i in 0 ... 7) {
			tx = (Math.cos(angle + (temprotate * i)) * radius);
		  ty = (Math.sin(angle + (temprotate * i)) * radius);
			
			tempshape.graphics.lineTo(tx, ty);
		}
		tempshape.graphics.endFill();
		
		shapematrix.translate(x, y);
		drawto.draw(tempshape, shapematrix);
		shapematrix.translate( -x, -y);
		#end
	}
	
	public static function drawcircle(x:Float, y:Float, radius:Float, col:Int, alpha:Float = 1.0) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		#if haxegonweb
		x = Std.int(x);
		y = Std.int(y);
		radius = Std.int(radius);
		tx = radius;
    ty = 0;
    var decisionOver2:Float = 1 - tx;   // Decision criterion divided by 2 evaluated at x=r, y=0
		
		while (tx >= ty) {
			setpixel(Std.int(tx + x), Std.int(ty + y), col);
			setpixel(Std.int(ty + x), Std.int(tx + y), col);
			setpixel(Std.int(-tx + x), Std.int(ty + y), col);
			setpixel(Std.int(-ty + x), Std.int(tx + y), col);
			setpixel(Std.int(-tx + x), Std.int(-ty + y), col);
			setpixel(Std.int(-ty + x), Std.int(-tx + y), col);
			setpixel(Std.int(tx + x), Std.int(-ty + y), col);
			setpixel(Std.int(ty + x), Std.int(-tx + y), col);
			ty++;
			if (decisionOver2<=0){
				decisionOver2 += 2 * ty + 1;   // Change in decision criterion for y -> y+1
			}else{
				tx--;
				decisionOver2 += 2 * (ty - tx) + 1;   // Change for y -> y+1, x -> x-1
			}
		}
		#else
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(_linethickness, col, alpha);
		tempshape.graphics.drawCircle(0, 0, radius);
		
		shapematrix.identity();
		shapematrix.translate(x, y);
		drawto.draw(tempshape, shapematrix);
		shapematrix.identity();
		#end
	}
	
	#if haxegonweb
	private static var fillcirclepoints:Array<Bool> = [];
	#end
	public static function fillcircle(x:Float, y:Float, radius:Float, col:Int, alpha:Float = 1.0) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		#if haxegonweb
		x = fastFloor(x);
		y = fastFloor(y);
		radius = fastFloor(radius);
		tx = radius;
    ty = 0;
    var decisionOver2:Float = 1 - tx;   // Decision criterion divided by 2 evaluated at x=r, y=0
		
		fillcirclepoints = [];
		for (i in 0 ... Std.int(radius * 2)) fillcirclepoints.push(true);
		while (tx >= ty) {
			if(fillcirclepoints[Std.int(ty)]){
				fillbox(x - tx, y + ty, tx + tx, 1, col, alpha);
				fillcirclepoints[Std.int(ty)] = false;
			}
			if(fillcirclepoints[Std.int(tx)]){
				fillbox(x - ty, y + tx, ty + ty, 1, col, alpha);
				fillcirclepoints[Std.int(tx)] = false;
			}
			
			if(fillcirclepoints[Std.int(radius + ty)]){
				fillbox(x - tx, y - ty, tx + tx, 1, col, alpha);
				fillcirclepoints[Std.int(radius + ty)] = false;
			}
			if(fillcirclepoints[Std.int(radius + tx)]){
				fillbox(x - ty, y - tx, ty + ty, 1, col, alpha);
				fillcirclepoints[Std.int(radius + tx)] = false;
			}
			
			ty++;
			if (decisionOver2<=0){
				decisionOver2 += 2 * ty + 1;   // Change in decision criterion for y -> y+1
			}else{
				tx--;
				decisionOver2 += 2 * (ty - tx) + 1;   // Change for y -> y+1, x -> x-1
			}
		}
		#else
		tempshape.graphics.clear();
		tempshape.graphics.beginFill(col, alpha);
		tempshape.graphics.drawCircle(0, 0, radius);
		tempshape.graphics.endFill();
		
		shapematrix.identity();
		shapematrix.translate(x, y);
		drawto.draw(tempshape, shapematrix);
		shapematrix.identity();
		#end
	}
	
	public static function drawtri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Int, alpha:Float = 1.0) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		#if haxegonweb
		drawline(x1, y1, x2, y2, col);
		drawline(x2, y2, x3, y3, col);
		drawline(x3, y3, x1, y1, col);
		#else
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(_linethickness, col, alpha);
		tempshape.graphics.lineTo(0, 0);
		tempshape.graphics.lineTo(x2 - x1, y2 - y1);
		tempshape.graphics.lineTo(x3 - x1, y3 - y1);
		tempshape.graphics.lineTo(0, 0);
		tempshape.graphics.endFill();
		
		shapematrix.translate(x1, y1);
		drawto.draw(tempshape, shapematrix);
		shapematrix.identity();
		#end
	}
	
	#if haxegonweb
	private static var tri_x1:Int;
	private static var tri_y1:Int;
	private static var tri_x2:Int;
	private static var tri_y2:Int;
	private static var tri_x3:Int;
	private static var tri_y3:Int;
	
	private static function getfilltrimatchpoint(t:Int):Int {
		//Return the INDEX of bresenham line two where the y value matches t.
		for (i in 0 ... bresy2.length) {
			if (bresy2[i] == t) {
				return i;
			}
		}
		return -1;
	}
	
	#end
	public static function filltri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Int, alpha:Float = 1.0) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		#if haxegonweb
		//Sort the points from y value highest to lowest
		if (y1 < y2 && y1 < y3) {
			tri_x1 = Std.int(x1); tri_y1 = Std.int(y1);
			if (y2 < y3) { tri_x2 = Std.int(x2); tri_y2 = Std.int(y2);	tri_x3 = Std.int(x3); tri_y3 = Std.int(y3);
			}else {	tri_x2 = Std.int(x3); tri_y2 = Std.int(y3);	tri_x3 = Std.int(x2); tri_y3 = Std.int(y2);}
		}else if (y2 < y3 && y2 < y1) {
			tri_x1 = Std.int(x2); tri_y1 = Std.int(y2);
			if (y1 < y3) { tri_x2 = Std.int(x1); tri_y2 = Std.int(y1);	tri_x3 = Std.int(x3); tri_y3 = Std.int(y3);
			}else {tri_x2 = Std.int(x3); tri_y2 = Std.int(y3);	tri_x3 = Std.int(x1); tri_y3 = Std.int(y1);	}
		}else {
			tri_x1 = Std.int(x3); tri_y1 = Std.int(y3);
			if (y2 < y1) {tri_x2 = Std.int(x2); tri_y2 = Std.int(y2);	tri_x3 = Std.int(x1); tri_y3 = Std.int(y1);
			}else {	tri_x2 = Std.int(x1); tri_y2 = Std.int(y1);	tri_x3 = Std.int(x2); tri_y3 = Std.int(y2);	}
		}
		
		//Bresenham from 1 to 2 and 1 to 3
		bresenhamline(tri_x1, tri_y1, tri_x2, tri_y2, 0);
		bresenhamline(tri_x1, tri_y1, tri_x3, tri_y3, 1);
		var matchingpoint:Int = 0;
		var lastypos:Int = -1;
		var firstypos:Int = bresy1[0];
		
		//1-2 is the shorter line, so run down it and fill that segment up
		for (i in 0 ... bresx1.length) {
			if (bresy1[i] != lastypos) {
				lastypos = bresy1[i];
				matchingpoint = getfilltrimatchpoint(bresy1[i]);
				if (matchingpoint > -1) {	
					if (bresx1[i] > bresx2[matchingpoint]) {
						settrect(bresx2[matchingpoint], bresy1[i], bresx1[i]-bresx2[matchingpoint], 1);
					}else {
						settrect(bresx1[i], bresy1[i], bresx2[matchingpoint]-bresx1[i], 1);
					}
					
					fillbox(trect.x, trect.y, trect.width, 1, col, alpha);
				}
			}
		}
		
		//Now get 2 to 3
		var secondlastypos:Int = -1;
		bresenhamline(tri_x2, tri_y2, tri_x3, tri_y3, 0);
		for (i in 0 ... bresx1.length) {
			if (bresy1[i] != lastypos && bresy1[i] != secondlastypos && bresy1[i] != firstypos) {
				secondlastypos = bresy1[i];
				matchingpoint = getfilltrimatchpoint(bresy1[i]);
				if (matchingpoint > -1) {	
					if (bresx1[i] > bresx2[matchingpoint]) {
						settrect(bresx2[matchingpoint], bresy1[i], bresx1[i]-bresx2[matchingpoint], 1);
					}else {
						settrect(bresx1[i], bresy1[i], bresx2[matchingpoint]-bresx1[i], 1);
					}
					
					fillbox(trect.x, trect.y, trect.width, 1, col, alpha);
				}
			}
		}
		#else
		tempshape.graphics.clear();
		tempshape.graphics.beginFill(col, alpha);
		tempshape.graphics.lineTo(0, 0);
		tempshape.graphics.lineTo(x2 - x1, y2 - y1);
		tempshape.graphics.lineTo(x3 - x1, y3 - y1);
		tempshape.graphics.lineTo(0, 0);
		tempshape.graphics.endFill();
		
		shapematrix.identity();
		shapematrix.translate(x1, y1);
		drawto.draw(tempshape, shapematrix);
		#end
	}

	public static function drawbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		if (width < 0) {
			width = -width;
			x = x - width;
		}
		if (height < 0) {
			height = -height;
			y = y - height;
		}
		#if haxegonweb
			fillbox(x, y, width, 1, col, alpha);
			fillbox(x, y + height - 1, width - 1, 1, col, alpha);
			fillbox(x, y + 1, 1, height - 1, col, alpha);
			fillbox(x + width - 1, y + 1, 1, height - 1, col, alpha);
		#else
		if (_linethickness < 2) {				
			fillbox(x, y, width, 1, col, alpha);
			fillbox(x, y + height - 1, width - 1, 1, col, alpha);
			fillbox(x, y + 1, 1, height - 1, col, alpha);
			fillbox(x + width - 1, y + 1, 1, height - 1, col, alpha);
		}else{
			tempshape.graphics.clear();
			tempshape.graphics.lineStyle(_linethickness, col, alpha);
			tempshape.graphics.lineTo(width, 0);
			tempshape.graphics.lineTo(width, height);
			tempshape.graphics.lineTo(0, height);
			tempshape.graphics.lineTo(0, 0);
			
			shapematrix.identity();
			shapematrix.translate(x, y);
			drawto.draw(tempshape, shapematrix);
			shapematrix.identity();
		}
		#end
	}

	public static var linethickness(get,set):Float;

	static function get_linethickness():Float {
		return _linethickness;
	}

	static function set_linethickness(size:Float) {
		_linethickness = size;
		if (_linethickness < 1) _linethickness = 1;
		if (_linethickness > 255) _linethickness = 255;
		return _linethickness;
	}
	
	public static function clearscreen(col:Int = 0x000000) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		drawto.fillRect(drawto.rect, (0xFF << 24) + col);
	}
	
	public static function getpixel(x:Float, y:Float):Int {
		var pixelalpha:Int = drawto.getPixel32(Std.int(x), Std.int(y)) >> 24 & 0xFF;
		var pixel:Int = drawto.getPixel(Std.int(x), Std.int(y));
		
		if (pixelalpha == 0) return Col.TRANSPARENT;
		return pixel;
	}
	
	public static function setpixel(x:Float, y:Float, col:Int, alpha:Float = 1.0) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		#if haxegonweb
		if (col == Col.TRANSPARENT) {
			if (_linethickness == 1) {
				settpoint(fastFloor(x), fastFloor(y));
				drawto.copyPixels(transparentpixel, transparentpixel.rect, tpoint, null, null, true);
			}else {
				fillbox(x - _linethickness + 1, y - _linethickness + 1, _linethickness + _linethickness - 2, _linethickness + _linethickness - 2, col);
			}
		}else	if (alpha < 1) {
			if (_linethickness == 1) {
				//drawto.setPixel32(Std.int(x), Std.int(y), (Std.int(alpha * 256) << 24) + col);
				settrect(Std.int(x), Std.int(y), 1, 1);
				drawto.fillRect(trect, (Std.int(alpha * 256) << 24) + col);
			}else {
				settrect(x - _linethickness + 1, y - _linethickness + 1, _linethickness + _linethickness - 2, _linethickness + _linethickness - 2);
				drawto.fillRect(trect, (Std.int(alpha * 256) << 24) + col);
			}
		}else {
			if (_linethickness == 1) {
				//drawto.setPixel32(Std.int(x), Std.int(y), (Std.int(alpha * 256) << 24) + col);
				settrect(Std.int(x), Std.int(y), 1, 1);
				drawto.fillRect(trect, (0xFF << 24) + col);
			}else {
				settrect(x - _linethickness + 1, y - _linethickness + 1, _linethickness + _linethickness - 2, _linethickness + _linethickness - 2);
				drawto.fillRect(trect, (0xFF << 24) + col);
			}
		}
		#else
		drawto.setPixel32(Std.int(x), Std.int(y), (Std.int(alpha * 255) << 24) + col);
		#end
	}

	public static function fillbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0) {
		if (!clearscreeneachframe) if (skiprender && drawingtoscreen) return;
		#if haxegonweb alpha = 1.0; #end
		#if haxegonweb
		if (col == Col.TRANSPARENT) {
			for (j in Std.int(y) ... Std.int(y + height)) {
				for (i in Std.int(x) ... Std.int(x + width)) {
					settpoint(Std.int(i), Std.int(j));
					drawto.copyPixels(transparentpixel, transparentpixel.rect, tpoint, null, null, true);
				}
			}
		}else	if (alpha == 1.0) {
			settrect(Std.int(x), Std.int(y), Std.int(width), Std.int(height));
			drawto.fillRect(trect, (0xFF << 24) + col);
		}else {
			tempshape.graphics.clear();
			tempshape.graphics.beginFill(col, alpha);
			tempshape.graphics.lineTo(Std.int(width), 0);
			tempshape.graphics.lineTo(Std.int(width), Std.int(height));
			tempshape.graphics.lineTo(0, Std.int(height));
			tempshape.graphics.lineTo(0, 0);
			tempshape.graphics.endFill();
			
			shapematrix.identity();
			shapematrix.translate(Std.int(x), Std.int(y));
			drawto.draw(tempshape, shapematrix);
		}
		#else
		tempshape.graphics.clear();
		tempshape.graphics.beginFill(col, alpha);
		tempshape.graphics.lineTo(width, 0);
		tempshape.graphics.lineTo(width, height);
		tempshape.graphics.lineTo(0, height);
		tempshape.graphics.lineTo(0, 0);
		tempshape.graphics.endFill();
		
		shapematrix.identity();
		shapematrix.translate(x, y);
		drawto.draw(tempshape, shapematrix);
		shapematrix.identity();
		#end
	}
	
	public static inline function getred(c:Int):Int {
		return ((c >> 16) & 0xFF);
	}
	
	public static inline function getgreen(c:Int):Int {
		return ((c >> 8) & 0xFF);
	}
	
	public static inline function getblue(c:Int):Int {
		return (c & 0xFF);
	}
	
	/** Get the Hue value (0-360) of a hex code colour. **/
	public static function gethue(c:Int):Int {
		var r:Float = getred(c) / 255;
		var g:Float = getgreen(c) / 255;
		var b:Float = getblue(c) / 255;
    var max:Float = Math.max(Math.max(r, g), b); 
		var min:Float = Math.min(Math.min(r, g), b); 
    
		var h:Float = (max + min) / 2;
		
    if (max != min) {
			var d:Float = max - min;
			if(max == r){
				h = (g - b) / d + (g < b ? 6 : 0);
			}else if (max == g) {
				h = (b - r) / d + 2;
			}else if (max == b) {
				h = (r - g) / d + 4;
			}
			h /= 6;
    }
		
    return Std.int(h * 360);
	}
	
	/** Get the Saturation value (0.0-1.0) of a hex code colour. **/
	public static function getsaturation(c:Int):Float {
		var r:Float = getred(c) / 255;
		var g:Float = getgreen(c) / 255;
		var b:Float = getblue(c) / 255;
    var max:Float = Math.max(Math.max(r, g), b); 
		var min:Float = Math.min(Math.min(r, g), b); 
    
		var s:Float = (max + min) / 2;
		var l:Float = s;
		
    if (max == min) {
			s = 0;
    }else {
			var d:Float = max - min;
			s = l > 0.5?d / (2 - max - min):d / (max + min);
    }
		
    return s;
	}
	
	/** Get the Lightness value (0.0-1.0) of a hex code colour. **/
	public static function getlightness(c:Int):Float {
		var r:Float = getred(c) / 255;
		var g:Float = getgreen(c) / 255;
		var b:Float = getblue(c) / 255;
    var max:Float = Math.max(Math.max(r, g), b); 
		var min:Float = Math.min(Math.min(r, g), b); 
		
    return (max + min) / 2;
	}
	
	public static function rgb(red:Int, green:Int, blue:Int):Int {
		return (blue | (green << 8) | (red << 16));
	}
	
	/** Picks a colour given Hue, Saturation and Lightness values. 
	 *  Hue is between 0-359, Saturation and Lightness between 0.0 and 1.0. */
	public static function hsl(hue:Float, saturation:Float, lightness:Float):Int{
		var q:Float = if (lightness < 1 / 2) {
			lightness * (1 + saturation);
		}else {
			lightness + saturation - (lightness * saturation);
		}
		
		var p:Float = 2 * lightness - q;
		
		var hk:Float = ((hue % 360) / 360);
		
		hslval[0] = hk + 1 / 3;
		hslval[1] = hk;
		hslval[2] = hk - 1 / 3;
		for (n in 0 ... 3){
			if (hslval[n] < 0) hslval[n] += 1;
			if (hslval[n] > 1) hslval[n] -= 1;
			hslval[n] = if (hslval[n] < 1 / 6){
				p + ((q - p) * 6 * hslval[n]);
			}else if (hslval[n] < 1 / 2)	{
				q;
			}else if (hslval[n] < 2 / 3){
				p + ((q - p) * 6 * (2 / 3 - hslval[n]));
			}else{
				p;
			}
		}
		
		return rgb(Std.int(hslval[0] * 255), Std.int(hslval[1] * 255), Std.int(hslval[2] * 255));
	}
	
	private static function setzoom(t:Int) {
		screen.width = screenwidth * t;
		screen.height = screenheight * t;
		screen.x = (screenwidth - (screenwidth * t)) / 2;
		screen.y = (screenheight - (screenheight * t)) / 2;
	}
	
	private static function updategraphicsmode() {
		if (fullscreen) {
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			gfxstage.scaleMode = StageScaleMode.NO_SCALE;
			
			var xScaleFresh:Float = Math.floor(cast(devicexres, Float) / cast(screenwidth, Float));
			var yScaleFresh:Float = Math.floor(cast(deviceyres, Float) / cast(screenheight, Float));
			var fullscreenscale:Int = 1;
			if (xScaleFresh < yScaleFresh) {
				fullscreenscale = Std.int(xScaleFresh);
			} else {
				fullscreenscale = Std.int(yScaleFresh);
			}
			screen.width = screenwidth * fullscreenscale;
			screen.height = screenheight * fullscreenscale;
			
			screen.x = (cast(devicexres, Float) / 2.0) - (screen.width / 2.0);
			screen.y = (cast(deviceyres, Float) / 2.0) - (screen.height / 2.0);
			//Mouse.hide();
		}else {
			Lib.current.stage.displayState = StageDisplayState.NORMAL;
			screen.width = screenwidth * screenscale;
			screen.height = screenheight * screenscale;
			screen.x = 0.0;
			screen.y = 0.0;
			gfxstage.scaleMode = StageScaleMode.SHOW_ALL;
			//gfxstage.align = StageAlign.TOP_LEFT;
			#if haxegonweb
			gfxstage.quality = StageQuality.LOW;
			#else
			gfxstage.quality = StageQuality.HIGH;
			#end
		}
	}
	
	/** Just gives Gfx access to the stage. */
	private static function init(stage:Stage) {
		if (initrun) {
			gfxstage = stage;
			
			#if (js || html5)
			onresize(null);
			stage.addEventListener(Event.RESIZE, onresize);
			#end
		}
		clearscreeneachframe = true;
		reset();
		linethickness = 1;
		transparentpixel = new BitmapData(1, 1, true, 0);
		
		#if haxegon3D
		Gfx3D.init3d();
		#end
	}	
	
	#if html5
	private static function onresize(e:Event):Void {
		//trace("Gfx.onresize called.");
		var scaleX:Float;
		var scaleY:Float;
		
		var ignoreresize:Bool = false;
		#if haxegonweb
		if (Game.editor()) ignoreresize = true;
		#end
		
		if (ignoreresize) {
			scaleX = gfxstage.stageWidth / screenwidth;
			scaleY = gfxstage.stageHeight / screenheight;
			var jsscaleeditor:Float = Math.min(scaleX, scaleY);
			
			gfxstage.scaleX = jsscaleeditor;
			gfxstage.scaleY = jsscaleeditor;
			
			gfxstage.x = (gfxstage.stageWidth - screenwidth * jsscaleeditor) / 2;
			gfxstage.y = (gfxstage.stageHeight - screenheight * jsscaleeditor) / 2;
		}else {
			//trace("screenwidth:", screenwidth);
			//trace("screenheight:", screenheight);
			//trace("gfxstage.stageWidth: ", gfxstage.stageWidth);
			//trace("gfxstage.stageHeight: ", gfxstage.stageHeight);
		  scaleX = Math.floor(gfxstage.stageWidth / screenwidth);
			scaleY = Math.floor(gfxstage.stageHeight / screenheight);
			//trace("scale: (" + scaleX + ", " + scaleY +")");
			
			var jsscale:Int = Convert.toint(Math.min(scaleX, scaleY));
			//trace("Intscale: " + jsscale);
			
			gfxstage.scaleX = jsscale;
			gfxstage.scaleY = jsscale;
			
			gfxstage.x = (gfxstage.stageWidth - screenwidth * jsscale) / 2;
			gfxstage.y = (gfxstage.stageHeight - screenheight * jsscale) / 2;
			//trace("gfxstage.pos: (" + gfxstage.x + ", " + gfxstage.y +")");
		}
	}
	#end
	
	/** Called from resizescreen(). Sets up all our graphics buffers. */
	private static function initgfx(width:Int, height:Int, scale:Int) {
		//We initialise a few things
		screenwidth = width; screenheight = height;
		screenwidthmid = Std.int(screenwidth / 2); screenheightmid = Std.int(screenheight / 2);
		
		devicexres = Std.int(flash.system.Capabilities.screenResolutionX);
		deviceyres = Std.int(flash.system.Capabilities.screenResolutionY);
		screenscale = scale;
		
		trect = new Rectangle(); tpoint = new Point();
		tbuffer = new BitmapData(1, 1, true);
		ct = new ColorTransform(0, 0, 0, 1, 255, 255, 255, 1); //Set to white
		alphact = new ColorTransform();
		hslval.push(0.0); hslval.push(0.0); hslval.push(0.0);
		
		if (backbuffer != null) backbuffer.dispose();
		#if haxegon3D
		backbuffer = new BitmapData(screenwidth, screenheight, true, 0);
		#else
		backbuffer = new BitmapData(screenwidth, screenheight, false, 0x000000);
		#end
		drawto = backbuffer;
		drawingtoscreen = true;
		
		screen = new Bitmap(backbuffer);
		screen.smoothing = false;
		screen.width = screenwidth * scale;
		screen.height = screenheight * scale;
		
		fullscreen = false;
		haxegon.Debug.showtest = false;
	}
	
	/** Sets the values for the temporary rect structure. Probably better than making a new one, idk */
	private static function settrect(x:Float, y:Float, w:Float, h:Float) {
		trect.x = x;
		trect.y = y;
		trect.width = w;
		trect.height = h;
	}
	
	/** Sets the values for the temporary point structure. Probably better than making a new one, idk */
	private static function settpoint(x:Float, y:Float) {
		tpoint.x = x;
		tpoint.y = y;
	}
	
	private static var tiles:Array<haxegon.util.Tileset> = new Array<haxegon.util.Tileset>();
	private static var tilesetindex:Map<String, Int> = new Map<String, Int>();
	private static var currenttileset:Int = -1;
	
	private static var animations:Array<AnimationContainer> = new Array<AnimationContainer>();
	private static var animationnum:Int;
	private static var animationindex:Map<String, Int> = new Map<String, Int>();
	
	private static var images:Array<BitmapData> = new Array<BitmapData>();
	private static var imagenum:Int;
	private static var ct:ColorTransform;
	private static var alphact:ColorTransform;
	private static var images_rect:Rectangle;
	private static var tl:Point = new Point(0, 0);
	private static var trect:Rectangle;
	private static var tpoint:Point;
	private static var tbuffer:BitmapData;
	private static var imageindex:Map<String, Int> = new Map<String, Int>();
	
	private static var transform:Bool;
	private static var coltransform:Bool;
	private static var imagerotate:Float;
	private static var imagerotatexpivot:Float;
	private static var imagerotateypivot:Float;
	private static var imagexscale:Float;
	private static var imageyscale:Float;
	private static var imagescalexpivot:Float;
	private static var imagescaleypivot:Float;
	private static var imagealphamult:Float;
	private static var imageredmult:Float;
	private static var imagegreenmult:Float;
	private static var imagebluemult:Float;
	private static var imageredadd:Float;
	private static var imagegreenadd:Float;
	private static var imageblueadd:Float;
	private static var tempframe:Int;
	private static var tempxalign:Float;
	private static var tempyalign:Float;
	private static var temprotate:Float;
	private static var changecolours:Bool;
	private static var oldtileset:String;
	private static var tx:Float;
	private static var ty:Float;
	private static var tx2:Float;
  private static var ty2:Float;
	private static var transparentpixel:BitmapData;
	
	private static var _linethickness:Float;
	
	private static var buffer:BitmapData;
	
	private static var temptile:BitmapData;
	//Actual backgrounds
	private static var screen:Bitmap;
	private static var tempshape:Shape = new Shape();
	private static var shapematrix:Matrix = new Matrix();
	
	private static var alphamult:Int;
	private static var gfxstage:Stage;
	
	//HSL conversion variables 
	private static var hslval:Array<Float> = new Array<Float>();
	
	public static var initrun:Bool;
	public static var skiprender:Bool;
	private static var drawingtoscreen:Bool;
}