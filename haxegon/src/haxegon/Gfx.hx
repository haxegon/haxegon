package haxegon;

import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import starling.display.*;
import starling.geom.*;
import starling.utils.AssetManager;
import starling.textures.*;
import openfl.Assets;

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
	
	/** Create a screen with a given width, height and scale. Also inits Text. */
	public static function resizescreen(width:Float, height:Float, scale:Int = 1) {
		initgfx(Std.int(width), Std.int(height), scale);
		Text.init(gfxstage);
		//showfps = false;
		gfxstage.addChild(screen);
		
		updategraphicsmode();
	}
	
	public static function setfullscreen(fs:Bool) {
		fullscreen = fs;
		updategraphicsmode();
	}
	
	//** Clear all rotations, scales and image colour changes */
	private static function reset() {
		transform = false;
		imagerotate = 0; 
		imagerotatexpivot = 0; imagerotateypivot = 0;
		imagexscale = 1.0; imageyscale = 1.0;
		imagescalexpivot = 0; imagescaleypivot = 0;
		
		coltransform = false;
		imagealphamult = 1.0;	imagecolormult = 0xFFFFFF;
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
		  if (imagecolormult == 0xFFFFFF) {
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
	public static function imagecolor(c:Int = 0xFFFFFF) {
		imagecolormult = c;
		
		coltransform = true;
		reset_ifclear();
	}
	
	public static function numberoftiles(tileset:String):Int {
		changetileset(tileset);
		return tiles[currenttileset].tiles.length;
	}
	
	/* Internal function for changing tile index to correct values for tileset */
	private static function changetileset(tilesetname:String) {
		if (currenttilesetname != tilesetname) {
			if(tilesetindex.exists(tilesetname)){
				currenttileset = tilesetindex.get(tilesetname);
				currenttilesetname = tilesetname;
			}else {
 				throw("ERROR: Cannot change to tileset \"" + tilesetname + "\", no tileset with that name found.");
			}
		}
	}
		
	/** Makes a tile array from a given image. */
	public static function loadtiles(imagename:String, width:Int, height:Int, altlabel:String = "") {		
		var tex:Texture;
		
		try {
		  tex = Texture.fromBitmapData(Assets.getBitmapData("data/graphics/" + imagename + ".png"), false);	
		}catch (e:Dynamic) {
			throw("ERROR: In loadimage, cannot find data/graphics/" + imagename + ".png.");
			return;
		}
		if (altlabel != "") imagename = altlabel;
		
		starlingassets.addTexture(imagename, tex);
		var spritesheet:Texture = starlingassets.getTexture(imagename);
		
		var tiles_rect:Rectangle = new Rectangle(0, 0, width, height);
		tiles.push(new haxegon.util.Tileset(imagename, width, height));
		tilesetindex.set(imagename, tiles.length - 1);
		currenttileset = tiles.length - 1;
		
		var tilerows:Int;
		var tilecolumns:Int;
		tilecolumns = Std.int((spritesheet.width - (spritesheet.width % width)) / width);
		tilerows = Std.int((spritesheet.height - (spritesheet.height % height)) / height);
		
		var framex:Int = 0;
		var framey:Int = 0;
		if (spritesheet.frame != null) {
			framex = Std.int(spritesheet.frame.left);
			framey = Std.int(spritesheet.frame.top);
		}
		
		for (j in 0 ... tilerows) {
			for (i in 0 ... tilecolumns) {
				var rect:Rectangle = new openfl.geom.Rectangle(framex + (i * width), framey + (j * height), width, height);
				var newtex:Texture = Texture.fromTexture(spritesheet, rect);
				tiles[currenttileset].tiles.push(new Image(newtex));
				tiles[currenttileset].tiles[tiles[currenttileset].tiles.length - 1].smoothing = "none";
			}
		}
	}
	
	/* Add some blank tiles to the end of a tileset*/ 
	public static function addblanktiles(tilesetname:String, num:Int) {
		trace("warning: Gfx.addblanktiles is not implemented");
	}
	
	/** Creates a blank tileset, with the name "imagename", with each tile a given width and height, containing "amount" tiles. */
	public static function createtiles(tilesetname:String, width:Float, height:Float, amount:Int) {
		trace("warning: Gfx.createtiles is not implemented");
	}
	
	/** Returns the width of a tile in the current tileset. */
	public static function tilewidth(tilesetname:String):Int {
		trace("warning: Gfx.tilewidth is not implemented");
		return 0;
	}
	
	/** Returns the height of a tile in the current tileset. */
	public static function tileheight(tilesetname:String):Int {
		trace("warning: Gfx.tileheight is not implemented");
		return 0;
	}
	
	/** Loads an image into the game. */
	public static function loadimage(imagename:String) {
		var tex:Texture;
		try {
		  tex = Texture.fromBitmapData(Assets.getBitmapData("data/graphics/" + imagename + ".png"), false);	
		}catch (e:Dynamic) {
			throw("ERROR: In loadimage, cannot find data/graphics/" + imagename + ".png.");
			return;
		}
		starlingassets.addTexture(imagename, tex);
		
		imageindex.set(imagename, images.length);
		images.push(new Image(starlingassets.getTexture(imagename)));
		images[images.length - 1].smoothing = "none";
	}
	
	/** Creates a blank image, with the name "imagename", with given width and height. */
	public static function createimage(imagename:String, width:Float, height:Float) {
		var tex:Texture = Texture.fromBitmapData(new BitmapData(Math.floor(width), Math.floor(height), true, 0));
		var img:Image = new Image(tex);

		var exindex:Null<Int> = imageindex.get(imagename);
		if (exindex == null) {
			imageindex.set(imagename, images.length);
			images.push(img);
		}else {
			images[exindex].dispose();
			images[exindex] = img;
		}
	}
	
	/** Resizes an image to a new size and stores it with the same label. */
	public static function resizeimage(imagename:String, scale:Float) {
		trace("warning: Gfx.resizeimage is not implemented");
	}
	
	/** Returns the width of the image. */
	public static function imagewidth(imagename:String):Int {
		if(imageindex.exists(imagename)){
			imagenum = imageindex.get(imagename);
		}else {
			throw("ERROR: In imagewidth, cannot find image \"" + imagename + "\".");
			return 0;
		}
		
		return Std.int(images[imagenum].width);
	}
	
	/** Returns the height of the image. */
	public static function imageheight(imagename:String):Int {
		if(imageindex.exists(imagename)){
			imagenum = imageindex.get(imagename);
		}else {
			throw("ERROR: In imageheight, cannot find image \"" + imagename + "\".");
			return 0;
		}
		
		return Std.int(images[imagenum].height);
	}
	
	/** Tell draw commands to draw to the actual screen. */
	public static function drawtoscreen() {
		trace("warning: Gfx.drawtoscreen is not implemented");
	}
	
	/** Tell draw commands to draw to the given image. */
	public static function drawtoimage(imagename:String) {
		trace("warning: Gfx.drawtoimage is not implemented");
	}
	
	/** Tell draw commands to draw to the given tile in the current tileset. */
	public static function drawtotile(tilenumber:Int) {
		trace("warning: Gfx.drawtotile is not implemented");
	}
	
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
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * */
	public static function drawimage(x:Float, y:Float, imagename:String) {
		if (!imageindex.exists(imagename)) {
			throw("ERROR: In drawimage, cannot find image \"" + imagename + "\".");
			return;
		}
		
		imagenum = imageindex.get(imagename);
		x = imagealignx(x); y = imagealigny(y);
		
		if (!transform && !coltransform) {
			shapematrix.identity();
			shapematrix.translate(Std.int(x), Std.int(y));
			backbuffer.draw(images[imagenum], shapematrix);
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
				images[imagenum].color = imagecolormult;
				backbuffer.draw(images[imagenum], shapematrix, imagealphamult);
				images[imagenum].color = Col.WHITE;
			}else {
				backbuffer.draw(images[imagenum], shapematrix);
			}
		}
	}
	
	public static function drawsubimage(x:Float, y:Float, x1:Float, y1:Float, w1:Float, h1:Float, imagename:String) {
		trace("warning: Gfx.drawsubimage is not implemented");
	}
	
	public static function grabtilefromscreen(tilenumber:Int, x:Float, y:Float) {
		trace("warning: Gfx.grabtilefromscreen is not implemented");
	}
	
	public static function grabtilefromimage(tilenumber:Int, imagename:String, x:Float, y:Float) {
		trace("warning: Gfx.grabtilefromimage is not implemented");
	}
	
	public static function grabimagefromscreen(imagename:String, x:Float, y:Float) {
		trace("warning: Gfx.grabimagefromscreen is not implemented");
	}
	
	public static function grabimagefromimage(imagename:String, imagetocopyfrom:String, x:Float, y:Float, w:Float = 0, h:Float = 0) {
		trace("warning: Gfx.grabimagefromimage is not implemented");
	}
	
	public static function copytile(totilenumber:Int, fromtileset:String, fromtilenumber:Int) {
		trace("warning: Gfx.copytile is not implemented");
	}
	
	/** Draws tile number t from current tileset.
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * */
	/*Draw a partial tile in the rectangle x1,y1-w,h*/
	public static function drawsubtile(x:Float, y:Float, x1:Float, y1:Float, w:Float, h:Float, tilesetname:String, t:Int) {
		trace("warning: Gfx.drawsubtile is not implemented");
	}
	
	public static function drawtile(x:Float, y:Float, tilesetname:String, t:Int) {
		changetileset(tilesetname);
		
		if (t >= numberoftiles(tilesetname)) {
			if (t == numberoftiles(tilesetname)) {
 			  throw("ERROR: Tried to draw tile number " + Std.string(t) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(t) + " is not a valid tile.)");
				return;
			}else{
				throw("ERROR: Tried to draw tile number " + Std.string(t) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
				return;
			}
		}
		
		x = tilealignx(x); y = tilealigny(y);
		
		if (!transform && !coltransform) {
			shapematrix.identity();
			shapematrix.translate(Std.int(x), Std.int(y));
			backbuffer.draw(tiles[currenttileset].tiles[t], shapematrix);
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
				tiles[currenttileset].tiles[t].color = imagecolormult;
				backbuffer.draw(tiles[currenttileset].tiles[t], shapematrix, imagealphamult);
				tiles[currenttileset].tiles[t].color = Col.WHITE;
			}else {
				backbuffer.draw(tiles[currenttileset].tiles[t], shapematrix);
			}
		}
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
	
	public static function drawline(_x1:Float, _y1:Float, _x2:Float, _y2:Float, col:Int, alpha:Float = 1.0) {
		//drawbresenhamline(Std.int(_x1), Std.int(_y1), Std.int(_x2), Std.int(_y2), col, alpha);
		templine = new Line(_x1, _y1, _x2, _y2, linethickness, col);
		templine.alpha = alpha;
		
		backbuffer.draw(templine);
	}

	public static function drawhexagon(x:Float, y:Float, radius:Float, angle:Float, col:Int, alpha:Float = 1.0) {
		var tempring:Ring = new Ring(radius - linethickness, radius, col, true, 6, angle);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		backbuffer.draw(tempring, shapematrix);
	}
	
	public static function fillhexagon(x:Float, y:Float, radius:Float, angle:Float, col:Int, alpha:Float = 1.0) {
		var tempring:Disk = new Disk(radius, col, true, 6, angle);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		backbuffer.draw(tempring, shapematrix);
	}
	
	public static function drawcircle(x:Float, y:Float, radius:Float, col:Int, alpha:Float = 1.0) {
		var tempring:Ring = new Ring(radius - linethickness, radius, col);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		backbuffer.draw(tempring, shapematrix);
	}
	
	public static function fillcircle(x:Float, y:Float, radius:Float, col:Int, alpha:Float = 1.0) {
		var tempring:Disk = new Disk(radius, col);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		backbuffer.draw(tempring, shapematrix);
	}
	
	public static function drawtri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Int, alpha:Float = 1.0) {
		drawbresenhamline(Std.int(x1), Std.int(y1), Std.int(x2), Std.int(y2), col, alpha);
		drawbresenhamline(Std.int(x2), Std.int(y2), Std.int(x3), Std.int(y3), col, alpha);
		drawbresenhamline(Std.int(x1), Std.int(y1), Std.int(x3), Std.int(y3), col, alpha);
	}
	
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
	
	public static function filltri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Int, alpha:Float = 1.0) {
		temppoly4 = new Poly4(x1, y1, x2, y2, x3, y3, x3, y3, col);
		temppoly4.alpha = alpha;
		backbuffer.draw(temppoly4);
		/*
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
		*/
	}

	public static function drawbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0) {
		if (width < 0) {
			width = -width;
			x = x - width;
		}
		if (height < 0) {
			height = -height;
			y = y - height;
		}
		
		fillbox(x, y, width, 1, col, alpha);
		fillbox(x, y + height - 1, width - 1, 1, col, alpha);
		fillbox(x, y + 1, 1, height - 1, col, alpha);
		fillbox(x + width - 1, y + 1, 1, height - 1, col, alpha);
	}

	public static var linethickness(get,set):Float;
	private static var _linethickness:Float;

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
		backbuffer.clear(col, 1.0);
	}
	
	public static function getpixel(x:Float, y:Float):Int {
		//This one seems tough :/ 
		//http://stackoverflow.com/questions/14078071/how-can-i-get-pixel-values-of-a-texture-in-starling
		trace("warning: Gfx.getpixel is not implemented");
		return 0;
	}
	
	public static function setpixel(x:Float, y:Float, col:Int, alpha:Float = 1.0) {
		fillbox(x, y, 1, 1, col, alpha);
	}

	public static function fillbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0) {
		tempquad.x = x;
		tempquad.y = y;
		tempquad.width = width;
		tempquad.height = height;
		tempquad.color = col;
		tempquad.alpha = alpha;
		
		backbuffer.draw(tempquad);
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
	public static function hsl(hue:Float, saturation:Float, lightness:Float):Int {
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
	//HSL conversion variables 
	private static var hslval:Array<Float> = [0.0, 0.0, 0.0];
	
	private static function setzoom(t:Int) {
		trace("warning: Gfx.setzoom is not implemented");
	}
	
	private static function updategraphicsmode() {
		trace("warning: Gfx.updategraphicsmode is not implemented");
	}
	
	/** Just gives Gfx access to the stage. */
	private static function init(stage:Stage) {
		gfxstage = stage;
		clearscreeneachframe = true;
		linethickness = 1;
		
		reset();
	}	
	
	public static function getscreenx(_x:Float) : Int {
		return Math.floor((_x - screen.x) * screenwidth / screen.width);
	}

	public static function getscreeny(_y:Float) : Int {
		return Math.floor((_y - screen.y) * screenheight / screen.height);
	}
	
	/** Called from resizescreen(). Sets up all our graphics buffers. */
	private static function initgfx(width:Int, height:Int, scale:Int) {
		//We initialise a few things
		screenwidth = width; screenheight = height;
		screenwidthmid = Std.int(screenwidth / 2); screenheightmid = Std.int(screenheight / 2);
		
		devicexres = Std.int(openfl.system.Capabilities.screenResolutionX);
		deviceyres = Std.int(openfl.system.Capabilities.screenResolutionY);
		screenscale = scale;
		
		trect = new Rectangle(0, 0, 0, 0);
		shapematrix = new Matrix();
		tempquad = new Quad(1, 1);
		//temppoly4 = new Poly4();
		
		starlingassets = new AssetManager();
		
		backbuffer = new RenderTexture(width, height, false);
		screen = new Image(backbuffer);
		screen.scale = scale;
		screen.smoothing = "none";
		gfxstage.addChild(screen);
	}
	
	/** Sets the values for the temporary rect structure. Probably better than making a new one, idk */
	private inline static function settrect(x:Float, y:Float, w:Float, h:Float) {
		trect.x = x;
		trect.y = y;
		trect.width = w;
		trect.height = h;
	}
	
	/** Sets the values for the temporary point structure. Probably better than making a new one, idk */
	private inline static function settpoint(x:Float, y:Float) {
		trace("warning: Gfx.settpoint is not implemented");
	}
	
	private static var backbuffer:RenderTexture;
	private static var screen:Image;
	private static var tempquad:Quad;
	private static var temppoly4:Poly4;
	private static var templine:Line;
	
	private static var starlingassets:AssetManager;
	private static var trect:Rectangle;
	private static var shapematrix:Matrix;
	
	private static var gfxstage:Stage;
	
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
	private static var imagecolormult:Int;
	private static var tempxalign:Float;
	private static var tempyalign:Float;
	private static var temprotate:Float;
	private static var tx:Float;
	private static var ty:Float;
	private static var tx2:Float;
  private static var ty2:Float;
	
	private static var imageindex:Map<String, Int> = new Map<String, Int>();
	private static var images:Array<Image> = new Array<Image>();
	private static var imagenum:Int;
	
	private static var tiles:Array<haxegon.util.Tileset> = new Array<haxegon.util.Tileset>();
	private static var tilesetindex:Map<String, Int> = new Map<String, Int>();
	private static var currenttileset:Int = -1;
}