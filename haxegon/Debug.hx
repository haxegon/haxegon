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
@:access(haxegon.Text)
class Debug {
	/** Clear the debug buffer */
	public static function clear() {
		history = [];
		posinfo = [];
		repeatcount = [];
		showlogwindow = false;
		init();
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
		//if our message and position haven't changed, it's being repeated
		if (posinfo.length == 0) {
			posinfo.push(pos);
			history.push(Convert.tostring(t));
			repeatcount.push(1);
			gui.scrollpos = history.length;
		}else {
			if (positionmatch(posinfo[posinfo.length - 1], pos) && history[history.length - 1] == Convert.tostring(t)) {
				repeatcount[repeatcount.length - 1]++;
			}else {
				posinfo.push(pos);
				history.push(Convert.tostring(t));
				repeatcount.push(1);
				gui.scrollpos = history.length;			
			}
		}
		
		if (gui.height < history.length) gui.height = history.length;
		if (gui.height > gui.maxlines) gui.height = gui.maxlines;
		
		if (gui.scrollpos > history.length - (gui.height - 1) - 1) gui.scrollpos = history.length - (gui.height - 1) - 1;
		showlogwindow = true;
	}
	
	private static function positionmatch(p1:haxe.PosInfos, p2:haxe.PosInfos):Bool {
		if (p1.fileName == p2.fileName) {
			if (p1.className == p2.className) {
				if (p1.lineNumber == p2.lineNumber) {
					if (p1.methodName == p2.methodName) {
					  return true;
					}
				}
			}
		}
		return false;
	}
	
	/* Returns true if the debug log is capturing mouse input right now */
	private static function update():Bool {
		if (showlogwindow) {
			var capturinginput:Bool = false;
			if (Geom.inbox(Mouse.x, Mouse.y, 0, 0, Gfx.screenwidth, (gui.height * gui.scale * 10) + 2)) {
				capturinginput = true;
			}
			
			return capturinginput;
		}
		
		return false;
	}
	
	private static function drawwindow() {
		var windowheight:Int = Std.int(gui.height * gui.scale * 10);
		Gfx.fillbox(0, 0, Gfx.screenwidth, windowheight, 0x272822, 0.75);
		var clearwidth:Int = Std.int(Text.width("clear") + (16 * gui.scale));
		
		if (Geom.inbox(Mouse.x, Mouse.y, Gfx.screenwidth - clearwidth, windowheight, clearwidth, gui.scale * 10)) {
			Gfx.fillbox(Gfx.screenwidth - clearwidth, windowheight, clearwidth, gui.scale * 10, 0x272822);
			drawicon(Std.int(Gfx.screenwidth - clearwidth + (gui.scale * 2)), Std.int(windowheight + (gui.scale * 2)), 0xFFFFFF, "close");
  		Text.display(Gfx.screenwidth - clearwidth + (gui.scale * 12), Std.int(windowheight + (gui.scale * 1)), "clear", 0xFFFFFF);
			if (gui.mousefocus == "none" && Mouse.leftheld()) {
			  clear();
			}
		}else {
			Gfx.fillbox(Gfx.screenwidth - clearwidth, windowheight, clearwidth, gui.scale * 10, 0x272822, 0.5);
			drawicon(Std.int(Gfx.screenwidth - clearwidth + (gui.scale * 2)), Std.int(windowheight + (gui.scale * 2)), 0xcacaca, "close");
	  	Text.display(Gfx.screenwidth - clearwidth + (gui.scale * 12), Std.int(windowheight + (gui.scale * 1)), "clear", 0xcacaca);
		}
		
		gui.scrollpos = drawscrollbar(
		  Std.int(Gfx.screenwidth - (12 * gui.scale)), 0, 
			Std.int(10 * gui.scale), Std.int(gui.height * gui.scale * 10),
		  gui.scrollpos, history.length - (gui.height - 1) - 1, 
		  true, 1);
		
		for (j in 0 ... gui.height) {
			var i:Int = j + gui.scrollpos;
			if(i >= 0 && i < history.length){
				Text.align(Text.LEFT);
				Text.display(gui.scale * 2, (gui.scale * 2) + (j * (gui.scale * 10)), history[i], 0xcacaca);
				if (repeatcount[i] > 1) {
					Text.align(Text.RIGHT);
					Text.display(Std.int(Gfx.screenwidth - (gui.showscrollbar?(14 * gui.scale):(2 * gui.scale))), (j * (gui.scale * 10)), "x" + repeatcount[i], 0xffbaba);
				}
			}
		}
	}
	
	private static function render() {
		if (showlogwindow) {
			var olddrawto:RenderTexture = Gfx.drawto;
			var oldfontsize:Float = Text.size;
			var oldfont:String = Text.font;
			var oldalign:Int = Text.textalign;
			
			//Figure out GUI scale before we draw anything
			gui.scale = Math.floor(Gfx.screenheight / 300) + 1;
			
			Text.font = "default"; Text.size = gui.scale;
			//Draw to our special window
			Gfx.endmeshbatch();
			if (Gfx.drawto != null) Gfx.drawto.bundleunlock();
			
			Gfx.drawtoscreen();
		  
			drawwindow();
			
			//Restore the old texture
			Gfx.drawto = olddrawto;
			Gfx.drawto.bundlelock();
			Text.font = oldfont; Text.size = oldfontsize;
			Text.textalign = oldalign;
		}
	}
	
	private static var showlogwindow:Bool;
	private static var history:Array<String> = [];
	private static var posinfo:Array<haxe.PosInfos> = [];
	private static var repeatcount:Array<Int> = [];
	private static var gui;
	
	private static function init() {
		gui = { 
			height: 0, scale: 2.0,
			showscrollbar: false, scrollpos: 0, scrolldelay: 0, scrollspeed: 1, mousefocus: "none",
			maxlines: 8
		};
	}
	
	/* Draw little 8x8 icons for the debug UI! */
	private static function drawicon(x:Int, y:Int, c:Int, type:String) {
		var oldlinethickness:Float = Gfx.linethickness;
		Gfx.linethickness = gui.scale;
	  switch(type) {	
			case "arrowup":
				Gfx.filltri(x, y + 7 * gui.scale, x + 4 * gui.scale, y + 1 * gui.scale, x + 8 * gui.scale, y + 7 * gui.scale, c);
			case "arrowdown":
				Gfx.filltri(x, y + 1 * gui.scale, x + 4 * gui.scale, y + 7 * gui.scale, x + 8 * gui.scale, y + 1 * gui.scale, c);
			case "close":
				Gfx.drawline(x + 1, y + 1, x + 6 * gui.scale, y + 6 * gui.scale, c);
				Gfx.drawline(x + 1, y + 6 * gui.scale, x + 6 * gui.scale, y + 1, c);
			default:
		}
		Gfx.linethickness = oldlinethickness;
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
			
			gui.showscrollbar = true;
		} else {
			// No scrolling. Draw nothing
			scrollpos = 0; // reset
			if (!Mouse.leftheld()) {
				gui.mousefocus = "none";
			}
			gui.scrolldelay = 0;
			
			gui.showscrollbar = false;
		}
		
		return scrollpos;
	}
}