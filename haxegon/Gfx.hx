package haxegon;

import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import starling.display.*;
import starling.geom.*;
import starling.core.StatsDisplay;
import starling.utils.AssetManager;
import starling.textures.*;
import openfl.Assets;

@:access(haxegon.Core)
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
	
	public static var screenscale:Int;
	public static var devicexres:Int;
	public static var deviceyres:Int;
	public static var fullscreen:Bool;
	
	public static var currenttilesetname:String;
	
	/** Create a screen with a given width, height and scale. Also inits Text. */
	public static function resizescreen(width:Float, height:Float, scale:Int = 1) {
		initgfx(Std.int(width), Std.int(height), scale);
		Text.init(gfxstage);
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
	public static function imagealpha(?alpha:Float) {
		if (alpha == null) alpha = 1.0;
		imagealphamult = alpha;
		coltransform = true;
		reset_ifclear();
	}
	
	/** Set a colour multipler and offset for image drawing functions. */
		public static function imagecolor(?color:Int) {
		if (color == null) color = 0xFFFFFF;
		imagecolormult = color;
		
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
	public static function loadtiles(imagename:String, width:Int, height:Int) {	
	  var tex:starling.textures.Texture;
		if (imageindex.exists(imagename)) {
		  //We've already loaded the image for this somewhere, probably from a packed texture
			//In any case, we use that texture as the source for these tiles
			tex = getassetpackedtexture(imagename);
		}else{
			try {
				tex = Texture.fromBitmapData(Assets.getBitmapData("data/graphics/" + imagename + ".png"), false);	
			}catch (e:Dynamic) {
				throw("ERROR: In loadimage, cannot find data/graphics/" + imagename + ".png.");
				return;
			}
			
			starlingassets.addTexture(imagename, tex);
		}
		
		//
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
		var tileset:Int = 0;
		if(tilesetindex.exists(tilesetname)){
			tileset = tilesetindex.get(tilesetname);
		}else {
			throw("ERROR: Cannot add blank tiles to tileset \"" + tilesetname + "\", no tileset with that name found.");
		}
		
		var w:Int = Std.int(tiles[tileset].tiles[0].width);
		var h:Int = Std.int(tiles[tileset].tiles[0].height);
		for (i in 0 ... num) {
			var tex:Texture = Texture.fromBitmapData(new BitmapData(w, h, true, 0), false);
			var img:Image = new Image(tex);
			img.touchable = false;
			tiles[tileset].tiles.push(img);
		}
	}
	
	/** Creates a blank tileset, with the name "tilesetname", with each tile a given width and height, containing "amount" tiles. */
	public static function createtiles(tilesetname:String, width:Float, height:Float, amount:Int) {
		var exindex:Null<Int> = tilesetindex.get(tilesetname);
		if (exindex == null) {
			tiles.push(new haxegon.util.Tileset(tilesetname, Std.int(width), Std.int(height)));
			tilesetindex.set(tilesetname, tiles.length - 1);
			currenttileset = tiles.length - 1;
			
			for (i in 0 ... amount) {
				var tex:Texture = Texture.fromBitmapData(new BitmapData(Math.floor(width), Math.floor(height), true, 0), false);
				var img:Image = new Image(tex);
				img.touchable = false;
				tiles[currenttileset].tiles.push(img);
			}
			
			changetileset(tilesetname);
		}else {
			changetileset(tilesetname);
			
			var purge:Bool = (tiles[currenttileset].width != Math.floor(width) || tiles[currenttileset].height != Math.floor(height));
			tiles[currenttileset].width = Math.floor(width);
			tiles[currenttileset].height = Math.floor(height);
			
			// Delete all excess or wrongly-sized tiles
			while (tiles[currenttileset].tiles.length > (purge ? 0 : amount)) {
				var extile:Image = tiles[currenttileset].tiles.pop();
				extile.touchable = false;
				extile.texture.dispose();
				extile.dispose();
			}
			
			// Create tiles, repurposing RenderTexture tiles when available
			for (i in 0 ... amount) {
				if (i < tiles[currenttileset].tiles.length && !purge && Std.is(tiles[currenttileset].tiles[i].texture, RenderTexture)) {
					cast(tiles[currenttileset].tiles[i].texture, RenderTexture).clear();
				} else {
					var tex:Texture = Texture.fromBitmapData(new BitmapData(Math.floor(width), Math.floor(height), true, 0), false);
					var img:Image = new Image(tex);
					img.touchable = false;
					
					if (i < tiles[currenttileset].tiles.length) {
						tiles[currenttileset].tiles[i].texture.dispose();
						tiles[currenttileset].tiles[i].dispose();
						tiles[currenttileset].tiles[i] = img;
					} else {
						tiles[currenttileset].tiles.push(img);
					}
				}
			}
		}
	}
	
	/** Returns the width of a tile in the current tileset. */
	public static function tilewidth(tilesetname:String):Int {
		changetileset(tilesetname);
		return tiles[currenttileset].width;
	}
	
	/** Returns the height of a tile in the current tileset. */
	public static function tileheight(tilesetname:String):Int {
		changetileset(tilesetname);
		return tiles[currenttileset].height;
	}

	/** Loads a texture from Starling. */
	private static function getassetpackedtexture(imagename:String):Texture {
		var bd:Texture = null;
		try {
			bd = starlingassets.getTexture(imagename);
		}catch (e:Dynamic) {
			throw("ERROR: Cannot find " + imagename + ".png in packed textures.");
		}
		return bd;
	}
	
	
	/** Loads a packed texture into Gfx. */
	private static function loadimagefrompackedtexture(imagename:String, tex:Texture) {
		imageindex.set(imagename, images.length);
		images.push(new Image(tex));
		images[images.length - 1].smoothing = "none";
	}		
	
	/** Loads an image into the game. */
	public static function loadimage(imagename:String) {
		if (imageindex.exists(imagename)) return; //This is already loaded, so we're done!
		
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
		//loadimagefrompackedtexture(imagename, getassetpackedtexture(imagename));
	}
	
	/** Creates a blank image, with the name "imagename", with given width and height. */
	public static function createimage(imagename:String, width:Float, height:Float) {
		var tex:Texture = Texture.fromBitmapData(new BitmapData(Math.floor(width), Math.floor(height), true, 0), false);
		var img:Image = new Image(tex);
		img.touchable = false;

		var exindex:Null<Int> = imageindex.get(imagename);
		if (exindex == null) {
			imageindex.set(imagename, images.length);
			images.push(img);
		}else {
			images[exindex].texture.dispose();
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
		if (!imageindex.exists(imagename)) {
			loadimage(imagename);
		}	
		
		var imagenum:Int = imageindex.get(imagename);
		return Std.int(images[imagenum].width);
	}
	
	/** Returns the height of the image. */
	public static function imageheight(imagename:String):Int {
		if (!imageindex.exists(imagename)) {
			loadimage(imagename);
		}	
		
		var imagenum:Int = imageindex.get(imagename);
		return Std.int(images[imagenum].height);
	}
	
	private static function promotetorendertarget(image:Image) {
		if (!Std.is(image.texture, RenderTexture)) {
			var newtexture:RenderTexture = new RenderTexture(Std.int(image.texture.width), Std.int(image.texture.height));
			
			// Copy the old texture to the new RenderTexture
			shapematrix.identity();
			newtexture.draw(image, shapematrix);
			
			// Clean up the old texture and swap
			image.texture.dispose();
			image.texture = newtexture;
		}
	}

	/** Tell draw commands to draw to the given image. */
	public static function drawtoscreen() {
		drawto = backbuffer;
	}
	
	/** Tell draw commands to draw to the given image. */
	public static function drawtoimage(imagename:String) {
		if (!imageindex.exists(imagename)) {
			throw("ERROR: In drawtoimage, cannot find image \"" + imagename + "\".");
			return;
		}
		
		var imagenum:Int = imageindex.get(imagename);
		promotetorendertarget(images[imagenum]);
		drawto = cast(images[imagenum].texture, RenderTexture);
	}
	
	/** Tell draw commands to draw to the given tile in the current tileset. */
	public static function drawtotile(tilesetname:String, t:Int) {
		var tileset:Int = 0;
		if(tilesetindex.exists(tilesetname)){
			tileset = tilesetindex.get(tilesetname);
		}else {
			throw("ERROR: Cannot change to tileset \"" + tilesetname + "\", no tileset with that name found.");
		}
		
		if (t >= numberoftiles(tilesetname)) {
			if (t == numberoftiles(tilesetname)) {
				throw("ERROR: Tried to draw tile number " + Std.string(t) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(t) + " is not a valid tile.)");
			}else{
				throw("ERROR: Tried to draw tile number " + Std.string(t) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
			}
		}

		promotetorendertarget(tiles[tileset].tiles[t]);
		drawto = cast(tiles[tileset].tiles[t].texture, RenderTexture);
	}
	
	/** Helper function for image drawing functions. */
	private static var t1:Float;
	private static var t2:Float;
	private static var t3:Float;
	private static function imagealignx(image:Image, x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Gfx.screenwidthmid - Std.int(image.width / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + image.width;
			}
		}
		
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealigny(image:Image, y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Gfx.screenheightmid - Std.int(image.height / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + image.height;
			}
		}
		
		return y;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagex(image:Image, x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Std.int(image.width / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + image.width;
			}
		}
		
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagey(image:Image, y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Std.int(image.height / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + image.height;
			}
		}
		
		return y;
	}
	
	private static function internaldrawimage(x:Float, y:Float, image:Image) {
		if (!transform && !coltransform) {
			shapematrix.identity();
			shapematrix.translate(Std.int(x), Std.int(y));
			drawto.draw(image, shapematrix);
		}else {
			tempxalign = 0;	tempyalign = 0;
			
			shapematrix.identity();
			
			if (imagexscale != 1.0 || imageyscale != 1.0) {
				if (imagescalexpivot != 0.0) tempxalign = imagealignonimagex(image, imagescalexpivot);
				if (imagescaleypivot != 0.0) tempyalign = imagealignonimagey(image, imagescaleypivot);
				shapematrix.translate( -tempxalign, -tempyalign);
				shapematrix.scale(imagexscale, imageyscale);
				shapematrix.translate( tempxalign, tempyalign);
			}
			
			if (imagerotate != 0) {
				if (imagerotatexpivot != 0.0) tempxalign = imagealignonimagex(image, imagerotatexpivot);
				if (imagerotateypivot != 0.0) tempyalign = imagealignonimagey(image, imagerotateypivot);
				shapematrix.translate( -tempxalign, -tempyalign);
				shapematrix.rotate((imagerotate * 3.1415) / 180);
				shapematrix.translate( tempxalign, tempyalign);
			}
			
			shapematrix.translate(x, y);
			if (coltransform) {
				image.color = imagecolormult;
				drawto.draw(image, shapematrix, imagealphamult);
				image.color = Col.WHITE;
			}else {
				drawto.draw(image, shapematrix);
			}
		}		
	}
	
	/** Draws image by name. 
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * */
	public static function drawimage(x:Float, y:Float, imagename:String) {
		if (!imageindex.exists(imagename)) {
			loadimage(imagename);
		}

		var image:Image = images[imageindex.get(imagename)];
		x = imagealignx(image, x); y = imagealigny(image, y);
		internaldrawimage(x, y, image);
	}
	
	/** Draws image by name. 
	 * x and y are the point at which to render.
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * x1, y1, w1, h1 describe the rectangle of the image to use.
	 * */
	public static function drawsubimage(x:Float, y:Float, x1:Float, y1:Float, w1:Float, h1:Float, imagename:String) {
		if (!imageindex.exists(imagename)) {
			throw("ERROR: In drawsubimage, cannot find image \"" + imagename + "\".");
			return;
		}
		
		var image:Image = images[imageindex.get(imagename)];
		x = imagealignx(image, x); y = imagealigny(image, y);
		
		// Acquire SubTexture and build an Image from it.
		trect.x = x1;
		trect.y = y1;
		trect.width = w1;
		trect.height = h1;

		// 2 allocs. avoidable with pooling?
		var subtex:Texture = Texture.fromTexture(image.texture, trect);
		var subimage:Image = new Image(subtex); // alloc. avoidable with pooling?
		subimage.touchable = false;
		
		internaldrawimage(x, y, subimage);

		// all done! clean up
		subtex.dispose();
		subimage.dispose();
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
	 * x1, y1, w1, h1 describe the rectangle of the tile to use.
	 * */
	public static function drawsubtile(x:Float, y:Float, x1:Float, y1:Float, w:Float, h:Float, tilesetname:String, t:Int) {
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
		
		// Acquire SubTexture and build an Image from it.
		trect.x = x1;
		trect.y = y1;
		trect.width = w;
		trect.height = h;

		// 2 allocs. avoidable with pooling?
		var subtex:Texture = Texture.fromTexture(tiles[currenttileset].tiles[t].texture, trect);
		var subimage:Image = new Image(subtex);
		subimage.touchable = false;
		
		internaldrawimage(x, y, subimage);

		// all done! clean up
		subtex.dispose();
		subimage.dispose();		
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
		
		internaldrawimage(x, y, tiles[currenttileset].tiles[t]);
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
		if (col == Col.TRANSPARENT) return;
		templine = new Line(_x1, _y1, _x2, _y2, linethickness, col);
		templine.alpha = alpha;
		
		drawto.draw(templine);
	}

	public static function drawhexagon(x:Float, y:Float, radius:Float, angle:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		var tempring:Ring = new Ring(radius - linethickness, radius, col, true, 6, angle);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		drawto.draw(tempring, shapematrix);
	}
	
	public static function fillhexagon(x:Float, y:Float, radius:Float, angle:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		var tempring:Disk = new Disk(radius, col, true, 6, angle);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		drawto.draw(tempring, shapematrix);
	}
	
	public static function drawcircle(x:Float, y:Float, radius:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		var tempring:Ring = new Ring(radius - linethickness, radius, col);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		drawto.draw(tempring, shapematrix);
	}
	
	public static function fillcircle(x:Float, y:Float, radius:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		var tempring:Disk = new Disk(radius, col);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		drawto.draw(tempring, shapematrix);
	}
	
	public static function drawtri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		drawline(x1, y1, x2, y2, col, alpha);
		drawline(x1, y1, x3, y3, col, alpha);
		drawline(x2, y2, x3, y3, col, alpha);
	}
	
	
	public static function filltri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		temppoly4 = new Poly4(x1, y1, x2, y2, x3, y3, x3, y3, col);
		temppoly4.alpha = alpha;
		drawto.draw(temppoly4);
	}

	public static function drawbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
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
		drawto.clear(col, 1.0);
	}
	
	public static function setpixel(x:Float, y:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		fillbox(x, y, 1, 1, col, alpha);
	}

	public static function fillbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		tempquad.x = x;
		tempquad.y = y;
		tempquad.width = width;
		tempquad.height = height;
		tempquad.color = col;
		tempquad.alpha = alpha;
		drawto.draw(tempquad);
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
	
	public static function getscreenx(_x:Float) : Int {
		return Math.floor((_x - screen.x) * screenwidth / screen.width);
	}

	public static function getscreeny(_y:Float) : Int {
		return Math.floor((_y - screen.y) * screenheight / screen.height);
	}
	
	/** Gives Gfx access to the stage, and preloads packed textures. */
	private static function init(stage:Stage) {
		gfxstage = stage;
		linethickness = 1;
		
		loadpackedtextures();
		
		reset();
	}	
	
	private static function loadpackedtextures() {
		if(!gfxinit){
			starlingassets = new AssetManager();
			starlingassets.verbose = false;
			
			//Scan for packed textures
			var atlasnum:Int = 0;
			for (t in Assets.list(AssetType.TEXT)) {
				var extension:String = S.getlastbranch(t, ".");
				if (extension == "xml") {
					//A packed texture is an XML file containing "TextureAtlas" as the first element
					var xml:Xml = Xml.parse(Assets.getText(t)).firstElement();
					if (xml.nodeName == "TextureAtlas") {
						//Cool, it's a packed texture! Let's load it in!
						var texturepackedimage:Texture = Texture.fromBitmapData(Assets.getBitmapData("data/graphics/" + xml.get("imagePath")), false);
						starlingassets.addTexture("atlas" + atlasnum, texturepackedimage);
						starlingassets.addTextureAtlas("atlas" + atlasnum, new TextureAtlas(texturepackedimage, xml));
						atlasnum++;
						
						//Ok, now we work though the XML and load all the images
						for (i in xml.elementsNamed("SubTexture")) {
							loadimagefrompackedtexture(i.get("name"), getassetpackedtexture(i.get("name")));
						}
						//for(i in xml.
					}
				}
			}
		}
	}
	
	/** Called from resizescreen(). Sets up all our graphics buffers. */
	private static function initgfx(width:Int, height:Int, scale:Int) {
		//We initialise a few things
		screenwidth = width; screenheight = height;
		screenwidthmid = Std.int(screenwidth / 2); screenheightmid = Std.int(screenheight / 2);
		
		devicexres = Std.int(openfl.system.Capabilities.screenResolutionX);
		deviceyres = Std.int(openfl.system.Capabilities.screenResolutionY);
		screenscale = scale;
		
		tempquad.touchable = false;
		//temppoly4 = new Poly4();
		
		if(!gfxinit){
			backbuffer = new RenderTexture(width, height, false);
			drawto = backbuffer;
			screen = new Image(backbuffer);
			screen.touchable = false;
			screen.scale = scale;
			screen.smoothing = "none";
			gfxstage.addChild(screen);
			
			if (Core.showstats) {
			  Core.statsdisplay = new StatsDisplay();
				gfxstage.addChild(Core.statsdisplay);
			}else {
				if(Core.statsdisplay != null) gfxstage.removeChild(Core.statsdisplay);
			}
		}
		
		gfxinit = true;
	}
	
	/** Sets the values for the temporary rect structure. Probably better than making a new one, idk */
	private inline static function settrect(x:Float, y:Float, w:Float, h:Float) {
		trect.x = x;
		trect.y = y;
		trect.width = w;
		trect.height = h;
	}
	
	private static var backbuffer:RenderTexture;
	private static var drawto:RenderTexture;
	private static var screen:Image;
	private static var tempquad:Quad = new Quad(1, 1);
	private static var temppoly4:Poly4;
	private static var templine:Line;
	
	private static var starlingassets:AssetManager;
	private static var trect:Rectangle = new Rectangle();
	private static var shapematrix:Matrix = new Matrix();
	
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
	
	private static var tiles:Array<haxegon.util.Tileset> = new Array<haxegon.util.Tileset>();
	private static var tilesetindex:Map<String, Int> = new Map<String, Int>();
	private static var currenttileset:Int = -1;
	
	private static var gfxinit:Bool = false;
}