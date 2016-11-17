package haxegon;

import starling.display.*;
import starling.events.*;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;
import openfl.net.*;
import openfl.Lib;
	
class Mouse{		
	public static var x:Int;
	public static var y:Int;
	public static var oldx:Int;
	public static var oldy:Int;
	private static var starstage:starling.display.Stage;
	private static var flashstage:openfl.display.Stage;
	
	private static var _current:Int;
	private static var _held:Int;
	private static var _last:Int;
	private static var _middlecurrent:Int;
	private static var _middlelast:Int;
	private static var _rightcurrent:Int;
	private static var _rightlast:Int;
	private static var _rightheld:Int;
	private static var gotosite:String = "";
	
	public static var mousewheel:Int = 0;
	
	public static var mouseoffstage:Bool;
	public static var isdragging:Bool;
	public static var cursormoved:Bool;
	
	public static function leftheld():Bool { return _current > 0; }
	public static function leftclick():Bool { return _current == 2; }
	public static function leftreleased():Bool { return _current == -1; }
	public static function leftforcerelease():Void { _current = -1; }
	
	public static function rightheld():Bool { return _rightcurrent > 0; }
	public static function rightclick():Bool { return _rightcurrent == 2; }	
	public static function rightreleased():Bool { return _rightcurrent == -1; }
	public static function rightforcerelease():Void { _rightcurrent = -1; }
	
	public static function middleheld():Bool { return _middlecurrent > 0; }
	public static function middleclick():Bool { return _middlecurrent == 2; }	
	public static function middlereleased():Bool { return _middlecurrent == -1; }
	public static function middleforcerelease():Void { _middlecurrent = -1; }
	
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
	
	
	private static function init(_starlingstage:starling.display.Stage, _flashstage:openfl.display.Stage) {
		x = 0;
		y = 0;
		oldx = 0;
		oldy = 0;
		cursormoved = false;
		_rightcurrent = 0;
		_rightlast = 0;
		_rightheld = 0;
		_middlecurrent = 0;
		_middlelast = 0;
		_current = 0;
		_held = 0;
		_last = 0;
		
		starstage = _starlingstage;
		flashstage = _flashstage;
		
    starstage.addEventListener(TouchEvent.TOUCH, ontouch);
    
    #if !flash
    flashstage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, handleRightMouseDown);
    flashstage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, handleRightMouseUp );
    #end
    flashstage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, handleMiddleMouseDown);
    flashstage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, handleMiddleMouseUp);
    
    flashstage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
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
	}	
	
	public static function visitsite(t:String) {
		gotosite = t;
	}
	
	public static function show() {
	  openfl.ui.Mouse.show();	
	}
	
	public static function hide() {
	  openfl.ui.Mouse.hide();	
	}
	
	private static function ontouch(e:TouchEvent) {
		var touch:Touch = e.getTouch(starstage);
		if (touch != null) {
			if(touch.phase == TouchPhase.BEGAN){
				//There was a touch (same as mouse down event)
				if (Input.pressed(Key.CONTROL)) {
					if(_rightcurrent > 0) _rightcurrent = 1;
					else _rightcurrent = 2;
					
					_rightheld = 0;
				}else{
					if(_current > 0) _current = 1;
					else _current = 2;
					
					if (_current == 2) {
						if (gotosite != "") {
							var link:URLRequest = new URLRequest(gotosite);
							Lib.getURL(link);
							gotosite = "";
						}
					}
					
					_held = 0;
				}
			}else if(touch.phase == TouchPhase.ENDED){
				//The Touch ended (same as mouse up event)
				if(_rightcurrent > 0) _rightcurrent = -1;
				else _rightcurrent = 0;
				
				if(_current > 0) _current = -1;
				else _current = 0;
				
				_held = 0;
				_rightheld = 0;
			}else if(touch.phase == TouchPhase.MOVED){
				//touch dragging
			}
		}
	}
	
	#if !flash
		private static function handleRightMouseDown(event:MouseEvent) { if (_rightcurrent > 0) { _rightcurrent = 1; } else { _rightcurrent = 2; } }
		private static function handleRightMouseUp(event:MouseEvent) { if (_rightcurrent > 0) { _rightcurrent = -1; } else { _rightcurrent = 0; }	}
	#end
	
	private static function handleMiddleMouseDown(event:MouseEvent) { if (_middlecurrent > 0) { _middlecurrent = 1; } else { _middlecurrent = 2; } }
	private static function handleMiddleMouseUp(event:MouseEvent) { if (_middlecurrent > 0) { _middlecurrent = -1; } else { _middlecurrent = 0; }	}

	private static function handleMouseWheel(event:MouseEvent) {
		mousewheel = (event.delta > 0) ? 2 : -2;
	}
	
	public static function update(X:Int, Y:Int, firstframe:Bool) {
		x = X;
		y = Y;
		
		if (x == oldx && y == oldy) {
		  cursormoved = false;	
		}else {
		  oldx = x; oldy = y;
			cursormoved = true;
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
		_rightheld = 0;
		_rightcurrent = 0;
		_rightlast = 0;
		_middlecurrent = 0;
		_middlelast = 0;
	}
}