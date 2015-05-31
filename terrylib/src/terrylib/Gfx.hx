package terrylib;
	
import terrylib.util.*;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import openfl.text.*;
import openfl.Assets;
import openfl.Lib;
import openfl.system.Capabilities;

typedef Drawparams = {
  @:optional var scale:Float;
  @:optional var xscale:Float;
  @:optional var yscale:Float;
  @:optional var rotation:Float;
  @:optional var xpivot:Float;
  @:optional var ypivot:Float;
	@:optional var alpha:Float;
	@:optional var col:Int;
}

class Gfx {
	/** Just gives Gfx access to the stage. */
	public static function init(stage:Stage):Void {
		gfxstage = stage;
	}
	
	/** Create a screen with a given width, height and scale. Also inits Text. */
	public static function createscreen(width:Int, height:Int, scale:Int = 1):Void {
		initgfx(width, height, scale);
		Text.init(gfxstage);
		gfxstage.addChild(screen);
		
		updategraphicsmode();
	}
	
	/** Called from createscreen(). Sets up all our graphics buffers. */
	private static function initgfx(width:Int, height:Int, scale:Int):Void {
		//We initialise a few things
		screenwidth = width; screenheight = height;
		screenwidthmid = Std.int(screenwidth / 2); screenheightmid = Std.int(screenheight / 2);
		
		devicexres = Std.int(flash.system.Capabilities.screenResolutionX);
		deviceyres = Std.int(flash.system.Capabilities.screenResolutionY);
		screenscale = scale;
		
		trect = new Rectangle(); tpoint = new Point();
		tbuffer = new BitmapData(1, 1, true);
		ct = new ColorTransform(0, 0, 0, 1, 255, 255, 255, 1); //Set to white
		hslval.push(0.0); hslval.push(0.0); hslval.push(0.0);
		
		backbuffer = new BitmapData(screenwidth, screenheight, false, 0x000000);
		drawto = backbuffer;
		
		screen = new Bitmap(backbuffer);
		screen.width = screenwidth * scale;
		screen.height = screenheight * scale;
		
		fullscreen = false;
		
		Debug.showtest = false;
	}
	
	/** Sets the values for the temporary rect structure. Probably better than making a new one, idk */
	private static function settrect(x:Float, y:Float, w:Float, h:Float):Void {
		trect.x = x;
		trect.y = y;
		trect.width = w;
		trect.height = h;
	}
	
	/** Sets the values for the temporary point structure. Probably better than making a new one, idk */
	private static function settpoint(x:Float, y:Float):Void {
		tpoint.x = x;
		tpoint.y = y;
	}
	
	/** Change the tileset that the draw functions use. */
	public static function changetileset(tilesetname:String):Void {
		if(currenttilesetname != tilesetname){
			currenttileset = tilesetindex.get(tilesetname);
			currenttilesetname = tilesetname;
		}
	}
	
	public static function numberoftiles():Int {
		return tiles[currenttileset].tiles.length;
	}
		
	/** Makes a tile array from a given image. */
	public static function loadtiles(imagename:String, width:Int, height:Int):Void {
		buffer = new Bitmap(Assets.getBitmapData("data/graphics/" + imagename + ".png")).bitmapData;
		
		var tiles_rect:Rectangle = new Rectangle(0, 0, width, height);
		tiles.push(new Tileset(imagename, width, height));
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
	}
	
