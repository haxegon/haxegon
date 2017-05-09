package haxegon;

import starling.display.*;
import starling.events.*;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;
import openfl.net.*;
import openfl.Lib;
	
class Mouse{		
	private static var _x:Int;
	private static var _y:Int;
	private static var previousx:Int;
	private static var previousy:Int;
	public static var deltax:Int;
	public static var deltay:Int;
	
	public static var x(get, set):Int;
	static function get_x():Int {
		return _x;
	}
	
	static function set_x(_newx:Float):Int {
		_x = Std.int(_newx);
		#if html5
		Debug.log("ERROR: Cannot set value of Mouse.x in HTML5.");
		#elseif flash
		Debug.log("ERROR: Cannot set value of Mouse.x in Flash.");
		#else
		lime.ui.Mouse.warp(_x, _y, Core.window);
		#end
		return _x;
	}
	
	public static var y(get, set):Int;
	static function get_y():Int {
		return _y;
	}
	
	static function set_y(_newy:Float):Int {
		_y = Std.int(_newy);
		#if html5
		Debug.log("ERROR: Cannot set value of Mouse.y in HTML5.");
		#elseif flash
		Debug.log("ERROR: Cannot set value of Mouse.y in Flash.");
		#else
		lime.ui.Mouse.warp(_x, _y, Core.window);
		#end
		return _y;
	}
	
	private static var starstage:starling.display.Stage;
	private static var flashstage:openfl.display.Stage;
	
	private static var _current:Int;
	private static var _held:Int;
	private static var _last:Int;
	private static var _middlecurrent:Int;
	private static var _middlelast:Int;
	private static var _middleheld:Int;
	private static var _rightcurrent:Int;
	private static var _rightlast:Int;
	private static var _rightheld:Int;
	
	public static var mousewheel:Int = 0;
	
	public static function offscreen():Bool { 
		if (Geom.inbox(Mouse.x, Mouse.y, 0, 0, Gfx.screenwidth, Gfx.screenheight)) {
			return _mouseoffstage;
		}else{
			return true;
		}
	}
	private static var _mouseoffstage:Bool;
	
	public static function cursormoved():Bool { return _cursormoved; }
	private static var _cursormoved:Bool;
	
	public static function leftheld():Bool { return _current > 0; }
	public static function leftclick():Bool { return _current == 2; }
	public static function leftreleased():Bool { return _current == -1; }
	public static function leftforcerelease():Void { _current = -1; }
	public static function leftheldpresstime():Int { return _held; }
	
	public static function rightheld():Bool { return _rightcurrent > 0; }
	public static function rightclick():Bool { return _rightcurrent == 2; }	
	public static function rightreleased():Bool { return _rightcurrent == -1; }
	public static function rightforcerelease():Void { _rightcurrent = -1; }
	public static function rightheldpresstime():Int { return _rightheld; }
	
	public static function middleheld():Bool { return _middlecurrent > 0; }
	public static function middleclick():Bool { return _middlecurrent == 2; }	
	public static function middlereleased():Bool { return _middlecurrent == -1; }
	public static function middleforcerelease():Void { _middlecurrent = -1; }
	public static function middleheldpresstime():Int { return _middleheld; }
	
	public static function leftdelaypressed(delay:Int):Bool {
		if (_held >= 1) {
			if (_held == 1) {
				return true;
			}else if (_held % delay == 0) {
				return true;
			}
		}
		return false;
	}
	
	public static function rightdelaypressed(delay:Int):Bool {
		if (_rightheld >= 1) {
			if (_rightheld == 1) {
				return true;
			}else if (_rightheld % delay == 0) {
				return true;
			}
		}
		return false;
	}
	
	public static function middledelaypressed(delay:Int):Bool {
		if (_middleheld >= 1) {
			if (_middleheld == 1) {
				return true;
			}else if (_middleheld % delay == 0) {
				return true;
			}
		}
		return false;
	}
	
