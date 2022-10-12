package haxegon;

import haxegon.starlingmods.*;
import flash.display.StageDisplayState;
import flash.display.BitmapData;
import haxe.Constraints.Function;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import starling.display.*;
import starling.utils.AssetManager;
import starling.textures.*;
import openfl.Assets;
import openfl.utils.AssetType;
import starling.events.ResizeEvent;
import starling.core.Starling;

class HaxegonImage {
	public function new(n:String) {
		name = n;
	}
	
	public function fetchsize() {
	  width = Std.int(contents.width);
		height = Std.int(contents.height);
	}
	
	public function dispose(){
		if(contents != null){
			contents.dispose();
			contents = null;
		}
	}
	
	public function toString():String{
		return name + " [" + width + "x" + height + "]";
	}
	
	public var contents:Image;
	public var name:String;
	public var width:Int;
	public var height:Int;
}

class HaxegonTileset {
	public function new(n:String, w:Int, h:Int) {
		name = n;
		width = w;
		height = h;
		
		tiles = [];
		
		sharedatlas = true;
	}
	
	public var tiles:Array<Image>;
	public var name:String;
	public var width:Int;
	public var height:Int;
	
	public var sharedatlas:Bool;
}

@:access(haxegon.Core)
@:access(haxegon.Data)
@:access(haxegon.Text)
class Gfx {
	private static inline var MAX_NUM_MESH:Int = 16383;
	public static var LEFT:Int = 0;
	public static var TOP:Int = 0;
	public static var CENTER:Int = -200000;
	public static var RIGHT:Int = -300000;
	public static var BOTTOM:Int = -300000;
	
	public static var screenwidth:Int;
	public static var screenheight:Int;
	public static var screenwidthmid:Int;
	public static var screenheightmid:Int;
	
	private static var devicexres:Int;
	private static var deviceyres:Int;
	
	private static var currenttilesetname:String;
	
	//** Clear all rotations, scales and image colour changes */
	public static function reset() {
		transform = false;
		imagerotate = 0; 
		imagerotatexpivot = 0; imagerotateypivot = 0;
		imagexscale = 1.0; imageyscale = 1.0;
		imagescalexpivot = 0; imagescaleypivot = 0;
		imagextranslate = 0; imageytranslate = 0;
		
		coltransform = false;
		imagealphamult = 1.0;	imagecolormult = 0xFFFFFF;
	}
	
