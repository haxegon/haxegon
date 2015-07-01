class Entityclass {
	public var active:Bool;
	
	public var x:Float;
	public var y:Float;
	
	public var newx:Float;
	public var newy:Float;
	
	public var vx:Float;
	public var vy:Float;
	
	public var ax:Float;
	public var ay:Float;
	
	public var isonground:Int;
	public var jumpstate:Int;
	public var gravity:Bool;
	
	public var rule:String;
	public var type:String;
	public var animation:String;
	public var state:String;
	public var statedelay:Int;
	
	public var collisionx:Float;
	public var collisiony:Float;
	public var collisionw:Float;
	public var collisionh:Float;
	
	public function new() {
		reset();
	}
	
	public function reset() {
		x = 0; y = 0;
		isonground = 0;
		jumpstate = 0;
		gravity = false;
		newx = 0; newy = 0;
		vx = 0; vy = 0;
		ax = 0; ay = 0;
		active = false;
		animation = "none";
		
		rule = "none";
		type = "none";
		state = "normal";
		statedelay = 0;
		
		setcollision(0, 0, 16, 16);
	}
	
	public function setcollision(_x:Float, _y:Float, _w:Float, _h:Float) {
		collisionx = _x;
		collisiony = _y;
		collisionw = _w;
		collisionh = _h;
	}
	
	public function create(_x:Float, _y:Float, _type:String) {
		reset();
		x = _x; y = _y;
		active = true;
		
		if (_type == "player") {
			rule = "player";
			type = "player";
			
			animation = "player";
			setcollision(0, 0, 16, 16);
			gravity = true;
		}else if (_type == "guard") {
			rule = "enemy";
			type = "guard";
			
			animation = "guard";
			setcollision(0, 0, 16, 16);
			gravity = true;
		}
	}
	
	public function update() {
		switch(type) {
			case "guard":
			  if (state == "walk_left") {
					
				}
		}
	}
}