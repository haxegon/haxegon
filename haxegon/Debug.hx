package haxegon;

import haxegon.Gfx.HaxegonImage;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import openfl.text.*;
import openfl.Assets;
import openfl.Lib;
import openfl.system.Capabilities;
import starling.textures.*;
import starling.display.*;

@:access(haxegon.Gfx)
class Debug {
	/** Clear the debug buffer */
	public static function clear() {
		history = [];
		posinfo = [];
	}
	
	public static function log(t:Dynamic, ?pos:haxe.PosInfos) {
		#if html5
		js.Browser.window.console.log(pos.fileName + ":" + pos.lineNumber + ": " + t);
		#elseif flash
		flash.Lib.trace(pos.fileName + ":" + pos.lineNumber + ": " + t);
		#elseif (neko || cpp)
		Sys.println(pos.fileName + ":" + pos.lineNumber + ": " + t);
		#else
		trace(pos.fileName + ":" + pos.lineNumber + ": " + t)
		#end
		posinfo.push(pos);
		history.push(Convert.tostring(t));
		showlogwindow = true;
	}
	
	/* Returns true if the debug log is capturing mouse input right now */
	private static function update():Bool {
		if (showlogwindow) {
			var capturinginput:Bool = false;
			if (Geom.inbox(Mouse.x, Mouse.y, gui.x - 1, gui.y - 1, gui.width + 2, gui.height + 2) || gui.windowdrag) {
				capturinginput = true;
				
				//if we're currently dragging, move the window
				if (!gui.windowdrag) {
					//otherwise start dragging from here
					if (Mouse.leftclick()) {
						if(Geom.inbox(Mouse.x, Mouse.y, gui.x, gui.y, gui.width, 20)){
							gui.windowdrag = true;
							gui.xdragoffset = Mouse.x - gui.x; gui.ydragoffset = Mouse.y - gui.y;
					  }
					}
				}
				
				if (gui.windowdrag) {
					//Drag anything else that's in this window
					gui.x = Mouse.x - gui.xdragoffset;
					gui.y = Mouse.y - gui.ydragoffset;
					if (gui.x < 0) gui.x = 0;
					if (gui.y < 0) gui.y = 0;
					
					if (gui.x > Gfx.screenwidth - gui.width) gui.x = Gfx.screenwidth - gui.width;
					if (gui.y > Gfx.screenheight - gui.height) gui.y = Gfx.screenheight - gui.height;
					
					if (!Mouse.leftheld()) gui.windowdrag = false;
				}
			}
			
			return capturinginput;
		}
		
		return false;
	}
	
	private static function drawwindow() {
		Gfx.fillbox(gui.x, gui.y, gui.width, gui.height, 0x272822, 0.75);
		Gfx.fillbox(gui.x, gui.y, gui.width, gui.scale * 10, 0xcacaca, 0.5);
		
		for (j in 0 ... (Math.floor(gui.height / (gui.scale * 10)) - 1)) {
			var i:Int = j + gui.scrollpos;
			if(i >= 0 && i < history.length){
				Text.display(gui.x + gui.scale, gui.y + (gui.scale * 10) + gui.scale + (j * (gui.scale * 10)), history[i], 0xcacaca);
			}
		}
		
		gui.scrollpos = drawscrollbar(
		  Std.int(gui.x + gui.width - 12 * gui.scale), 
			Std.int(gui.y + (gui.scale * 10) + gui.scale), 
			Std.int(10 * gui.scale), Std.int(gui.height - (gui.scale * 10) - (2 * gui.scale)), 
		  gui.scrollpos, history.length - (Math.floor(gui.height / (gui.scale * 10)) - 1), 
		  true, 1);
	}
	
	private static function render() {
		if (showlogwindow) {
			var olddrawto:RenderTexture = Gfx.drawto;
			var oldfontsize:Float = Text.size;
			var oldfont:String = Text.font;
			
			Text.font = "default"; Text.size = gui.scale;
			//Draw to our special window
			Gfx.endquadbatch();
			if (Gfx.drawto != null) Gfx.drawto.bundleunlock();
			
			Gfx.drawtoscreen();
		  
			drawwindow();
			
			//Restore the old texture
			Gfx.drawto = olddrawto;
			Gfx.drawto.bundlelock();
			Text.font = oldfont; Text.size = oldfontsize;
		}
	}
	
