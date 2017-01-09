package haxegon;

import flash.display.StageDisplayState;
import flash.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import starling.display.*;
import starling.geom.*;
import starling.core.StatsDisplay;
import starling.utils.AssetManager;
import starling.textures.*;
import openfl.Assets;
import starling.events.ResizeEvent;
import starling.core.Starling;

class HaxegonTileset {
	public function new(n:String, w:Int, h:Int) {
		name = n;
		width = w;
		height = h;
		
		tiles = [];
	}
	
	public var tiles:Array<Image>;
	public var name:String;
	public var width:Int;
	public var height:Int;
}

@:access(haxegon.Core)
@:access(haxegon.Data)
@:access(haxegon.Text)
class Gfx {    
	private static inline var MAX_NUM_QUADS:Int = 16383;
	public static var LEFT:Int = -10000;
	public static var RIGHT:Int = -20000;
	public static var TOP:Int = -10000;
	public static var BOTTOM:Int = -20000;
	public static var CENTER:Int = -15000;
	
	public static var screenwidth:Int;
	public static var screenheight:Int;
	public static var screenwidthmid:Int;
	public static var screenheightmid:Int;
	
	private static var devicexres:Int;
	private static var deviceyres:Int;
	
	private static var currenttilesetname:String;
	
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
 				Debug.log("ERROR: Cannot change to tileset \"" + tilesetname + "\", no tileset with that name found.");
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
		}else {
			if(Data.assetexists("data/graphics/" + imagename + ".png")){
				tex = Texture.fromBitmapData(Data.getgraphicsasset("data/graphics/" + imagename + ".png"), false);
			}else if (Data.assetexists("data/graphics/" + imagename + ".jpg")) {
				tex = Texture.fromBitmapData(Data.getgraphicsasset("data/graphics/" + imagename + ".jpg"), false);
			}else {
				Debug.log("ERROR: In loadtiles, cannot find \"data/graphics/" + imagename + ".png\" or \"data/graphics/" + imagename + ".jpg\"");
				return;
			}	
			
			starlingassets.addTexture(imagename, tex);
		}
		
		//
		var spritesheet:Texture = starlingassets.getTexture(imagename);
		
		var tiles_rect:Rectangle = new Rectangle(0, 0, width, height);
		tiles.push(new HaxegonTileset(imagename, width, height));
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
			Debug.log("ERROR: Cannot add blank tiles to tileset \"" + tilesetname + "\", no tileset with that name found.");
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
			tiles.push(new HaxegonTileset(tilesetname, Std.int(width), Std.int(height)));
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
			Debug.log("ERROR: Cannot find " + imagename + ".png in packed textures.");
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
		if(Data.assetexists("data/graphics/" + imagename + ".png")){
		  tex = Texture.fromBitmapData(Data.getgraphicsasset("data/graphics/" + imagename + ".png"), false);
		}else if (Data.assetexists("data/graphics/" + imagename + ".jpg")) {
			tex = Texture.fromBitmapData(Data.getgraphicsasset("data/graphics/" + imagename + ".jpg"), false);
		}else {
			Debug.log("ERROR: In loadimage, cannot find \"data/graphics/" + imagename + ".png\" or \"data/graphics/" + imagename + ".jpg\"");
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
		img.smoothing = "none";

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
		Gfx.endquadbatch();
		if (drawto != null) drawto.bundleunlock();
		
		drawto = backbuffer;
		
		if (drawto != null) drawto.bundlelock();
	}
	
	/** Tell draw commands to draw to the given image. */
	public static function drawtoimage(imagename:String) {
		if (!imageindex.exists(imagename)) {
			Debug.log("ERROR: In drawtoimage, cannot find image \"" + imagename + "\".");
			return;
		}
		
		Gfx.endquadbatch();
		if (drawto != null) drawto.bundleunlock();
		
		var imagenum:Int = imageindex.get(imagename);
		promotetorendertarget(images[imagenum]);
		drawto = cast(images[imagenum].texture, RenderTexture);
		
		if (drawto != null) drawto.bundlelock();
	}
	
	/** Tell draw commands to draw to the given tile in the current tileset. */
	public static function drawtotile(tilesetname:String, tilenum:Int) {
		var tileset:Int = 0;
		if(tilesetindex.exists(tilesetname)){
			tileset = tilesetindex.get(tilesetname);
		}else {
			Debug.log("ERROR: Cannot change to tileset \"" + tilesetname + "\", no tileset with that name found.");
		}
		
		if (tilenum >= numberoftiles(tilesetname)) {
			if (tilenum == numberoftiles(tilesetname)) {
				Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(tilenum) + " is not a valid tile.)");
			}else{
				Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
			}
		}
		
		Gfx.endquadbatch();
		if (drawto != null) drawto.bundleunlock();
		
		promotetorendertarget(tiles[tileset].tiles[tilenum]);
		drawto = cast(tiles[tileset].tiles[tilenum].texture, RenderTexture);
		
		if (drawto != null) drawto.bundlelock();
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
		Gfx.endquadbatch();
		
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
			Debug.log("ERROR: In drawsubimage, cannot find image \"" + imagename + "\".");
			return;
		}
		Gfx.endquadbatch();
		
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
	
	public static function grabtilefromscreen(tilesetname:String, tilenumber:Int, screenx:Float, screeny:Float) {
		Gfx.endquadbatch();
		trace("warning: Gfx.grabtilefromscreen is not implemented");
	}
	
	public static function grabtilefromimage(tilesetname:String, tilenumber:Int, imagename:String, imagex:Float, imagey:Float) {
		Gfx.endquadbatch();
		trace("warning: Gfx.grabtilefromimage is not implemented");
	}
	
	public static function grabimagefromscreen(imagename:String, screenx:Float, screeny:Float) {
		Gfx.endquadbatch();
		trace("warning: Gfx.grabimagefromscreen is not implemented");
	}
	
	public static function grabimagefromimage(imagetocopyto:String, sourceimage:String, sourceimagex:Float, sourceimagey:Float) {
		Gfx.endquadbatch();
		trace("warning: Gfx.grabimagefromimage is not implemented");
	}
	
	public static function copytile(totileset:String, totilenumber:Int, fromtileset:String, fromtilenumber:Int) {
		Gfx.endquadbatch();
		trace("warning: Gfx.copytile is not implemented");
	}
	
	/** Draws tile number t from current tileset.
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * x1, y1, w1, h1 describe the rectangle of the tile to use.
	 * */
	public static function drawsubtile(x:Float, y:Float, tilesetname:String, tilenum:Int, x1:Float, y1:Float, w:Float, h:Float) {
		changetileset(tilesetname);
		
		if (tilenum >= numberoftiles(tilesetname)) {
			if (tilenum == numberoftiles(tilesetname)) {
 			  Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(tilenum) + " is not a valid tile.)");
				return;
			}else{
				Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
				return;
			}
		}
		Gfx.endquadbatch();
		
		x = tilealignx(x); y = tilealigny(y);
		
		// Acquire SubTexture and build an Image from it.
		trect.x = x1;
		trect.y = y1;
		trect.width = w;
		trect.height = h;

		// 2 allocs. avoidable with pooling?
		var subtex:Texture = Texture.fromTexture(tiles[currenttileset].tiles[tilenum].texture, trect);
		var subimage:Image = new Image(subtex);
		subimage.touchable = false;
		
		internaldrawimage(x, y, subimage);

		// all done! clean up
		subtex.dispose();
		subimage.dispose();		
	}
	
	public static function drawtile(x:Float, y:Float, tilesetname:String, tilenum:Int) {
		changetileset(tilesetname);
		
		if (tilenum >= numberoftiles(tilesetname)) {
			if (tilenum == numberoftiles(tilesetname)) {
 			  Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(tilenum) + " is not a valid tile.)");
				return;
			}else{
				Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
				return;
			}
		}
		
		Gfx.endquadbatch();
		
		x = tilealignx(x); y = tilealigny(y);
		
		internaldrawimage(x, y, tiles[currenttileset].tiles[tilenum]);
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
		
	public static function drawline(x1:Float, y1:Float, x2:Float, y2:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		updatequadbatch();
		
		templine = new Line(x1, y1, x2, y2, linethickness, color);
		templine.alpha = alpha;
		
		quadbatch.addQuad(templine);
	}

	public static function drawhexagon(x:Float, y:Float, radius:Float, angle:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		Gfx.endquadbatch();
		
		var tempring:Ring = new Ring(radius - linethickness, radius, color, true, 6, angle);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		drawto.draw(tempring, shapematrix);
	}
	
	public static function fillhexagon(x:Float, y:Float, radius:Float, angle:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		Gfx.endquadbatch();
		
		var tempring:Disk = new Disk(radius, color, true, 6, angle);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		drawto.draw(tempring, shapematrix);
	}
	
	public static function drawcircle(x:Float, y:Float, radius:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		Gfx.endquadbatch();
		
		var tempring:Ring = new Ring(radius - linethickness, radius, color);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		drawto.draw(tempring, shapematrix);
	}
	
	public static function fillcircle(x:Float, y:Float, radius:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT || drawto == null) return;
		Gfx.endquadbatch();
		
		var tempring:Disk = new Disk(radius, col);
		tempring.alpha = alpha;
		
		shapematrix.identity();
		shapematrix.translate(x - radius, y - radius);
		
		drawto.draw(tempring, shapematrix);
	}
	
	public static function drawtri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		
		drawline(x1, y1, x2, y2, color, alpha);
		drawline(x1, y1, x3, y3, color, alpha);
		drawline(x2, y2, x3, y3, color, alpha);
	}
	
	public static function filltri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		Gfx.endquadbatch();
		
		temppoly4 = new Poly4(x1, y1, x2, y2, x3, y3, x3, y3, color);
		temppoly4.alpha = alpha;
		drawto.draw(temppoly4);
	}

	public static function drawbox(x:Float, y:Float, width:Float, height:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		
		if (width < 0) {
			width = -width;
			x = x - width;
		}
		if (height < 0) {
			height = -height;
			y = y - height;
		}
		
		fillbox(x, y, width, 1, color, alpha);
		fillbox(x, y + height - 1, width - 1, 1, color, alpha);
		fillbox(x, y + 1, 1, height - 1, color, alpha);
		fillbox(x + width - 1, y + 1, 1, height - 1, color, alpha);
	}
	
	public static function fillbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		updatequadbatch();
		
		tempquad.x = x;
		tempquad.y = y;
		tempquad.width = width;
		tempquad.height = height;
		tempquad.color = col;
		tempquad.alpha = alpha;
		
		quadbatch.addQuad(tempquad);
	}
	
	private inline static function updatequadbatch() {
		quadbatchcount++;
	  if (quadbatchcount >= MAX_NUM_QUADS) endquadbatch();	
	}
	
	private static function endquadbatch() {
		drawto.draw(quadbatch);
		
		quadbatch.reset();
		quadbatchcount = 0;
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
	
	public static var clearcolor:Int = 0x000000;
	
	public static function clearscreen(color:Int = 0x000000) {
		if (color == Col.TRANSPARENT && drawto != null) return;
		Gfx.endquadbatch();
		
		drawto.clear(color, 1.0);
	}
	
	public static function setpixel(x:Float, y:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT && drawto != null) return;
		
		fillbox(x, y, 1, 1, color, alpha);
	}
	
	private static function updategraphicsmode(windowwidth:Int, windowheight:Int) {
		if (!_fullscreen) {
			if (flashstage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE || 
			    flashstage.displayState==StageDisplayState.FULL_SCREEN){
				flashstage.displayState=StageDisplayState.NORMAL;
			}
		}else {
			if (flashstage.displayState == StageDisplayState.NORMAL) {
			  try {
					flashstage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;	
				}catch (e:Dynamic) {
					#if flash
					if (e.name == "SecurityError") {
						if (flashstage.loaderInfo.url.indexOf("file://") == 0) {
						}else {
							Debug.log("Error: Haxegon is unable to toggle fullscreen in browsers due to Adobe security settings. To do: make haxegon_flash addon!");
						}
					}
					#end
				}
			}
		}
		
		if (windowwidth == 0 && windowheight == 0) {
			//if returning to windowed mode from fullscreen, don't mess with the
			//viewport now; leave it to the onresize event to catch
			return;
		}
		
		starstage.stageWidth = screenwidth;
    starstage.stageHeight = screenheight;
		
		// set rectangle dimensions for viewPort:
		var stretchscalex:Float;
		var stretchscaley:Float;
		var stretchscalex:Float = Std.int(windowwidth) / screenwidth;
		var stretchscaley:Float = Std.int(windowheight) / screenheight;
		var stretchscale:Float = Math.min(stretchscalex, stretchscaley);
		
		var viewPortRectangle:Rectangle = new Rectangle();
		viewPortRectangle.width = screenwidth * stretchscale; 
		viewPortRectangle.height = screenheight * stretchscale;
		
		viewPortRectangle.x = Std.int((windowwidth - Std.int(screenwidth * stretchscale)) / 2);
		viewPortRectangle.y = Std.int((windowheight - Std.int(screenheight * stretchscale)) / 2);
		// resize the viewport:
		Starling.current.viewPort = viewPortRectangle;
	}
	
	private static function getscreenx(_x:Float) : Int {
		return Math.floor((_x - Starling.current.viewPort.x) * screenwidth / Starling.current.viewPort.width);
	}

	private static function getscreeny(_y:Float) : Int {
		return Math.floor((_y - Starling.current.viewPort.y) * screenheight / Starling.current.viewPort.height);
	}
	
	/** Create a screen with a given width, height and scale. Also inits Text. */
	public static function resizescreen(width:Float, height:Float) {
		initgfx(Std.int(width), Std.int(height));
		Text.init(starstage);
		updategraphicsmode(starstage.stageWidth, starstage.stageHeight);
	}
	
	public static var fullscreen(get,set):Bool;
	private static var _fullscreen:Bool;

	static function get_fullscreen():Bool {
		return _fullscreen;
	}

  static function set_fullscreen(fs:Bool) {
		#if html5
		_fullscreen = fs;
		if(fs) Debug.log("Warning: HTML5 target does not currently support fullscreen. Check again in a later version!");
		return fs;
		#else
		_fullscreen = fs;
		if (!gfxinit) return fs;
		
		if (_fullscreen) {
			updategraphicsmode(devicexres, deviceyres);
		}else {
			updategraphicsmode(0, 0);
		}
		
		return _fullscreen;
		#end
	}
	
	/** Gives Gfx access to the stage, and preloads packed textures. */
	private static function init(_starlingstage:starling.display.Stage, _flashstage:openfl.display.Stage) {
		starstage = _starlingstage;
		flashstage = _flashstage;
		
		starstage.addEventListener(ResizeEvent.RESIZE, onresize);
		
		linethickness = 1;
		loadpackedtextures();
		
		reset();
	}
	
	private static function onresize(e:ResizeEvent) {
		updategraphicsmode(e.width, e.height);
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
	private static function initgfx(width:Int, height:Int) {
		//We initialise a few things
		screenwidth = width; screenheight = height;
		screenwidthmid = Std.int(screenwidth / 2); screenheightmid = Std.int(screenheight / 2);
		
		devicexres = Std.int(openfl.system.Capabilities.screenResolutionX);
		deviceyres = Std.int(openfl.system.Capabilities.screenResolutionY);
		
		quadbatch = new QuadBatch();
		starstage.touchable = false;
		//temppoly4 = new Poly4();
		
		if(!gfxinit){
			backbuffer = new RenderTexture(width, height, true);
			drawto = backbuffer;
			screen = new Image(backbuffer);
			screen.touchable = false;
			screen.scale = 1;
			screen.smoothing = "none";
			starstage.addChild(screen);
			
			if (Core.showstats) {
			  Core.statsdisplay = new StatsDisplay();
				starstage.addChild(Core.statsdisplay);
			}else {
				if(Core.statsdisplay != null) starstage.removeChild(Core.statsdisplay);
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
	
	private static function startframe() {
		drawto.bundlelock();	
		
		if (clearcolor != Col.TRANSPARENT) clearscreen(clearcolor);
		quadbatch.reset();
		quadbatchcount = 0;
	}
	
	private static function endframe() {
		endquadbatch();
		drawto.bundleunlock();
	}
	
	private static var quadbatchcount:Int = 0;
	private static var quadbatch:QuadBatch = null;
	
	private static var backbuffer:RenderTexture;
	private static var drawto:RenderTexture;
	private static var screen:Image;
	private static var tempquad:Quad = new Quad(1, 1);
	private static var temppoly4:Poly4;
	private static var templine:Line;
	
	private static var starlingassets:AssetManager;
	private static var trect:Rectangle = new Rectangle();
	private static var shapematrix:Matrix = new Matrix();
	
	private static var starstage:starling.display.Stage;
	private static var flashstage:openfl.display.Stage;
	
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
	
	private static var tiles:Array<HaxegonTileset> = new Array<HaxegonTileset>();
	private static var tilesetindex:Map<String, Int> = new Map<String, Int>();
	private static var currenttileset:Int = -1;
	
	private static var gfxinit:Bool = false;
}