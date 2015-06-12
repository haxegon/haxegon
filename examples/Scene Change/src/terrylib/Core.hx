package terrylib;

import openfl.display.*;
import openfl.events.*;
import openfl.Lib;

@:access(Main)
@:access(terrylib.Mouse)
@:access(terrylib.Input)
@:access(terrylib.Scene)
class Core extends Sprite {
	public function new() {
		super();
		
		init();
	}
	
	public function init():Void {
		//Init library classes
		Random.setseed(Std.int(Math.random() * 233280));
		Input.init(this.stage);
		Mouse.init(this.stage);
		Gfx.init(this.stage);
		Music.init();
		
		//Default setup
		Gfx.resizescreen(768, 480);
		Text.addfont("opensans", 24);
		
		Scene.init();
		
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	
	
	public function update(t:Event):Void {
		Mouse.update(Std.int(Lib.current.mouseX / Gfx.screenscale), Std.int(Lib.current.mouseY / Gfx.screenscale));
		
		Gfx.backbuffer.lock();
		
		Gfx.cls();
		Scene.update();
		Text.drawstringinput();
		Debug.showlog();
		
		Gfx.backbuffer.unlock();
	}
	
	
}