	/** Called when a transform takes place to check if any transforms are active */
	private static function reset_ifclear() {
		if (imagerotate == 0) {
		  if (imagexscale == 1.0) {
				if (imageyscale == 1.0) {
					if (imagextranslate == 0) {
						if (imageytranslate == 0) {
							transform = false;
						}
					}
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
	public static function rotation(angle:Float, xpivot:Float = 0, ypivot:Float = 0) {
		imagerotate = angle;
		imagerotatexpivot = xpivot;
		imagerotateypivot = ypivot;
		transform = true;
		reset_ifclear();
	}
	
	/** Scales image drawing functions. Optionally takes a second argument 
	 * to scale X and Y seperately. */
	public static function scale(?xscale:Float, ?yscale:Float, ?xpivot:Float = 0, ?ypivot:Float = 0) {
		if (xscale == null && yscale == null) {
		  xscale = 1.0; yscale = 1.0;
		}
		if (yscale == null && xscale != null) yscale = xscale;
		imagexscale = xscale;
		imageyscale = yscale;
		imagescalexpivot = xpivot;
		imagescaleypivot = ypivot;
		
		transform = true;
		reset_ifclear();
	}

	/** Translates image drawing functions. */
	public static function translate(xtranslate:Float, ?ytranslate:Float = 0) {
		imagextranslate = xtranslate;
		imageytranslate = ytranslate;

		transform = true;
		reset_ifclear();
	}

	/** Set an alpha multipler for image drawing functions. */
	public static var imagealpha(get, set):Float;
	public static function resetalpha(){ imagealpha = 1.0; }

	static function set_imagealpha(_alpha:Float) {
		imagealphamult = _alpha;
		coltransform = true;
		reset_ifclear();
		
		return imagealphamult;
	}
	
	static function get_imagealpha():Float {
		return imagealphamult;
	}
	
	/** Set a colour multipler and offset for image drawing functions. */
	public static var imagecolor(get, set):Int;
	public static function resetcolor(){ imagecolor = 0xFFFFFF; }
	
	static function set_imagecolor(_color:Int) {
		imagecolormult = _color;
		
		coltransform = true;
		reset_ifclear();
		
		return imagecolormult;
	}
	
	static function get_imagecolor():Int {
		return imagecolormult;
	}
	
	public static function numberoftiles(tileset:String):Int {
		changetileset(tileset);
		return tiles[currenttileset].tiles.length;
	}
	
	/* Internal function for changing tile index to correct values for tileset */
	private static function changetileset(tilesetname:String):Bool {
		if (currenttilesetname != tilesetname) {
			if(tilesetindex.exists(tilesetname)){
				currenttileset = tilesetindex.get(tilesetname);
				currenttilesetname = tilesetname;
			}else {
 				Debug.log("ERROR: Cannot change to tileset \"" + tilesetname + "\", no tileset with that name found.");
				return false;
			}
		}
		return true;
	}
		
	/** Makes a tile array from a given image. */
	public static function loadtiles(imagename:String, width:Int, height:Int) {	
		imagename = imagename.toLowerCase();
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
		
		var spritesheet:Texture = starlingassets.getTexture(imagename);
		
		tiles.push(new HaxegonTileset(imagename, width, height));
		tilesetindex.set(imagename, tiles.length - 1);
		currenttileset = tiles.length - 1;
		currenttilesetname = imagename;
		
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
				tiles[currenttileset].tiles[tiles[currenttileset].tiles.length - 1].textureSmoothing = Core.texturesmoothing;
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
		
		tiles[tileset].sharedatlas = false;
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
			
			tiles[currenttileset].sharedatlas = false;
			changetileset(tilesetname);
		}else {
			changetileset(tilesetname);
			tiles[currenttileset].sharedatlas = false;
			
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
				if (i < tiles[currenttileset].tiles.length && !purge && #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(tiles[currenttileset].tiles[i].texture, RenderTexture)) {
					cast(tiles[currenttileset].tiles[i].texture, HaxegonRenderTexture).clear();
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
		haxegonimage = new HaxegonImage(imagename);
		haxegonimage.contents = new Image(tex);
		haxegonimage.fetchsize();
		images.push(haxegonimage);
		images[images.length - 1].contents.textureSmoothing = Core.texturesmoothing;
	}		
	
	/** Loads an image into the game. */
	public static function loadimage(imagename:String):Bool {
		imagename = imagename.toLowerCase();
		if (imageindex.exists(imagename)) return true; //This is already loaded, so we're done!
		
		var tex:Texture;
		if(Data.assetexists("data/graphics/" + imagename + ".png")){
		  tex = Texture.fromBitmapData(Data.getgraphicsasset("data/graphics/" + imagename + ".png"), false);
		}else if (Data.assetexists("data/graphics/" + imagename + ".jpg")) {
			tex = Texture.fromBitmapData(Data.getgraphicsasset("data/graphics/" + imagename + ".jpg"), false);
		}else if(Data.assetexists(imagename + ".png")){
		  tex = Texture.fromBitmapData(Data.getgraphicsasset(imagename + ".png"), false);
		}else if(Data.assetexists(imagename + ".jpg")){
		  tex = Texture.fromBitmapData(Data.getgraphicsasset(imagename + ".jpg"), false);
		}else {
			Debug.log("ERROR: In loadimage, cannot find \"data/graphics/" + imagename + ".png\" or \"data/graphics/" + imagename + ".jpg\"");
			return false;
		}
		starlingassets.addTexture(imagename, tex);
		
		imageindex.set(imagename, images.length);
		haxegonimage = new HaxegonImage(imagename);
		haxegonimage.contents = new Image(starlingassets.getTexture(imagename));
		haxegonimage.contents.textureSmoothing = Core.texturesmoothing;
		haxegonimage.fetchsize();
		
		images.push(haxegonimage);
		return true;
	}
	
	/* Unload an image, freeing up its resources */ 
	public static function unloadimage(imagename:String):Bool{
		imagename = imagename.toLowerCase();
		if (!imageindex.exists(imagename)) return true; //This is already removed, so we're done!
		
		haxegonimage = images[imageindex.get(imagename)];
		haxegonimage.contents.texture.dispose();
		haxegonimage.dispose();
		
		images[imageindex.get(imagename)] = null;
		
		starlingassets.removeTexture(imagename, true);
		imageindex.remove(imagename);
		return true;
	}
	
	/** Creates a blank image, with the name "imagename", with given width and height. */
	public static function createimage(imagename:String, width:Float, height:Float) {
		var tex:Texture = Texture.fromBitmapData(new BitmapData(Math.floor(width), Math.floor(height), true, 0), false);
		var img:Image = new Image(tex);
		img.touchable = false;
		img.textureSmoothing = Core.texturesmoothing;

		var exindex:Null<Int> = imageindex.get(imagename);
		if (exindex == null) {
			imageindex.set(imagename, images.length);
			haxegonimage = new HaxegonImage(imagename);
			haxegonimage.contents = img;
			haxegonimage.fetchsize();
			
			images.push(haxegonimage);
		}else {
			images[exindex].contents.texture.dispose();
			images[exindex].contents.dispose();
			images[exindex].contents = img;
			images[exindex].fetchsize();
		}
	}
	
	/** Returns the width of the image. */
	public static function imagewidth(imagename:String):Int {
		if (!imageindex.exists(imagename)) {
			loadimage(imagename);
		}	
		
		var imagenum:Int = imageindex.get(imagename);
		return images[imagenum].width;
	}
	
	/** Returns the height of the image. */
	public static function imageheight(imagename:String):Int {
		if (!imageindex.exists(imagename)) {
			loadimage(imagename);
		}	
		
		var imagenum:Int = imageindex.get(imagename);
		return images[imagenum].height;
	}
	
	private static function promotetorendertarget(image:Image) {
		if (!#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(image.texture, HaxegonRenderTexture)) {
			var newtexture:HaxegonRenderTexture = new HaxegonRenderTexture(Std.int(image.texture.width), Std.int(image.texture.height));
			
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
		screenshotdirty = true;
		Gfx.endmeshbatch();
		if (drawto != null){
			if(drawtolocked) drawto.bundleunlock();
			drawtolocked = false;
		}
		
		drawto = backbuffer;
		
		if (drawto != null){
			if(!drawtolocked) drawto.bundlelock();
			drawtolocked = true;
		}
	}
	
	/** Tell draw commands to draw to the given image. */
	public static function drawtoimage(imagename:String) {
		screenshotdirty = true;
		if (!imageindex.exists(imagename)) {
			Debug.log("ERROR: In drawtoimage, cannot find image \"" + imagename + "\".");
			return;
		}
		
		Gfx.endmeshbatch();
		if (drawto != null){
			if(drawtolocked) drawto.bundleunlock();
			drawtolocked = false;
		}
		
		var imagenum:Int = imageindex.get(imagename);
		promotetorendertarget(images[imagenum].contents);
		drawto = cast(images[imagenum].contents.texture, HaxegonRenderTexture);
		
		if (drawto != null){
			if(!drawtolocked) drawto.bundlelock();
			drawtolocked = true;
		}
	}
	
	/** Tell draw commands to draw to the given tile in the current tileset. */
	public static function drawtotile(tilesetname:String, tilenum:Int) {
		screenshotdirty = true;
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
		
		endmeshbatch();
		if (drawto != null){
			if(drawtolocked) drawto.bundleunlock();
			drawtolocked = false;
		}
		
		promotetorendertarget(tiles[tileset].tiles[tilenum]);
		drawto = cast(tiles[tileset].tiles[tilenum].texture, HaxegonRenderTexture);
		
		if (drawto != null){
			if(!drawtolocked) drawto.bundlelock();
			drawtolocked = true;
		}
	}
	
	/** Helper function for image drawing functions. */
	private static var t1:Float;
	private static var t2:Float;
	private static var t3:Float;
	private static function imagealignx(imagewidth:Int, x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Gfx.screenwidthmid - Std.int(imagewidth / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + imagewidth;
			}
		}
		
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealigny(imageheight:Int, y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Gfx.screenheightmid - Std.int(imageheight / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + imageheight;
			}
		}
		
		return y;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagex(imagewidth:Int, x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Std.int(imagewidth / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + imagewidth;
			}
		}
		
		return x;
	}
	
	/** Helper function for image drawing functions. */
	private static function imagealignonimagey(imageheight:Int, y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Std.int(imageheight / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + imageheight;
			}
		}
		
		return y;
	}
	
	private static function internaldrawimage(x:Float, y:Float, image:Image, imagewidth:Int, imageheight:Int) {
		screenshotdirty = true;
		if (!transform && !coltransform) {
			shapematrix.identity();
			shapematrix.translate(Std.int(x), Std.int(y));
			addmeshtobatch(image, shapematrix, 1.0);
		}else {
			tempxalign = 0;	tempyalign = 0;
			
			shapematrix.identity();
			
			if (imagexscale != 1.0 || imageyscale != 1.0) {
				if (imagescalexpivot != 0.0) tempxalign = imagealignonimagex(imagewidth, imagescalexpivot);
				if (imagescaleypivot != 0.0) tempyalign = imagealignonimagey(imageheight, imagescaleypivot);
				shapematrix.translate( -tempxalign, -tempyalign);
				shapematrix.scale(imagexscale, imageyscale);
				shapematrix.translate( tempxalign, tempyalign);
			}
			
			if (imagerotate != 0) {
				if (imagerotatexpivot != 0.0) tempxalign = imagealignonimagex(imagewidth, imagerotatexpivot);
				if (imagerotateypivot != 0.0) tempyalign = imagealignonimagey(imageheight, imagerotateypivot);
				shapematrix.translate( -tempxalign * imagexscale, -tempyalign * imageyscale);
				shapematrix.rotate((imagerotate * 3.1415) / 180);
				shapematrix.translate( tempxalign * imagexscale, tempyalign * imageyscale);
			}

			if (imagextranslate != 0.0 || imageytranslate != 0.0) {
				shapematrix.translate(imagextranslate, imageytranslate);
			}
			
			shapematrix.translate(x, y);
			if (coltransform) {
				image.color = imagecolormult;
				addmeshtobatch(image, shapematrix, imagealphamult);
				image.color = Col.WHITE;
			}else {
				addmeshtobatch(image, shapematrix, 1.0);
			}
		} 
	}
	
	/** Draws image by name. 
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * */
	public static function drawimage(x:Float, y:Float, imagename:String) {
		if (!imageindex.exists(imagename)) {
			if (!loadimage(imagename)) return;
		}
		
		haxegonimage = images[imageindex.get(imagename)];
		x = imagealignx(haxegonimage.width, x); y = imagealigny(haxegonimage.height, y);
		internaldrawimage(x, y, haxegonimage.contents, haxegonimage.width, haxegonimage.height);
	}
	
	/** Draws image by name. 
	 * x and y are the point at which to render.
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * x1, y1, w1, h1 describe the rectangle of the image to use.
	 * */
	@:access(starling.display.Mesh.vertexData)
	public static function drawsubimage(x:Float, y:Float, x1:Int, y1:Int, w1:Int, h1:Int, imagename:String) {
		if (!imageindex.exists(imagename)) {
			Debug.log("ERROR: In drawsubimage, cannot find image \"" + imagename + "\".");
			return;
		}
		
		//
		haxegonimage = images[imageindex.get(imagename)];
		var w:Int = haxegonimage.width;
		var h:Int = haxegonimage.height;
		x = imagealignx(w1, x); y = imagealigny(h1, y);
		
		// Get original coords
		haxegonimage.contents.texture.getTexCoords(haxegonimage.contents.vertexData, 0, "texCoords", tpoint1);
		haxegonimage.contents.texture.getTexCoords(haxegonimage.contents.vertexData, 3, "texCoords", tpoint2);
		haxegonimage.contents.getVertexPosition(0, tpoint3);
		haxegonimage.contents.getVertexPosition(3, tpoint4);
		
		// Set coords
		var tu1:Float = tpoint1.x + (tpoint2.x - tpoint1.x) * (x1 / w);
		var tu2:Float = tpoint1.x + (tpoint2.x - tpoint1.x) * ((x1 + w1) / w);
		var tv1:Float = tpoint1.y + (tpoint2.y - tpoint1.y) * (y1 / h);
		var tv2:Float = tpoint1.y + (tpoint2.y - tpoint1.y) * ((y1 + h1) / h);

		haxegonimage.contents.texture.setTexCoords(haxegonimage.contents.vertexData, 0, "texCoords", tu1, tv1);
		haxegonimage.contents.texture.setTexCoords(haxegonimage.contents.vertexData, 1, "texCoords", tu2, tv1);
		haxegonimage.contents.texture.setTexCoords(haxegonimage.contents.vertexData, 2, "texCoords", tu1, tv2);
		haxegonimage.contents.texture.setTexCoords(haxegonimage.contents.vertexData, 3, "texCoords", tu2, tv2);

		haxegonimage.contents.setVertexPosition(0, 0, 0);
		haxegonimage.contents.setVertexPosition(1, w1, 0);
		haxegonimage.contents.setVertexPosition(2, 0, h1);
		haxegonimage.contents.setVertexPosition(3, w1, h1);
		
		internaldrawimage(x, y, haxegonimage.contents, w1, h1);

		// Restore coords
		haxegonimage.contents.texture.setTexCoords(haxegonimage.contents.vertexData, 0, "texCoords", tpoint1.x, tpoint1.y);
		haxegonimage.contents.texture.setTexCoords(haxegonimage.contents.vertexData, 1, "texCoords", tpoint2.x, tpoint1.y);
		haxegonimage.contents.texture.setTexCoords(haxegonimage.contents.vertexData, 2, "texCoords", tpoint1.x, tpoint2.y);
		haxegonimage.contents.texture.setTexCoords(haxegonimage.contents.vertexData, 3, "texCoords", tpoint2.x, tpoint2.y);

		haxegonimage.contents.setVertexPosition(0, tpoint3.x, tpoint3.y);
		haxegonimage.contents.setVertexPosition(1, tpoint4.x, tpoint3.y);
		haxegonimage.contents.setVertexPosition(2, tpoint3.x, tpoint4.y);
		haxegonimage.contents.setVertexPosition(3, tpoint4.x, tpoint4.y);
	}
	
	public static function grabtilefromscreen(tilesetname:String, tilenumber:Int, screenx:Float, screeny:Float) {
		changetileset(tilesetname);
		
		if (tilenumber >= numberoftiles(tilesetname)) {
			if (tilenumber == numberoftiles(tilesetname)) {
 			  Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenumber) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(tilenumber) + " is not a valid tile.)");
				return;
			}else{
				Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenumber) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
				return;
			}
		}
		
		//Make sure everything's on the screen before we grab it
		endmeshbatch();
		
		// Acquire SubTexture and build an Image from it.
		promotetorendertarget(tiles[currenttileset].tiles[tilenumber]);
		
		// Copy the old texture to the new RenderTexture
		shapematrix.identity();
		shapematrix.translate(-screenx, -screeny);
		
		cast(tiles[currenttileset].tiles[tilenumber].texture, HaxegonRenderTexture).draw(screen, shapematrix);
	}
	
	public static function grabtilefromimage(tilesetname:String, tilenumber:Int, imagename:String, imagex:Float, imagey:Float) {
		if (!imageindex.exists(imagename)) {
			throw("ERROR: In grabtilefromimage, \"" + imagename + "\" does not exist.");
			return;
		}
		
		changetileset(tilesetname);
		
		if (tilenumber >= numberoftiles(tilesetname)) {
			if (tilenumber == numberoftiles(tilesetname)) {
 			  Debug.log("ERROR: Tried to grab tile from image to tile number " + Std.string(tilenumber) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(tilenumber) + " is not a valid tile.)");
				return;
			}else{
				Debug.log("ERROR: Tried to grab tile from image to tile number " + Std.string(tilenumber) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
				return;
			}
		}
		
		//Make sure everything's on the screen before we grab it
		endmeshbatch();
		
		// Acquire SubTexture and build an Image from it.
		promotetorendertarget(tiles[currenttileset].tiles[tilenumber]);
		
		// Copy the old texture to the new RenderTexture
		shapematrix.identity();
		shapematrix.translate(-imagex, -imagey);
		
		cast(tiles[currenttileset].tiles[tilenumber].texture, HaxegonRenderTexture).draw(images[imageindex.get(imagename)].contents, shapematrix);
	}
	
	public static function grabimagefromscreen(imagename:String, screenx:Float, screeny:Float) {
		if (!imageindex.exists(imagename)) {
			Debug.log("ERROR: In Gfx.grabimagefromscreen, \"" + imagename + "\" does not exist. You need to create an image label first before using this function.");
			return;
		}
		
		//Make sure everything's on the screen before we grab it
		endmeshbatch();
		
		haxegonimage = images[imageindex.get(imagename)];
		// Acquire SubTexture and build an Image from it.
		promotetorendertarget(haxegonimage.contents);
		
		// Copy the old texture to the new RenderTexture
		shapematrix.identity();
		shapematrix.translate(-screenx, -screeny);
		
		cast(haxegonimage.contents.texture, HaxegonRenderTexture).draw(screen, shapematrix);
	}
	
	public static function grabimagefromimage(destinationimage:String, sourceimage:String, sourceimagex:Float, sourceimagey:Float) {
		if (!imageindex.exists(destinationimage)) {
			Debug.log("ERROR: In grabimagefromimage, \"" + destinationimage + "\" does not exist. You need to create an image label first before using this function.");
			return;
		}
		
		if (!imageindex.exists(sourceimage)) {
			Debug.log("ERROR: No image called \"" + sourceimage + "\" found.");
			return;
		}
		
		//Make sure everything's on the screen before we grab it
		endmeshbatch();
		
		haxegonimage = images[imageindex.get(destinationimage)];
		var sourceimage:HaxegonImage = images[imageindex.get(sourceimage)];
		
		// Make sure the destination image is a render target
		promotetorendertarget(haxegonimage.contents);
		
		// Copy the old texture to the new RenderTexture
		shapematrix.identity();
		shapematrix.translate(-sourceimagex, -sourceimagey);
		
		cast(haxegonimage.contents.texture, HaxegonRenderTexture).draw(sourceimage.contents, shapematrix);
	}
	
	public static function copytile(totileset:String, totilenumber:Int, fromtileset:String, fromtilenumber:Int) {
		if (tilesetindex.exists(fromtileset)) {
			if (tiles[currenttileset].width == tiles[tilesetindex.get(fromtileset)].width && tiles[currenttileset].height == tiles[tilesetindex.get(fromtileset)].height) {
				promotetorendertarget(tiles[tilesetindex.get(totileset)].tiles[totilenumber]);
				
				shapematrix.identity();
				cast(tiles[tilesetindex.get(totileset)].tiles[totilenumber].texture, HaxegonRenderTexture).draw(tiles[tilesetindex.get(fromtileset)].tiles[fromtilenumber], shapematrix);
			}else {
				Debug.log("ERROR: Tilesets " + totileset + " (" + Std.string(tilewidth(totileset)) + "x" + Std.string(tileheight(totileset)) + ") and " + fromtileset + " (" + Std.string(tiles[tilesetindex.get(fromtileset)].width) + "x" + Std.string(tiles[tilesetindex.get(fromtileset)].height) + ") are different sizes. Maybe try just drawing to the tile you want instead with Gfx.drawtotile()?");
				return;
			}
		}else {
			Debug.log("ERROR: Tileset " + fromtileset + " hasn't been loaded or created.");
			return;
		}
	}
	
	/** Draws tile number t from current tileset.
	 * x and y can be: Gfx.CENTER, Gfx.TOP, Gfx.BOTTOM, Gfx.LEFT, Gfx.RIGHT. 
	 * x1, y1, w1, h1 describe the rectangle of the tile to use.
	 * */
	public static function drawsubtile(x:Float, y:Float, tilesetname:String, tilenum:Int, x1:Float, y1:Float, w:Float, h:Float) {
		screenshotdirty = true;
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
		
		internaldrawimage(x, y, subimage, Std.int(subimage.width), Std.int(subimage.height));
		
		// all done! clean up
		subtex.dispose();
		subimage.dispose();		
	}
	
	public static function drawtile(x:Float, y:Float, tilesetname:String, tilenum:Int) {
		screenshotdirty = true;
		if (!changetileset(tilesetname)) return;
		
		if (tilenum < 0){
			Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", which is out of bounds.)");
			return;
		}else	if (tilenum >= numberoftiles(tilesetname)) {
			if (tilenum == numberoftiles(tilesetname)) {
 			  Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\". (Because this includes tile number 0, " + Std.string(tilenum) + " is not a valid tile.)");
				return;
			}else{
				Debug.log("ERROR: Tried to draw tile number " + Std.string(tilenum) + ", but there are only " + Std.string(numberoftiles(tilesetname)) + " tiles in tileset \"" + tiles[currenttileset].name + "\".");
				return;
			}
		}
		
		x = tilealignx(x); y = tilealigny(y);
		
		internaldrawimage(x, y, tiles[currenttileset].tiles[tilenum], tiles[currenttileset].width, tiles[currenttileset].height);
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
		screenshotdirty = true;
		
		templine.thickness = _linethickness;
		templine.setPosition(x1, y1, x2, y2);
		templine.color = color;
		templine.alpha = alpha;
		
		addmeshtobatch(templine, null, alpha);
	}
	