	private static function init(_starlingstage:starling.display.Stage, _flashstage:openfl.display.Stage) {
		_x = 0;
		_y = 0;
	  previousx = 0;
		previousy = 0;
		_cursormoved = false;
		
		_current = 0;
		_held = 0;
		_last = 0;
		
		_rightcurrent = 0;
		_rightheld = 0;
		_rightlast = 0;
		
		_middlecurrent = 0;
		_middleheld = 0;
		_middlelast = 0;
		
		starstage = _starlingstage;
		flashstage = _flashstage;
		
    starstage.addEventListener(TouchEvent.TOUCH, ontouch);
    #if !flash
    flashstage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, handleRightMouseDown);
    flashstage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, handleRightMouseUp );
		#else
		flashstage.addEventListener(MouseEvent.RIGHT_CLICK, function(event:MouseEvent){});
    #end
    flashstage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, handleMiddleMouseDown);
    flashstage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, handleMiddleMouseUp);
    
    flashstage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
    flashstage.addEventListener(MouseEvent.MOUSE_MOVE, mouseOver);
    flashstage.addEventListener(openfl.events.Event.MOUSE_LEAVE, mouseLeave);
	}
	
	private static function unload(_starlingstage:starling.display.Stage, _flashstage:openfl.display.Stage) {
		_starlingstage.removeEventListener(TouchEvent.TOUCH, ontouch);
			
    //Right mouse stuff
    #if !flash
    _flashstage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, handleRightMouseDown);
    _flashstage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, handleRightMouseUp );
    #end
    _flashstage.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, handleMiddleMouseDown);
    _flashstage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, handleMiddleMouseUp);
    
    _flashstage.removeEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
    _flashstage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseOver);
    _flashstage.removeEventListener(openfl.events.Event.MOUSE_LEAVE, mouseLeave);
	}
	
	public static function show() {
	  openfl.ui.Mouse.show();	
	}
	
	public static function hide() {
	  openfl.ui.Mouse.hide();	
	}
	
	private static function ontouch(e:TouchEvent) {
		var touch:Touch = e.getTouch(starstage);
		_mouseoffstage = true;
		
		if (touch != null) {
			if (touch.phase == TouchPhase.HOVER) {
				_mouseoffstage = false;
			}	
			
			if (touch.phase == TouchPhase.BEGAN) {
				_mouseoffstage = false;	
				
				//There was a touch (same as mouse down event
				#if flash
				if (Input.pressed(Key.CONTROL)) {
					if(_rightcurrent > 0) _rightcurrent = 1;
					else _rightcurrent = 2;
					
					_rightheld = 0;
				}else{
					if(_current > 0) _current = 1;
					else _current = 2;
					
					_held = 0;
				}
				#else
				if(_current > 0) _current = 1;
				else _current = 2;
				
				_held = 0;
				#end
			}else if(touch.phase == TouchPhase.ENDED){
				//The Touch ended (same as mouse up event)
				#if flash
				if(_rightcurrent > 0) _rightcurrent = -1;
				else _rightcurrent = 0;
				#end
				
				if(_current > 0) _current = -1;
				else _current = 0;
				
				_held = 0;
				_rightheld = 0;
			}else if (touch.phase == TouchPhase.MOVED) {
				_mouseoffstage = false;	
				//touch dragging
			}
		}
	}
	
	#if !flash
		private static function handleRightMouseDown(event:MouseEvent) { if (_rightcurrent > 0) { _rightcurrent = 1; } else { _rightcurrent = 2; } }
		private static function handleRightMouseUp(event:MouseEvent) { if (_rightcurrent > 0) { _rightcurrent = -1; } else { _rightcurrent = 0; }	}
	#end
	
	private static function handleMiddleMouseDown(event:MouseEvent) { if (_middlecurrent > 0) { _middlecurrent = 1; } else { _middlecurrent = 2; } }
	private static function handleMiddleMouseUp(event:MouseEvent) { if (_middlecurrent > 0) { _middlecurrent = -1; _middleheld = 0; } else { _middlecurrent = 0; }	}

	private static function handleMouseWheel(event:MouseEvent) {
		mousewheel = (event.delta > 0) ? 2 : -2;
	}
	
	private static function mouseOver(event:MouseEvent) {
		_mouseoffstage = false;
	}
	
	private static function mouseLeave(event:openfl.events.Event) {
		_mouseoffstage = true;
		reset();
	}
	
	private static function update(mx:Int, my:Int, firstframe:Bool) {
		_x = mx;
		_y = my;
		
		if (x == previousx && y == previousy) {
		  _cursormoved = false;	
			deltax = 0; deltay = 0;
		}else {
			deltax = x - previousx; deltay = y - previousy;
		  previousx = x; previousy = y;
			_cursormoved = true;
		}
		
		if((_last == -1) && (_current == -1))
			_current = 0;
		else if((_last == 2) && (_current == 2))
			_current = 1;
		_last = _current;
		
		if (_current > 0) {
			++_held;
    }

		if((_rightlast == -1) && (_rightcurrent == -1))
			_rightcurrent = 0;
		else if((_rightlast == 2) && (_rightcurrent == 2))
			_rightcurrent = 1;
		_rightlast = _rightcurrent;
		
		if (_rightcurrent > 0) {
			++_rightheld;
    }
		
		if((_middlelast == -1) && (_middlecurrent == -1))
			_middlecurrent = 0;
		else if((_middlelast == 2) && (_middlecurrent == 2))
			_middlecurrent = 1;
		_middlelast = _middlecurrent;
		
		
		if (_middlecurrent > 0) {
			++_middleheld;
    }
		
		if (firstframe) {
			if (mousewheel == -2) {
				mousewheel = -1;
			} else if (mousewheel == 2) {
				mousewheel = 1;
			} else {
				mousewheel = 0;
			}
		}
	}
	
	private static function reset(){
		_current = 0;
		_last = 0;
		_held = 0;
		
		_rightcurrent = 0;
		_rightlast = 0;
		_rightheld = 0;
		
		_middlecurrent = 0;
		_middlelast = 0;
		_middleheld = 0;
	}
}