	/** Creates a blank tileset, with the name "imagename", with each tile a given width and height, containing "amount" tiles. */
	public static function createtiles(imagename:String, width:Float, height:Float, amount:Int):Void {
		tiles.push(new Tileset(imagename, Std.int(width), Std.int(height)));
		tilesetindex.set(imagename, tiles.length - 1);
		currenttileset = tiles.length - 1;
		
		for (i in 0 ... amount) {
			var t:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0x000000);
			tiles[currenttileset].tiles.push(t);
		}
	}
	
	/** Returns the width of a tile in the current tileset. */
	public static function tilewidth():Int {
		return tiles[currenttileset].tiles[0].width;
	}
	
	/** Returns the height of a tile in the current tileset. */
	public static function tileheight():Int {
		return return tiles[currenttileset].tiles[0].height;
	}
	
	/** Loads an image into the game. */
	public static function loadimage(imagename:String):Void {
		buffer = new Bitmap(Assets.getBitmapData("data/graphics/" + imagename + ".png")).bitmapData;
		imageindex.set(imagename, images.length);
		
		var t:BitmapData = new BitmapData(buffer.width, buffer.height, true, 0x000000);
		settrect(0, 0, buffer.width, buffer.height);			
		t.copyPixels(buffer, trect, tl);
		images.push(t);
	}
	
	/** Creates a blank image, with the name "imagename", with given width and height. */
	public static function createimage(imagename:String, width:Float, height:Float):Void {
		imageindex.set(imagename, images.length);
		
		var t:BitmapData = new BitmapData(Math.floor(width), Math.floor(height), true, 0x000000);
		images.push(t);
	}
	
	/** Returns the width of the image. */
	public static function imagewidth(imagename:String):Int {
		imagenum = imageindex.get(imagename);
		
		return images[imagenum].width;
	}
	
	/** Returns the height of the image. */
	public static function imageheight(imagename:String):Int {
		imagenum = imageindex.get(imagename);
		
		return images[imagenum].height;
	}
	
	/** Tell draw commands to draw to the actual screen. */
	public static function drawtoscreen():Void {
		drawto.unlock();
		drawto = backbuffer;
		drawto.lock();
	}
	
	/** Tell draw commands to draw to the given image. */
	public static function drawtoimage(imagename:String):Void {
		imagenum = imageindex.get(imagename);
		
		drawto.unlock();
		drawto = images[imagenum];
		drawto.lock();
	}
	
	/** Tell draw commands to draw to the given tile in the current tileset. */
	public static function drawtotile(tilenumber:Int):Void {
		drawto.unlock();
		drawto = tiles[currenttileset].tiles[tilenumber];
		drawto.lock();
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignx(x:Float):Float {
		if (x == CENTER) return Gfx.screenwidthmid - Std.int(images[imagenum].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return images[imagenum].width;
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealigny(y:Float):Float {
		if (y == CENTER) return Gfx.screenheightmid - Std.int(images[imagenum].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return images[imagenum].height;
		return y;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagex(x:Float):Float {
		if (x == CENTER) return Std.int(images[imagenum].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return images[imagenum].width;
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagey(y:Float):Float {
		if (y == CENTER) return Std.int(images[imagenum].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return images[imagenum].height;
		return y;
	}
		
	/** Draws image by name. 
	 * Parameters can be: rotation, scale, xscale, yscale, xpivot, ypivoy, alpha
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * */
	public static function drawimage(x:Float, y:Float, imagename:String, ?parameters:Drawparams):Void {
		imagenum = imageindex.get(imagename);
		
		tempxpivot = 0;
		tempypivot = 0;
		tempxscale = 1.0;
		tempyscale = 1.0;
		temprotate = 0;
		tempalpha = 1.0;
		
		x = imagealignx(x); y = imagealigny(y);
		if(parameters != null){
			if (parameters.xpivot != null) tempxpivot = imagealignonimagex(parameters.xpivot);
			if (parameters.ypivot != null) tempypivot = imagealignonimagey(parameters.ypivot); 
			if (parameters.scale != null) {
				tempxscale = parameters.scale;
				tempyscale = parameters.scale;
			}else{
				if (parameters.xscale != null) tempxscale = parameters.xscale;
				if (parameters.yscale != null) tempyscale = parameters.yscale;
			}
			if (parameters.rotation != null) temprotate = parameters.rotation;
			if (parameters.alpha != null) tempalpha = parameters.alpha;
		}
			
		shapematrix.identity();
		shapematrix.translate( -tempxpivot, -tempypivot);
		if (temprotate != 0) shapematrix.rotate((temprotate * 3.1415) / 180);
		if (tempxscale != 1.0 || tempyscale != 1.0) shapematrix.scale(tempxscale, tempyscale);
		shapematrix.translate(x + tempxpivot, y + tempypivot);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	/** Draws tile number t from current tileset.
	 * Parameters can be: rotation, scale, xscale, yscale, xpivot, ypivoy, alpha
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * */
	public static function drawtile(x:Float, y:Float, t:Int, ?parameters:Drawparams):Void {
		if (t >= numberoftiles()) {
			if (t == numberoftiles()) {
			  trace("ERROR: Tried to draw tile number " + Std.string(t) + ", but there are only " + Std.string(numberoftiles()) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(t) + " is not a valid tile.)");
			}else{
				trace("ERROR: Tried to draw tile number " + Std.string(t) + ", but there are only " + Std.string(numberoftiles()) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
			}
		}
		
		tempxpivot = 0;
		tempypivot = 0;
		tempxscale = 1.0;
		tempyscale = 1.0;
		temprotate = 0;
		tempalpha = 1.0;
		
		x = tilealignx(x); y = tilealigny(y);
		if (parameters != null) {
			if (parameters.xpivot != null) tempxpivot = tilealignontilex(parameters.xpivot);
			if (parameters.ypivot != null) tempypivot = tilealignontiley(parameters.ypivot); 
			if (parameters.scale != null) {
				tempxscale = parameters.scale;
				tempyscale = parameters.scale;
			}else{
				if (parameters.xscale != null) tempxscale = parameters.xscale;
				if (parameters.yscale != null) tempyscale = parameters.yscale;
			}
			if (parameters.rotation != null) temprotate = parameters.rotation;
			if (parameters.alpha != null) tempalpha = parameters.alpha;
		}
		
		shapematrix.identity();
		shapematrix.translate( -tempxpivot, -tempypivot);
		if (temprotate != 0) shapematrix.rotate((temprotate * 3.1415) / 180);
		if (tempxscale != 1.0 || tempyscale != 1.0) shapematrix.scale(tempxscale, tempyscale);
		shapematrix.translate(x + tempxpivot, y + tempypivot);
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
	}
	
	/** Returns the current animation frame of the current tileset. */
	public static function currentframe():Int {
		return tiles[currenttileset].currentframe;
	}
	
	/** Resets the animation on this tileset. */
	public static function stopanimation():Void {
		tiles[currenttileset].animationspeed = 1;
		tiles[currenttileset].timethisframe = 0;
		tiles[currenttileset].currentframe = tiles[currenttileset].startframe;
		
		if (tiles[currenttileset].endframe == -1) {
			tiles[currenttileset].endframe = numberoftiles() - 1;
		}
	}
	
	public static function startframe(framenumber:Int):Void {
		if (framenumber < 0 || framenumber > numberoftiles() - 1) {
			trace("ERROR: Framenumber " + Std.string(framenumber) + " is out of bounds [0-" + Std.string(numberoftiles() - 1) + "].");
			return;
		}
		tiles[currenttileset].startframe = framenumber;
		
		if (tiles[currenttileset].currentframe < tiles[currenttileset].startframe) {
			tiles[currenttileset].currentframe = tiles[currenttileset].startframe;
		}
	}
	
	public static function endframe(framenumber:Int):Void {
		if (framenumber < 0 || framenumber > numberoftiles() - 1) {
			trace("ERROR: Framenumber " + Std.string(framenumber) + " is out of bounds [0-" + Std.string(numberoftiles() - 1) + "].");
			return;
		}
		tiles[currenttileset].endframe = framenumber;
		
		if (tiles[currenttileset].currentframe > tiles[currenttileset].endframe) {
			tiles[currenttileset].currentframe = tiles[currenttileset].startframe;
		}
	}
	
	public static function drawanimation(x:Float, y:Float, delayperframe:Int, ?parameters:Drawparams):Void {
		if (delayperframe < 1) {
			trace("ERROR: Cannot have a delay per frame of less than 1.");
			return;
		}
		tiles[currenttileset].animationspeed = delayperframe;
		
		tiles[currenttileset].timethisframe++;
		if (tiles[currenttileset].timethisframe > tiles[currenttileset].animationspeed) {
			tiles[currenttileset].timethisframe = 0;
	  	tiles[currenttileset].currentframe++;
			if (tiles[currenttileset].currentframe > tiles[currenttileset].endframe) {
				tiles[currenttileset].currentframe = tiles[currenttileset].startframe;
			}
		}
		
		if (parameters != null) {
		  drawtile(x, y, tiles[currenttileset].currentframe, parameters);
		}else {
			drawtile(x, y, tiles[currenttileset].currentframe);
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
	
	public static function drawline(x1:Float, y1:Float, x2:Float, y2:Float, col:Int):Void {
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(1, col);
		tempshape.graphics.lineTo(x2 - x1, y2 - y1);
		
		shapematrix.translate(x1, y1);
		drawto.draw(tempshape, shapematrix);
		shapematrix.translate(-x1, -y1);
	}
	
	public static function drawcircle(x:Float, y:Float, radius:Float, col:Int):Void {
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(1, col);
		tempshape.graphics.drawCircle(0, 0, radius);
		
		shapematrix.translate(x, y);
		drawto.draw(tempshape, shapematrix);
		shapematrix.translate(-x, -y);
	}
	
	public static function fillcircle(x:Float, y:Float, radius:Float, col:Int):Void {
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(1, col);
		tempshape.graphics.beginFill(col);
		tempshape.graphics.drawCircle(0, 0, radius);
		tempshape.graphics.endFill();
		
		shapematrix.translate(x, y);
		drawto.draw(tempshape, shapematrix);
		shapematrix.translate(-x, -y);
	}
	
	public static function drawtri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Int):Void {
		drawline(x1, y1, x2, y2, col);
		drawline(x2, y2, x3, y3, col);
		drawline(x3, y3, x1, y1, col);
	}
	
	public static function filltri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Int):Void {
		tempshape.graphics.clear();
		tempshape.graphics.beginFill(col);
		tempshape.graphics.lineTo(0, 0);
		tempshape.graphics.lineTo(x2 - x1, y2 - y1);
		tempshape.graphics.lineTo(x3 - x1, y3 - y1);
		tempshape.graphics.lineTo(0, 0);
		tempshape.graphics.endFill();
		
		
		shapematrix.translate(x1, y1);
		drawto.draw(tempshape, shapematrix);
		shapematrix.translate(-x1, -y1);
	}

	public static function drawbox(x:Float, y:Float, width:Float, height:Float, col:Int):Void {
		if (width < 0) {
			width = -width;
			x = x - width;
		}
		if (height < 0) {
			height = -height;
			y = y - height;
		}
		settrect(x, y, width, 1); drawto.fillRect(trect, col);
		settrect(x, y + height - 1, width, 1); drawto.fillRect(trect, col);
		settrect(x, y, 1, height); drawto.fillRect(trect, col);
		settrect(x + width - 1, y, 1, height); drawto.fillRect(trect, col);
	}

	public static function cls():Void {
		fillbox(0, 0, screenwidth, screenheight, 0x000000);
	}

	public static function fillbox(x:Float, y:Float, width:Float, height:Float, col:Int):Void {
		settrect(x, y, width, height);
		drawto.fillRect(trect, col);
	}
	
	public static function getred(c:Int):Int {
		return (( c >> 16 ) & 0xFF);
	}
	
	public static function getgreen(c:Int):Int {
		return ( (c >> 8) & 0xFF );
	}
	
	public static function getblue(c:Int):Int {
		return ( c & 0xFF );
	}
	
	public static function RGB(red:Int, green:Int, blue:Int):Int {
		return (blue | (green << 8) | (red << 16));
	}
	
	/** Picks a colour given Hue, Saturation and Lightness values. 
	 *  Hue is between 0-359, Saturation and Lightness between 0.0 and 1.0. */
	public static function HSL(hue:Float, saturation:Float, lightness:Float):Int{
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
		
		return RGB(Std.int(hslval[0] * 255), Std.int(hslval[1] * 255), Std.int(hslval[2] * 255));
	}
	
	private static function setzoom(t:Int):Void {
		screen.width = screenwidth * t;
		screen.height = screenheight * t;
		screen.x = (screenwidth - (screenwidth * t)) / 2;
		screen.y = (screenheight - (screenheight * t)) / 2;
	}
	
	public static function updategraphicsmode():Void {
		if (fullscreen) {
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			gfxstage.scaleMode = StageScaleMode.NO_SCALE;
			
			var xScaleFresh:Float = cast(devicexres, Float) / cast(screenwidth, Float);
			var yScaleFresh:Float = cast(deviceyres, Float) / cast(screenheight, Float);
			if (xScaleFresh < yScaleFresh){
				screen.width = screenwidth * xScaleFresh;
				screen.height = screenheight * xScaleFresh;
			}else if (yScaleFresh < xScaleFresh){
				screen.width = screenwidth * yScaleFresh;
				screen.height = screenheight * yScaleFresh;
			} else {
				screen.width = screenwidth * xScaleFresh;
				screen.height = screenheight * yScaleFresh;
			}
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
			gfxstage.quality = StageQuality.HIGH;
		}
	}
	
	public static var screenwidth:Int;
	public static var screenheight:Int;
	public static var screenwidthmid:Int;
	public static var screenheightmid:Int;
	
	public static var screenscale:Int;
	public static var devicexres:Int;
	public static var deviceyres:Int;
	public static var fullscreen:Bool;
	
	private static var tiles:Array<Tileset> = new Array<Tileset>();
	private static var tilesetindex:Map<String, Int> = new Map<String, Int>();
	private static var currenttileset:Int;
	public static var currenttilesetname:String;
	
	public static var drawto:BitmapData;
	
	private static var images:Array<BitmapData> = new Array<BitmapData>();
	private static var imagenum:Int;
	private static var ct:ColorTransform;
	private static var images_rect:Rectangle;
	private static var tl:Point = new Point(0, 0);
	private static var trect:Rectangle;
	private static var tpoint:Point;
	private static var tbuffer:BitmapData;
	private static var imageindex:Map<String, Int> = new Map<String, Int>();
	
	private static var temprotate:Float;
	private static var tempxscale:Float;
	private static var tempyscale:Float;
	private static var tempxpivot:Float;
	private static var tempypivot:Float;
	private static var tempalpha:Float;
	
	private static var buffer:BitmapData;
	
	private static var temptile:BitmapData;
	//Actual backgrounds
	public static var backbuffer:BitmapData;
	private static var screen:Bitmap;
	private static var tempshape:Shape = new Shape();
	private static var shapematrix:Matrix = new Matrix();
	
	private static var alphamult:Int;
	private static var gfxstage:Stage;
	
	//HSL conversion variables 
	private static var hslval:Array<Float> = new Array<Float>();
	
	public static var LEFT:Int = -20000;
	public static var RIGHT:Int = -20001;
	public static var TOP:Int = -20002;
	public static var BOTTOM:Int = -20003;
	public static var CENTER:Int = -20004;
}