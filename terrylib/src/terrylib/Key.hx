package terrylib;

import openfl.display.DisplayObject;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

enum Keystate {
  justreleased;
	notpressed;
	pressed;
	justpressed;
}

class Key {
	public static function init(stage:DisplayObject):Void{
		stage.addEventListener(KeyboardEvent.KEY_DOWN, handlekeydown);
		stage.addEventListener(KeyboardEvent.KEY_UP, handlekeyup);
		
		//BASIC STORAGE & TRACKING			
		var i:Int = 0;
		for(i in 0...numletters){
			current.push(Keystate.notpressed);
			last.push(Keystate.notpressed);
			keyheld.push(false);
		}
		
		//LETTERS
		addkey("A", Keyboard.A);
		addkey("B", Keyboard.B);
		addkey("C", Keyboard.C);
		addkey("D", Keyboard.D);
		addkey("E", Keyboard.E);
		addkey("F", Keyboard.F);
		addkey("G", Keyboard.G);
		addkey("H", Keyboard.H);
		addkey("I", Keyboard.I);
		addkey("J", Keyboard.J);
		addkey("K", Keyboard.K);
		addkey("L", Keyboard.L);
		addkey("M", Keyboard.M);
		addkey("N", Keyboard.N);
		addkey("O", Keyboard.O);
		addkey("P", Keyboard.P);
		addkey("Q", Keyboard.Q);
		addkey("R", Keyboard.R);
		addkey("S", Keyboard.S);
		addkey("T", Keyboard.T);
		addkey("U", Keyboard.U);
		addkey("V", Keyboard.V);
		addkey("W", Keyboard.W);
		addkey("X", Keyboard.X);
		addkey("Y", Keyboard.Y);
		addkey("Z", Keyboard.Z);
		
		//NUMBERS
		addkey("ZERO",Keyboard.NUMBER_0);
		addkey("ONE",Keyboard.NUMBER_1);
		addkey("TWO",Keyboard.NUMBER_2);
		addkey("THREE",Keyboard.NUMBER_3);
		addkey("FOUR",Keyboard.NUMBER_4);
		addkey("FIVE",Keyboard.NUMBER_5);
		addkey("SIX",Keyboard.NUMBER_6);
		addkey("SEVEN",Keyboard.NUMBER_7);
		addkey("EIGHT",Keyboard.NUMBER_8);
		addkey("NINE",Keyboard.NUMBER_9);
		
		//FUNCTION KEYS
		addkey("F1",Keyboard.F1);
		addkey("F2",Keyboard.F2);
		addkey("F3",Keyboard.F3);
		addkey("F4",Keyboard.F4);
		addkey("F5",Keyboard.F5);
		addkey("F6",Keyboard.F6);
		addkey("F7",Keyboard.F7);
		addkey("F8",Keyboard.F8);
		addkey("F9",Keyboard.F9);
		addkey("F10",Keyboard.F10);
		addkey("F11",Keyboard.F11);
		addkey("F12",Keyboard.F12);
		
		//SPECIAL KEYS + PUNCTUATION
		addkey("ESCAPE",Keyboard.ESCAPE);
		addkey("MINUS",Keyboard.MINUS);
		addkey("PLUS",Keyboard.EQUAL);
		addkey("DELETE",Keyboard.DELETE);
		addkey("BACKSPACE",Keyboard.BACKSPACE);
		addkey("LBRACKET",Keyboard.LEFTBRACKET);
		addkey("RBRACKET",Keyboard.RIGHTBRACKET);
		addkey("BACKSLASH",Keyboard.BACKSLASH);
		addkey("CAPSLOCK",Keyboard.CAPS_LOCK);
		addkey("SEMICOLON",Keyboard.SEMICOLON);
		addkey("QUOTE",Keyboard.QUOTE);
		addkey("ENTER",Keyboard.ENTER);
		addkey("SHIFT",Keyboard.SHIFT);
		addkey("COMMA",Keyboard.COMMA);
		addkey("PERIOD",Keyboard.PERIOD);
		addkey("SLASH",Keyboard.SLASH);
		addkey("CONTROL",Keyboard.CONTROL);
		addkey("ALT", 18);
		addkey("SPACE",Keyboard.SPACE);
		addkey("UP",Keyboard.UP);
		addkey("DOWN",Keyboard.DOWN);
		addkey("LEFT",Keyboard.LEFT);
		addkey("RIGHT", Keyboard.RIGHT);
	}
	