	private static var showlogwindow:Bool;
	private static var history:Array<String> = [];
	private static var posinfo:Array<haxe.PosInfos> = [];
	private static var gui;
	
	private static function init() {
		gui = { 
			x: 0, y: 0, width: 400, height: 150, scale: 2.0,
			xdragoffset: 0, ydragoffset: 0,
			showscrollbar: false, scrollpos: 0, scrolldelay: 0, scrollspeed: 1, 
			windowdrag: false,
			mousefocus: "none"
		};
	}
	
	/* Draw little 8x8 icons for the debug UI! */
	private static function drawicon(x:Int, y:Int, c:Int, type:String) {
	  switch(type) {	
			case "arrowup":
				Gfx.filltri(x, y + 7 * gui.scale, x + 4 * gui.scale, y + 1 * gui.scale, x + 8 * gui.scale, y + 7 * gui.scale, c);
			case "arrowdown":
				Gfx.filltri(x, y + 1 * gui.scale, x + 4 * gui.scale, y + 7 * gui.scale, x + 8 * gui.scale, y + 1 * gui.scale, c);
			case "close":
				Gfx.drawline(x, y, x + 8 * gui.scale, y + 8 * gui.scale, c);
				Gfx.drawline(x, y + 8 * gui.scale, x + 8 * gui.scale, y, c);
			default:
		}
	}
	
	private static function drawscrollbar(x:Int, y:Int, width:Int, height:Int, scrollpos:Int, scrollmax:Int, applywheel:Bool, scrolladjustment:Int = 1):Int {
		if (scrollmax > 0) {
			if(applywheel){
				if (Mouse.mousewheel > 0) {
					Mouse.mousewheel = 0;	
					scrollpos -= scrolladjustment;
					if (scrollpos < 0) scrollpos = 0;
				}else if (Mouse.mousewheel < 0) {
					Mouse.mousewheel = 0;	
					scrollpos += scrolladjustment;
					if (scrollpos >= scrollmax) scrollpos = scrollmax;
				}
			}
			
			if (Mouse.leftheld()) {
				if ((Geom.inbox(Mouse.x, Mouse.y, x, y, width, 10) 
					&& gui.mousefocus == "none") || gui.mousefocus == "topbutton") {
					if (gui.scrolldelay > 0) {
						gui.scrolldelay--;
					}else{
						scrollpos -= scrolladjustment;
						if (scrollpos < 0) scrollpos = 0;
						gui.scrolldelay = gui.scrollspeed;
					}
					gui.mousefocus = "topbutton";
				}else if ((Geom.inbox(Mouse.x, Mouse.y, x, y + height - 10, width, 10) 
						  && gui.mousefocus == "none") || gui.mousefocus == "bottombutton") {
					if (gui.scrolldelay > 0) {
						gui.scrolldelay--;
					}else{
						scrollpos += scrolladjustment;
						if (scrollpos >= scrollmax) scrollpos = scrollmax;
						gui.scrolldelay = gui.scrollspeed;
					}
					gui.mousefocus = "bottombutton";
				}else if ((Geom.inbox(Mouse.x, Mouse.y, x, y, width, height) 
						  && gui.mousefocus == "none") || gui.mousefocus == "scrollbar") {
					scrollpos = Math.round(((Mouse.y - y - (15/2)) * scrollmax) / (height - (10 * 2) - 15));
					gui.mousefocus = "scrollbar";
				}
			}else {
				gui.mousefocus = "none";
				gui.scrolldelay = 0;
			}
			
			scrollpos = Std.int(Geom.clamp(scrollpos, 0, scrollmax));
			
			var scrollbarposition:Int = Math.round((scrollpos * (height - (10 * 2 * gui.scale) - 15)) / scrollmax);
			Gfx.fillbox(x, y, width, height, 0x2a282f);
			Gfx.fillbox(x + 1, y + (10 * gui.scale) + scrollbarposition, width - 1, 15, 0xb9bcc1);
			
			drawicon(x + 2, y + 1, 0x828085, "arrowup");
			drawicon(x + 2, Std.int(y + height + ( -10 + 3) * gui.scale), 0x828085, "arrowdown");
		} else {
			// No scrolling. Draw a basic skeleton of a scrollbar
			Gfx.fillbox(x, y, width, height, 0x2a282f);
			scrollpos = 0; // reset
			if (!Mouse.leftheld()) {
				gui.mousefocus = "none";
			}
			gui.scrolldelay = 0;
		}
		
		return scrollpos;
	}
}