	public static function drawhexagon(x:Float, y:Float, radius:Float, angle:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		if (radius <= 0) return;
		screenshotdirty = true;
		if (!Geom.inbox(x, y, -radius, -radius, screenwidth + (radius * 2), screenheight + (radius * 2))) return;
		
		var tempring:Ring = new Ring(x - radius, y - radius, radius - linethickness, radius, color, alpha, 6, angle);
		
		for (i in 0 ... tempring._polygons.length){
			addmeshtobatch(tempring._polygons[i], null, alpha);
		}
	}
	
	public static function fillhexagon(x:Float, y:Float, radius:Float, angle:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		if (radius <= 0) return;
		screenshotdirty = true;
		if (!Geom.inbox(x, y, -radius, -radius, screenwidth + (radius * 2), screenheight + (radius * 2))) return;
		
		var tempring:Disk = new Disk(x - radius, y - radius, radius, color, alpha, 6, angle);
		
		for (i in 0 ... tempring._polygons.length){
			addmeshtobatch(tempring._polygons[i], null, alpha);
		}
	}
	
	public static function drawcircle(x:Float, y:Float, radius:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		if (radius <= 0) return;
		screenshotdirty = true;
		if (!Geom.inbox(x, y, -radius, -radius, screenwidth + (radius * 2), screenheight + (radius * 2))) return;
		
		var tempring:Ring = new Ring(x - radius, y - radius, radius - linethickness, radius, color, alpha);
		
		for (i in 0 ... tempring._polygons.length){
			addmeshtobatch(tempring._polygons[i], null, alpha);
		}
	}
	