	public static function update():Void{
		for (i in 0 ... numletters) {
			if (lookup.exists(i)) {
				if ((last[i] == Keystate.justreleased) && (current[i] == Keystate.justreleased)) current[i] = Keystate.notpressed;
				else if ((last[i] == Keystate.justpressed) && (current[i] == Keystate.justpressed)) current[i] = Keystate.pressed;
				last[i] = current[i];
			}
		}
	}
	
	public static function reset():Void{
		for (i in 0...numletters) {
			if (lookup.exists(i)) {
				current[i] = Keystate.notpressed;
				last[i] = Keystate.notpressed;
				keyheld[i] = false;
			}
		}
	}
	
	public static function delaypressed(k:String, delay:Int):Bool {
		keycode = keymap.get(k);
		if (keyheld[keycode]) {
			if (keydelay[keycode] <= 0) {
				keydelay[keycode] = delay;
				return true;
			}else {
		    keydelay[keycode]--;
				return false;
			}
		}else {
			keydelay[keycode] = 0;
		}
		return false;
	}
	
	public static function pressed(k:String):Bool {
		return keyheld[keymap.get(k)]; 
	}
	
	public static function justpressed(k:String):Bool { 
		if (current[keymap.get(k)] == Keystate.justpressed) {
			current[keymap.get(k)] = Keystate.pressed;
			return true;
		}else {
			return false;
		}
	}
	
	public static function justreleased(k:String):Bool { 
		if (current[keymap.get(k)] == Keystate.justreleased) {
			current[keymap.get(k)] = Keystate.notpressed;
			return true;
		}else {
			return false;
		}
	}
	
	public static function iskeycodeheld(k:Keystate):Bool {
		if (k == Keystate.justpressed || k == Keystate.pressed) {
			return true;
		}
		return false;
	}
	
	public static function handlekeydown(event:KeyboardEvent):Void {
		keycode = event.keyCode;
		
		if (lookup.exists(keycode)) {
			if (iskeycodeheld(current[keycode])) {
				current[keycode] = Keystate.pressed;
			}else {
				current[keycode] = Keystate.justpressed;
				keydelay[keycode] = 0;
			}
			keyheld[keycode] = true;
		}
	}
	
	public static function handlekeyup(event:KeyboardEvent):Void {
		keycode = event.keyCode;
		if (lookup.exists(keycode)) {
			if (iskeycodeheld(current[keycode])) {
				current[keycode] = Keystate.justreleased;
			}else {
				current[keycode] = Keystate.notpressed;
			}
			keyheld[keycode] = false;
		}
	}
	
	private static function addkey(KeyName:String, KeyCode:Int):Void {
		keymap.set(KeyName, KeyCode);
		lookup.set(KeyCode, KeyName);
		current[KeyCode] = Keystate.notpressed;
		last[KeyCode] = Keystate.notpressed;
		keyheld[KeyCode] = false;
	}
	
	public static var keymap:Map<String, Int> = new Map<String, Int>();
	public static var lookup:Map<Int, String> = new Map<Int, String>();
	public static var current:Array<Keystate> = new Array<Keystate>();
	public static var last:Array<Keystate> = new Array<Keystate>();
	public static var keydelay:Array<Int> = new Array<Int>();
	public static var keyheld:Array<Bool> = new Array<Bool>();
	
	public static var numletters:Int = 256;
	public static var keycode:Int;
}
