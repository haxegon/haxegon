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
		screenbuffer = new BitmapData(screenwidth, screenheight, false, 0x000000);
		
		drawto = backbuffer;
		
		screen = new Bitmap(screenbuffer);
		screen.width = screenwidth * scale;
		screen.height = screenheight * scale;
		
		fullscreen = false;
		
		Debug.test = false;
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
		
	/** Makes a tile array from a given image. */
	public static function maketiles(imagename:String, width:Int, height:Int):Void {
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
	
	/** Loads an image into the game. */
	public static function addimage(imagename:String):Void {
		buffer = new Bitmap(Assets.getBitmapData("data/graphics/" + imagename + ".png")).bitmapData;
		imageindex.set(imagename, images.length);
		
		var t:BitmapData = new BitmapData(buffer.width, buffer.height, true, 0x000000);
		settrect(0, 0, buffer.width, buffer.height);			
		t.copyPixels(buffer, trect, tl);
		images.push(t);
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignx(x:Int):Int {
		if (x == CENTER) return Gfx.screenwidthmid - Std.int(images[imagenum].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return images[imagenum].width;
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealigny(y:Int):Int {
		if (y == CENTER) return Gfx.screenheightmid - Std.int(images[imagenum].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return images[imagenum].height;
		return y;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagex(x:Int):Int {
		if (x == CENTER) return Std.int(images[imagenum].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return images[imagenum].width;
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagey(y:Int):Int {
		if (y == CENTER) return Std.int(images[imagenum].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return images[imagenum].height;
		return y;
	}
	
	/** Draws image by name. 
	 * x and y can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage(x:Int, y:Int, imagename:String):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		shapematrix.identity();
		shapematrix.translate(x, y);
		backbuffer.draw(images[imagenum], shapematrix);
	}
	
	/** Draws image by name, with a single scale value.
	 * x, y, pivotx and pivoty can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage_scale(x:Int, y:Int, imagename:String, scale:Float, pivotx:Int, pivoty:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		pivotx = imagealignonimagex(pivotx); pivoty = imagealignonimagey(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.scale(scale, scale);
		shapematrix.translate(x + pivotx, y + pivoty);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	/** Draws image by name, with individual x and y scales.
	 * x, y, pivotx and pivoty can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage_freescale(x:Int, y:Int, imagename:String, xscale:Float, yscale:Float, pivotx:Int, pivoty:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		pivotx = imagealignonimagex(pivotx); pivoty = imagealignonimagey(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + pivotx, y + pivoty);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	/** Draws image by name, with rotation around point pivotx, pivoty.
	 * x, y, pivotx and pivoty can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage_rotate(x:Int, y:Int, imagename:String, rotate:Int, pivotx:Int, pivoty:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		pivotx = imagealignonimagex(pivotx); pivoty = imagealignonimagey(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.translate(x + pivotx, y + pivoty);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	/** Draws image by name, with single scale value and rotation.
	 * x, y, pivotx and pivoty can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage_scale_rotate(x:Int, y:Int, imagename:String, scale:Float, rotate:Int, pivotx:Int, pivoty:Int):Void {
		drawimage_freescale_rotate(x, y, imagename, scale, scale, rotate, pivotx, pivoty);
	}
	
	/** Draws image by name, with individual x and y scales and rotation.
	 * x, y, pivotx and pivoty can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage_freescale_rotate(x:Int, y:Int, imagename:String, xscale:Float, yscale:Float, rotate:Int, pivotx:Int, pivoty:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		pivotx = imagealignonimagex(pivotx); pivoty = imagealignonimagey(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + pivotx, y + pivoty);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	/** Draws image by name, with colour transform.
	 * x and y can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage_col(x:Int, y:Int, imagename:String, col:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		
  	shapematrix.identity();
		shapematrix.translate(x, y);
		ct.color = col;
		drawto.draw(images[imagenum], shapematrix, ct);
	}
	
	/** Draws image by name, with single scale value and colour transform.
	 * x, y, pivotx and pivoty can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage_scale_col(x:Int, y:Int, imagename:String, scale:Float, pivotx:Int, pivoty:Int, col:Int):Void {
		drawimage_freescale_col(x, y, imagename, scale, scale, pivotx, pivoty, col);
	}
	
	/** Draws image by name, with individual x and y scales and colour transform.
	 * x, y, pivotx and pivoty can be: CENTER, TOP, BOTTOM, LEFT, RIGHT. */
	public static function drawimage_freescale_col(x:Int, y:Int, imagename:String, xscale:Float, yscale:Float, pivotx:Int, pivoty:Int, col:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		pivotx = imagealignonimagex(pivotx); pivoty = imagealignonimagey(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + pivotx, y + pivoty);
		ct.color = col;
		drawto.draw(images[imagenum], shapematrix, ct);
	}
	
	public static function drawimage_rotate_col(x:Int, y:Int, imagename:String, rotate:Int, pivotx:Int, pivoty:Int, col:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		pivotx = imagealignonimagex(pivotx); pivoty = imagealignonimagey(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.translate(x + pivotx, y + pivoty);
		ct.color = col;
		drawto.draw(images[imagenum], shapematrix, ct);
	}
	
	public static function drawimage_scale_rotate_col(x:Int, y:Int, imagename:String, scale:Float, rotate:Int, pivotx:Int, pivoty:Int, col:Int):Void {
		drawimage_freescale_rotate_col(x, y, imagename, scale, scale, rotate, pivotx, pivoty, col);
	}
	
	public static function drawimage_freescale_rotate_col(x:Int, y:Int, imagename:String, xscale:Float, yscale:Float, rotate:Int, pivotx:Int, pivoty:Int, col:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		pivotx = imagealignonimagex(pivotx); pivoty = imagealignonimagey(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + pivotx, y + pivoty);
		ct.color = col;
		drawto.draw(images[imagenum], shapematrix, ct);
	}
	
	public static function drawtile(x:Int, y:Int, t:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
			
		shapematrix.identity();
		shapematrix.translate(x, y);
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
	}
	
	private static function tilealignx(x:Int):Int {
		if (x == CENTER) return Gfx.screenwidthmid - Std.int(tiles[currenttileset].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return tiles[currenttileset].width;
		return x;
	}
	
	private static function tilealigny(y:Int):Int {
		if (y == CENTER) return Gfx.screenheightmid - Std.int(tiles[currenttileset].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return tiles[currenttileset].height;
		return y;
	}
	
	private static function tilealignontilex(x:Int):Int {
		if (x == CENTER) return Std.int(tiles[currenttileset].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return tiles[currenttileset].width;
		return x;
	}
	
	private static function tilealignontiley(y:Int):Int {
		if (y == CENTER) return Std.int(tiles[currenttileset].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return tiles[currenttileset].height;
		return y;
	}
	
	public static function drawtile_scale(x:Int, y:Int, t:Int, scale:Float, pivotx:Int, pivoty:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
		pivotx = tilealignontilex(pivotx); pivoty = tilealignontilex(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.scale(scale, scale);
		shapematrix.translate(x + pivotx, y + pivoty);
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
	}
	
	public static function drawtile_freescale(x:Int, y:Int, t:Int, xscale:Float, yscale:Float, pivotx:Int, pivoty:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
		pivotx = tilealignontilex(pivotx); pivoty = tilealignontilex(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + pivotx, y + pivoty);
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
	}
	
	public static function drawtile_rotate(x:Int, y:Int, t:Int, rotate:Int, pivotx:Int, pivoty:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
		pivotx = tilealignontilex(pivotx); pivoty = tilealignontilex(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.translate(x + pivotx, y + pivoty);
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
	}
	
	public static function drawtile_scale_rotate(x:Int, y:Int, t:Int, scale:Float, rotate:Int, pivotx:Int, pivoty:Int):Void {
	  drawtile_freescale_rotate(x, y, t, scale, scale, rotate, pivotx, pivoty);
	}
	
	public static function drawtile_freescale_rotate(x:Int, y:Int, t:Int, xscale:Float, yscale:Float, rotate:Int, pivotx:Int, pivoty:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
		pivotx = tilealignontilex(pivotx); pivoty = tilealignontilex(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + pivotx, y + pivoty);
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
	}
	
	public static function drawtile_col(x:Int, y:Int, t:Int, col:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
		
		shapematrix.identity();
		shapematrix.translate(x, y);
		ct.color = col;
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix, ct);
	}
	
	public static function drawtile_scale_col(x:Int, y:Int, t:Int, scale:Float, pivotx:Int, pivoty:Int, col:Int):Void {
		drawtile_freescale_col(x, y, t, scale, scale, pivotx, pivoty, col);
	}
	
	public static function drawtile_freescale_col(x:Int, y:Int, t:Int, xscale:Float, yscale:Float, pivotx:Int, pivoty:Int, col:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
		pivotx = tilealignontilex(pivotx); pivoty = tilealignontilex(pivoty);
		
		shapematrix.identity();
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x, y);
		ct.color = col;
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix, ct);
	}
	
	public static function drawtile_rotate_col(x:Int, y:Int, t:Int, rotate:Int, pivotx:Int, pivoty:Int, col:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.translate(x + pivotx, y + pivoty);
		ct.color = col;
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix, ct);
	}
	
	public static function drawtile_scale_rotate_col(x:Int, y:Int, t:Int, scale:Float, rotate:Int, pivotx:Int, pivoty:Int, col:Int):Void {
	  drawtile_freescale_rotate_col(x, y, t, scale, scale, rotate, pivotx, pivoty, col);
	}
	
	
	public static function drawtile_freescale_rotate_col(x:Int, y:Int, t:Int, xscale:Float, yscale:Float, rotate:Int, pivotx:Int, pivoty:Int, col:Int):Void {
		x = tilealignx(x); y = tilealigny(y);
		pivotx = tilealignontilex(pivotx); pivoty = tilealignontilex(pivoty);
		
		shapematrix.identity();
		shapematrix.translate(-pivotx, -pivoty);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + pivotx, y + pivoty);
		ct.color = col;
		drawto.draw(tiles[currenttileset].tiles[t], shapematrix, ct);
	}
	
	public static function drawline(x1:Float, y1:Float, x2:Float, y2:Float, col:Int):Void {
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(1, col);
		tempshape.graphics.lineTo(x2 - x1, y2 - y1);
		
		shapematrix.translate(x1, y1);
		backbuffer.draw(tempshape, shapematrix);
		shapematrix.translate(-x1, -y1);
	}
	
	public static function drawcircle(x:Float, y:Float, radius:Float, col:Int):Void {
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(1, col);
		tempshape.graphics.drawCircle(0, 0, radius);
		
		shapematrix.translate(x, y);
		backbuffer.draw(tempshape, shapematrix);
		shapematrix.translate(-x, -y);
	}
	
	public static function fillcircle(x:Float, y:Float, radius:Float, col:Int):Void {
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(1, col);
		tempshape.graphics.beginFill(col);
		tempshape.graphics.drawCircle(0, 0, radius);
		tempshape.graphics.endFill();
		
		shapematrix.translate(x, y);
		backbuffer.draw(tempshape, shapematrix);
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
		backbuffer.draw(tempshape, shapematrix);
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
		settrect(x, y, width, 1); backbuffer.fillRect(trect, col);
		settrect(x, y + height - 1, width, 1); backbuffer.fillRect(trect, col);
		settrect(x, y, 1, height); backbuffer.fillRect(trect, col);
		settrect(x + width - 1, y, 1, height); backbuffer.fillRect(trect, col);
	}

	public static function cls():Void {
		fillbox(0, 0, screenwidth, screenheight, 0x000000);
	}

	public static function fillbox(x:Float, y:Float, width:Float, height:Float, col:Int):Void {
		settrect(x, y, width, height);
		backbuffer.fillRect(trect, col);
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
		
		var hk:Float = (hue % 360) / 360;
		
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
	
	//Render functions
	public static function screenrender():Void {
		backbuffer.unlock();
		
		screenbuffer.lock();
		screenbuffer.copyPixels(backbuffer, backbuffer.rect, tl, null, null, false);
		screenbuffer.unlock();
		
		backbuffer.lock();
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
	public static var screentilewidth:Int;
	public static var screentileheight:Int;
	
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
	
	private static var buffer:BitmapData;
	
	private static var temptile:BitmapData;
	//Actual backgrounds
	public static var backbuffer:BitmapData;
	private static var screenbuffer:BitmapData;
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