	public static function fillcircle(x:Float, y:Float, radius:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT || drawto == null) return;
		if (radius <= 0) return;
		screenshotdirty = true;
		if (!Geom.inbox(x, y, -radius, -radius, screenwidth + (radius * 2), screenheight + (radius * 2))) return;
		
		var tempring:Disk = new Disk(x - radius, y - radius, radius, col, alpha);
		
		for(i in 0 ... tempring._polygons.length){
			addmeshtobatch(tempring._polygons[i], null, alpha);
		}
	}
	
	public static function drawellipse(x:Float, y:Float, xradius:Float, yradius:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT || drawto == null) return;
		if (xradius <= 0) return;
		if (yradius <= 0) return;
		screenshotdirty = true;
		if (!Geom.inbox(x, y, -xradius, -yradius, screenwidth + (xradius * 2), screenheight + (yradius * 2))) return;
		
		tempellipsering.setto(x - xradius, y - yradius, xradius - linethickness, yradius - linethickness, xradius, yradius, col, alpha);
		
		for(i in 0 ... tempellipsering._polygons.length){
			addmeshtobatch(tempellipsering._polygons[i], null, alpha);
		}
	}
	
	public static function fillellipse(x:Float, y:Float, xradius:Float, yradius:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT || drawto == null) return;
		if (xradius <= 0) return;
		if (yradius <= 0) return;
		screenshotdirty = true;
		if (!Geom.inbox(x, y, -xradius, -yradius, screenwidth + (xradius * 2), screenheight + (yradius * 2))) return;
		
		tempellipsedisk = new EllipseDisk(x - xradius, y - yradius, xradius, yradius, col, alpha);
		
		for(i in 0 ... tempellipsedisk._polygons.length){
			addmeshtobatch(tempellipsedisk._polygons[i], null, alpha);
		}
	}
	
	public static function drawtri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		
		drawline(x1, y1, x2, y2, color, alpha);
		drawline(x1, y1, x3, y3, color, alpha);
		drawline(x2, y2, x3, y3, color, alpha);
	}
	
	public static function filltri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, color:Int, alpha:Float = 1.0) {
		if (color == Col.TRANSPARENT || drawto == null) return;
		screenshotdirty = true;
		
		temppoly4.setVertexPositions(x1, y1, x2, y2, x3, y3, x3, y3);
		temppoly4.color = color;
		temppoly4.alpha = alpha;
		
		addmeshtobatch(temppoly4, null, alpha);
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
		
		fillbox(x, y, width, linethickness, color, alpha);
		fillbox(x + linethickness, y + height - linethickness, width - (linethickness * 2), linethickness, color, alpha);
		fillbox(x, y + linethickness, linethickness, height - linethickness, color, alpha);
		fillbox(x + width - linethickness, y + linethickness, linethickness, height - linethickness, color, alpha);
	}
	
	public static function fillbox(x:Float, y:Float, width:Float, height:Float, col:Int, alpha:Float = 1.0) {
		if (col == Col.TRANSPARENT) return;
		screenshotdirty = true;
		
		tempquad.x = x;
		tempquad.y = y;
		tempquad.width = width;
		tempquad.height = height;
		tempquad.color = col;
		tempquad.alpha = alpha;
		
		addmeshtobatch(tempquad, null, alpha);
	}
	
	private static function addmeshtobatch(mesh:Mesh, matrix:Matrix = null, alpha:Float = 1.0) {
		if (!meshbatch.canAddMesh(mesh)) {
			endmeshbatch();
		}
		meshbatch.addMesh(mesh, matrix, alpha);
		meshbatchcount++;
		if (meshbatchcount >= MAX_NUM_MESH) endmeshbatch();	
	}
	
	private static function endmeshbatch() {
		if (meshbatchcount > 0) {
			drawto.draw(meshbatch);
				
			meshbatch.clear();
			meshbatchcount = 0;
		}
	}
	
	private static function endmeshbatchonsurface(d:HaxegonRenderTexture) {
		if (meshbatchcount > 0) {
			d.draw(meshbatch);
			
			meshbatch.clear();
			meshbatchcount = 0;
		}
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
		if (drawto == null) return;
		endmeshbatch();
		if (drawto != null){
			if(drawtolocked) drawto.bundleunlock();
			drawtolocked = false;
		}
		
		if (color == Col.TRANSPARENT){
			drawto.clear(0, 0);
		}else {
			drawto.clear(color, 1.0);
		}
		
		if (drawto != null){
			if(!drawtolocked) drawto.bundlelock();
			drawtolocked = true;
		}
	}
	
	public static function setpixel(x:Float, y:Float, color:Int, alpha:Float = 1.0) {
		fillbox(x, y, 1, 1, color, alpha);
	}
	
	private static var screenshot:BitmapData;
	private static var screenshotdirty:Bool = true;
	public static function getpixel(x:Float, y:Float):Int {
		var resultpixel:Int = Col.TRANSPARENT;
		
		var xs:Float = Starling.current.viewPort.width / screenwidth;
		var ys:Float = Starling.current.viewPort.height / screenheight;
		
		if (!screenshotdirty){
			//If our current screenshot is still good, then this is a LOT simplier
			
			var pixelalpha:Int = screenshot.getPixel32(Std.int(x * xs), Std.int(y * ys)) >> 24 & 0xFF;
			var pixel:Int = screenshot.getPixel(Std.int(x * xs), Std.int(y * ys));
			
			if (pixelalpha == 0) {
				resultpixel = Col.TRANSPARENT;
			}else{
				resultpixel = pixel;
			}
		}else if (backbuffer == null){
			if(drawto != null){
				//Weird case: we haven't defined the backbuffer yet because we're trying to call
				//getpixel in Main.new().
				endmeshbatch();
				
				drawto.bundleunlock();
				
				var tempimage:Image = new Image(drawto);
				Starling.current.stage.addChildAt(tempimage, 0);
				
				if (screenshot != null) screenshot.dispose();
				screenshot = new BitmapData(screenwidth, screenheight);
				screenshot = Starling.current.stage.drawToBitmapData(screenshot);
				screenshotdirty = false;
				
				var pixelalpha:Int = screenshot.getPixel32(Std.int(x * xs), Std.int(y * ys)) >> 24 & 0xFF;
				var pixel:Int = screenshot.getPixel(Std.int(x * xs), Std.int(y * ys));
				
				if (pixelalpha == 0) {
					resultpixel = Col.TRANSPARENT;
				}else{
					resultpixel = pixel;
				}
				
				Starling.current.stage.removeChild(tempimage, false);
				tempimage.dispose();
				tempimage = null;
				
				drawto.bundlelock();
			}else{
				throw("Error: Sorry, Gfx.getpixel() can't be used on the screen in Main.new()!\n" +
							"If you want to do some drawing in Main.new(), instead try creating a\n" +
							"surface with Gfx.createimage(), and drawing to and grabbing from that.");
			}
		}else	if (drawto == backbuffer) {
			//Getting a pixel from the screen
			//First, we take a screenshot
			if (screenshotdirty){
				if (screenshot != null) screenshot.dispose();
				screenshot = new BitmapData(screenwidth, screenheight);
				screenshot = Starling.current.stage.drawToBitmapData(screenshot);
				screenshotdirty = false;
			}
			
			var pixelalpha:Int = screenshot.getPixel32(Std.int(x * xs), Std.int(y * ys)) >> 24 & 0xFF;
			var pixel:Int = screenshot.getPixel(Std.int(x * xs), Std.int(y * ys));
			
			if (pixelalpha == 0) {
				resultpixel = Col.TRANSPARENT;
			}else{
				resultpixel = pixel;
			}
		}else {
		  //We're getting a pixel from a rendertexture image. 
			//Ok, this is the awful worst case, but here's how we do it:
			//Starling doesn't support drawing an arbitrary texture to a bitmapdata. 
			//We can only do this with the screen. Therefore, we:
			// - Grab a screenshot
			// - Clear the screen, then draw our image to it
			// - Get the pixel
			// - Redraw the screenshot over the screen
			endmeshbatch();
			
			drawto.bundleunlock();
			var originalscreenshot:BitmapData = new BitmapData(screenwidth, screenheight);
			originalscreenshot = Starling.current.stage.drawToBitmapData(originalscreenshot);
			
			//Now, we clear the screen
			backbuffer.bundlelock();
			backbuffer.clear();
			
			//And we draw our image to this
			backbuffer.draw(new Image(drawto));
			backbuffer.bundleunlock();
			
			if (screenshot != null) screenshot.dispose();
			screenshot = new BitmapData(screenwidth, screenheight);
			screenshot = Starling.current.stage.drawToBitmapData(screenshot);
			screenshotdirty = false;
			
			var pixelalpha:Int = screenshot.getPixel32(Std.int(x * xs), Std.int(y * ys)) >> 24 & 0xFF;
			var pixel:Int = screenshot.getPixel(Std.int(x * xs), Std.int(y * ys));
			
			if (pixelalpha == 0) {
				resultpixel = Col.TRANSPARENT;
			}else{
				resultpixel = pixel;
			}
			
			//Now we redraw the screen
			backbuffer.draw(new Image(Texture.fromBitmapData(originalscreenshot)));
			originalscreenshot.dispose();
		}
		return resultpixel;
	}
	
	private static function updategraphicsmode(windowwidth:Int, windowheight:Int) {
		if (windowwidth == 0 && windowheight == 0) {
			//if returning to windowed mode from fullscreen, don't mess with the
			//viewport now; leave it to the 3 event to catch
			return;
		}
		
		starstage.stageWidth = screenwidth;
    starstage.stageHeight = screenheight;
		
		// set rectangle dimensions for viewPort:
		var stretchscalex:Float = Std.int(windowwidth) / screenwidth;
		var stretchscaley:Float = Std.int(windowheight) / screenheight;
		var stretchscale:Float = Math.min(stretchscalex, stretchscaley);
		if (_keeppixelratio)	stretchscale = Math.floor(stretchscale);
		
		var viewPortRectangle:Rectangle = new Rectangle();
		
		if (perfectfit == 1){
			viewPortRectangle.width = Std.int(windowwidth); 
			viewPortRectangle.height = Std.int(windowheight);
			
			viewPortRectangle.x = Std.int((windowwidth - Std.int(screenwidth * stretchscaley)) / 2);
			viewPortRectangle.y = Std.int((windowheight - Std.int(screenheight * stretchscaley)) / 2);
		}else if (perfectfit == 2){
			viewPortRectangle.width = Std.int(windowwidth); 
			viewPortRectangle.height = Std.int(windowheight);
			
			viewPortRectangle.x = Std.int((windowwidth - Std.int(screenwidth * stretchscalex)) / 2);
			viewPortRectangle.y = Std.int((windowheight - Std.int(screenheight * stretchscalex)) / 2);
		}else{
			viewPortRectangle.width = screenwidth * stretchscale; 
			viewPortRectangle.height = screenheight * stretchscale;
			
			viewPortRectangle.x = Std.int((windowwidth - Std.int(screenwidth * stretchscale)) / 2);
			viewPortRectangle.y = Std.int((windowheight - Std.int(screenheight * stretchscale)) / 2);
		}
		
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
	public static function resizescreen(width:Float, height:Float, keeppixelratio:Bool = false) {
		_keeppixelratio = keeppixelratio;
		if (width <= 0 && height <= 0){
			width = Std.int(flash.Lib.current.stage.stageWidth);
			height = Std.int(flash.Lib.current.stage.stageHeight);
			perfectfit = 3;
			dynamicwidth = 0;
			dynamicheight = 0;
		}else if (width <= 0){
			perfectfit = 1;
			width = Std.int(flash.Lib.current.stage.stageWidth * (height / flash.Lib.current.stage.stageHeight));
			dynamicwidth = 0;
			dynamicheight = Std.int(height);
		}else if (height <= 0){
			perfectfit = 2;
			height = Std.int(flash.Lib.current.stage.stageHeight * (width / flash.Lib.current.stage.stageWidth));
			dynamicwidth = Std.int(width);
			dynamicheight = 0;
		}else{
			perfectfit = 0;
			dynamicwidth = 0;
			dynamicheight = 0;
		}
		initgfx(Std.int(width), Std.int(height));
		Text.setstage(starstage);
		if (perfectfit == 1 || perfectfit == 2){
			updategraphicsmode(Std.int(flash.Lib.current.stage.stageWidth), Std.int(flash.Lib.current.stage.stageHeight));
		}else if (perfectfit == 3){
			updategraphicsmode(Std.int(width), Std.int(height));
		}else{
			updategraphicsmode(Std.int(Starling.current.stage.stageWidth), Std.int(Starling.current.stage.stageHeight));
		}
	}
	
	public static var fullscreen(get,set):Bool;
	private static var _fullscreen:Bool;

	static function get_fullscreen():Bool {
		return _fullscreen;
	}
	
  static function set_fullscreen(fs:Bool) {
		#if html5
		_fullscreen = fs;
		if(fs) Debug.log("Error: HTML5 target cannot set fullscreen this way. See Core.fullscreenbutton() for an alternative.");
		return fs;
		#else
		_fullscreen = fs;
		if (!gfxinit) return fs;
		
		if (_fullscreen) {
			if (flashstage.displayState == StageDisplayState.NORMAL) {
			  try {
					flashstage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;	
				}catch (e:Dynamic) {
					#if flash
					if (e.name == "SecurityError") {
						if (flashstage.loaderInfo.url.indexOf("file://") == 0) {
						}else {
							Debug.log("Error: Haxegon is unable to toggle fullscreen in browsers due to Adobe security settings. See Core.fullscreenbutton() for an alternative.");
						}
					}
					#end
				}
			}
			
			updategraphicsmode(devicexres, deviceyres);
		}else {
			if (flashstage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE || 
			    flashstage.displayState==StageDisplayState.FULL_SCREEN){
				flashstage.displayState=StageDisplayState.NORMAL;
			}
		}
		
		return _fullscreen;
		#end
	}
	
	/** Gives Gfx access to the stage, and preloads packed textures. */
	private static function init(_starlingstage:starling.display.Stage, _flashstage:openfl.display.Stage) {
		starstage = _starlingstage;
		flashstage = _flashstage;
		
		starstage.addEventListener(ResizeEvent.RESIZE, onresize);
		#if html5
		onresize(null);
		#end
		
		meshbatch = new MeshBatch();
		
		linethickness = 1;
		loadpackedtextures();
		
		reset();
	}
	
	private static function onresize(e:ResizeEvent) {
		_onwindowresized = true;
		if(customresize == null){
			if (perfectfit == 1){
				resizescreen(0, dynamicheight);
			}else if (perfectfit == 2){
				resizescreen(dynamicwidth, 0);
			}else if (perfectfit == 3){
				resizescreen(0, 0);
			}else{
				if (e != null){
					updategraphicsmode(e.width, e.height);
				}
			}
		}else{
			customresize();
		}
	}
	
	public static function onwindowresized():Bool{
		if (_onwindowresized){
			_onwindowresized = false;
			return true;
		}
		return false;
	}
	
	private static var _onwindowresized:Bool = false;
	
	private static function loadpackedtextures() {
		if(!gfxinit){
			starlingassets = new AssetManager();
			starlingassets.verbose = false;
			
			var exclusions:Array<String> = [];
			//Check for packed texture exclusion list
			if(Assets.exists("data/text/_pack_exclude.txt")) {
				exclusions = Data.loadtext("_pack_exclude");
			}

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
							var iname = i.get("name");
							if(exclusions.indexOf(iname) == -1) {
								//Include all image nodes that aren't explicitly excluded
								loadimagefrompackedtexture(iname, getassetpackedtexture(iname));
							}
						}
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
		
		var resizebuffers:Bool = gfxinit && (backbuffer.width != width || backbuffer.height != height);

		if (resizebuffers) {
			backbuffer.dispose();
			screen.dispose();
		}
		
		if (!gfxinit || resizebuffers){
			backbuffer = new HaxegonRenderTexture(width, height, true);
			drawto = backbuffer;
			screen = new Image(backbuffer);
			screen.touchable = false;
			screen.scale = 1;
			screen.textureSmoothing = Core.texturesmoothing;
			starstage.addChildAt(screen, 0);
			
			tempquad = new Quad(1, 1);
			temppoly4 = new Poly4(0, 0, 1, 0, 1, 1, 0, 1);
			templine = new Line(1, 1, 2, 2, 1, 0xFFFFFF);
			tempellipsering = new EllipseRing(0, 0, 1, 1, 2, 2, 0xFFFFFF, 1);
			tempellipsedisk = new EllipseDisk(0, 0, 1, 1, 0xFFFFFF, 1);
			
			drawto.bundlelock();
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
		if (drawto != null){
			if(!drawtolocked) drawto.bundlelock();
			drawtolocked = true;
		}
		
		meshbatch.clear();
		meshbatchcount = 0;
		if (clearcolor != Col.TRANSPARENT) clearscreen(clearcolor);
		
		if (!screenshotdirty){
			if (screenshot != null) screenshot.dispose();
			screenshotdirty = true;
		}
		
		Text.resettextfields();
	}
	
	private static function endframe() {
		endmeshbatch();
		if (drawto != null){
			if(drawtolocked) drawto.bundleunlock();
			drawtolocked = false;
		}
		
		if(screen != null) screen.setRequiresRedraw();
	}
	
	private static var meshbatchcount:Int = 0;
	private static var meshbatch:MeshBatch = null;
	
	private static var backbuffer:HaxegonRenderTexture;
	private static var drawto:HaxegonRenderTexture;
	private static var screen:Image;
	private static var tempquad:Quad;
	private static var temppoly4:Poly4;
	private static var templine:Line;
	private static var tempellipsering:EllipseRing;
	private static var tempellipsedisk:EllipseDisk;
	
	
	private static var starlingassets:AssetManager;
	private static var trect:Rectangle = new Rectangle();
	private static var tpoint1:Point = new Point();
	private static var tpoint2:Point = new Point();
	private static var tpoint3:Point = new Point();
	private static var tpoint4:Point = new Point();
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
	private static var imagextranslate:Float = 0;
	private static var imageytranslate:Float = 0;
	private static var imagealphamult:Float;
	private static var imagecolormult:Int;
	private static var tempxalign:Float;
	private static var tempyalign:Float;
	private static var temprotate:Float;
	private static var tx:Float;
	private static var ty:Float;
	private static var tx2:Float;
	private static var ty2:Float;
	private static var haxegonimage:HaxegonImage;
	
	private static var imageindex:Map<String, Int> = new Map<String, Int>();
	private static var images:Array<HaxegonImage> = new Array<HaxegonImage>();
	
	private static var tiles:Array<HaxegonTileset> = new Array<HaxegonTileset>();
	private static var tilesetindex:Map<String, Int> = new Map<String, Int>();
	private static var currenttileset:Int = -1;
	
	private static var gfxinit:Bool = false;
	private static var perfectfit:Int = 0;
	private static var dynamicwidth:Int = 0;
	private static var dynamicheight:Int = 0;
	private static var _keeppixelratio:Bool = false;
	
	public static var customresize:Function;
	
	private static var drawtolocked:Bool = false;
}
