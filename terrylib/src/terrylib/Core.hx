package terrylib;

import openfl.display.*;
import openfl.events.*;
import openfl.Lib;

@:access(Main)
class Core extends Sprite {
	public function new() {
		super();
		
		init();
	}
	
	public function init():Void {
		//Init library classes
		Key.init(this.stage);
		Mouse.init(this.stage);
		Gfx.init(this.stage);
		Music.init();
		
		//Default setup
		Gfx.createscreen(768, 480);
		Text.addfont("verdana", 24);
		
		main = new Main();
		
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	public function update(t:Event):Void {
		Mouse.update(Std.int(Lib.current.mouseX / Gfx.screenscale), Std.int(Lib.current.mouseY / Gfx.screenscale));
			
		Gfx.backbuffer.lock();
		Gfx.cls();
		main.update();
		Text.drawstringinput();
		Debug.showlog();
		Gfx.screenrender();
	}
	
	public var main:Main;
}