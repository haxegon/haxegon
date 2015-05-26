package terrylib;

import openfl.display.DisplayObject;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;
import openfl.events.Event;
import openfl.net.*;
import openfl.Lib;
	
class Mouse{		
	public static var x:Int;
	public static var y:Int;
	public static var leftheld:Bool;
	public static var _current:Int;
	public static var _last:Int;
	
	public static var mouseoffstage:Bool;
	public static var isdragging:Bool;
	
	public static var _rightcurrent:Int;
	public static var _rightlast:Int;
	public static var rightheld:Bool;
	public static var gotosite:String = "";
	
	public static function rightpressed():Bool { return _rightcurrent > 0; }
	public static function justrightpressed():Bool { return _rightcurrent == 2; }	
	public static function justrightreleased():Bool { return _rightcurrent == -1; }
	#if !flash
		public static function handleRightMouseDown(event:MouseEvent):Void {	if (_rightcurrent > 0) { _rightcurrent = 1; } else { _rightcurrent = 2; } }
		public static function handleRightMouseUp(event:MouseEvent):Void {	if (_rightcurrent > 0) { _rightcurrent = -1; } else { _rightcurrent = 0; }	}
  #end
	
	public static function init(stage:DisplayObject):Void {
		//Right mouse stuff
		#if !flash
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, handleRightMouseDown);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, handleRightMouseUp );
		#end
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, mousewheelHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseOver);
		stage.addEventListener(Event.MOUSE_LEAVE, mouseLeave);
		x = 0;
		y = 0;
		_rightcurrent = 0;
		_rightlast = 0;
		_current = 0;
		_last = 0;
	}		
	
	private static function mouseLeave(e:Event) :Void {
		mouseoffstage = true;
		_current = 0;
		_last = 0;
		isdragging = false;
		_rightcurrent = 0;
		_rightlast = 0;
	}
	
	private static function mouseOver(e:MouseEvent) :Void {
		mouseoffstage = false;
	}
	
	public static function mousewheelHandler( e:MouseEvent ):Void {
		mousewheel = e.delta;
	}
	
	public static function visitsite(t:String):Void {
		gotosite = t;
	}
	
	public static var mousewheel:Int = 0;
	
	public static function update(X:Int,Y:Int):Void{
		x = X;
		y = Y;
		
		if((_last == -1) && (_current == -1))
			_current = 0;
		else if((_last == 2) && (_current == 2))
			_current = 1;
		_last = _current;
		
		if((_rightlast == -1) && (_rightcurrent == -1))
			_rightcurrent = 0;
		else if((_rightlast == 2) && (_rightcurrent == 2))
			_rightcurrent = 1;
		_rightlast = _rightcurrent;
	}
	
	public static function reset():Void{
		_current = 0;
		_last = 0;
		_rightcurrent = 0;
		_rightlast = 0;
	}
	
	public static function leftpressed():Bool { return _current > 0; }
	public static function justleftpressed():Bool { return _current == 2; }
	public static function justleftreleased():Bool { return _current == -1; }
	
	public static function handleMouseDown(event:MouseEvent):Void {
		if (Key.pressed("CONTROL")) {
			if(_rightcurrent > 0) _rightcurrent = 1;
			else _rightcurrent = 2;
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
		}
	}
	
	public static function handleMouseUp(event:MouseEvent):Void {		
		if(_rightcurrent > 0) _rightcurrent = -1;
		else _rightcurrent = 0;
		
		if(_current > 0) _current = -1;
		else _current = 0;
	}
}