import terrylib.*;

class Entityclass {
	public var active:Bool;
	
	public var x:Float;
	public var y:Float;
	
	public var vx:Float;
	public var vy:Float;
	
	public var isonground:Int;
	public var jumpstate:Int;
	public var gravity:Bool;
	
	public var rule:String;
	public var type:String;
	public var animation:String;
	public var state:String;
	public var statedelay:Int;
	
	public var checkentitycollision:Bool;
	
	public var xhitwall:Bool;
	public var yhitwall:Bool;
	public var stepoffleft:Bool;
	public var stepoffright:Bool;
	
	public var collisionx:Float;
	public var collisiony:Float;
	public var collisionw:Float;
	public var collisionh:Float;
	
	public function new() {
		reset();
	}
	
	public function reset() {
		active = false;
		
		x = 0; y = 0;
		isonground = 0;
		jumpstate = 0;
		gravity = false;
		vx = 0; vy = 0;
		animation = "none";
		
		xhitwall = false;
		yhitwall = false;
		stepoffleft = false;
		stepoffright = false;
		
		checkentitycollision = false;
		
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
			
			checkentitycollision = true;
		}else if (_type == "guard") {
			rule = "enemy";
			type = "guard";
			
			state = Random.pickstring("walk_left", "walk_right");
			
			animation = "guard";
			setcollision(0, 0, 16, 16);
			gravity = true;
		}else if (_type == "coin") {
			rule = "item";
			type = "coin";
			
			animation = "coin";
			setcollision(0, 0, 16, 16);
		}
	}
	
	public function update() {
		if (statedelay > 0) {
			statedelay--;
		}else{
			switch(type) {
				case "guard":
					if (state == "walk_left") {
						vx = -1;
						if (xhitwall || stepoffleft) {
							statedelay = 30;
							vx = 0;
							state = "walk_right";
						}
					}else if (state == "walk_right") {
						vx = 1;
						if (xhitwall || stepoffright) {
							statedelay = 30;
							vx = 0;
							state = "walk_left";
						}
					}
			}
		}
	}
}