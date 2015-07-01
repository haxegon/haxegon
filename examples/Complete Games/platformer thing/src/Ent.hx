class Ent {
	//Static entity control class
	public static var entities:Array<Entityclass>;
	public static var numentities:Int;
	
	public static function init() {
		entities = [];
		for (i in 0 ... Game.maxentities) {
			entities.push(new Entityclass());
		}
		numentities = 0;
	}
	
	public static function getentity(_rule:String):Int {
		for (i in 0 ... numentities) {
			if (entities[i].active) {
				if (entities[i].rule == _rule) {
					return i;
				}
			}
		}
		
		return -1;
	}
	
	public static function createentity(_x:Float, _y:Float, _type:String) {
		//Create the entity at a tile position:
		_x = _x * Game.tilewidth;
		_y = _y * Game.tileheight;
		//Find the first non-active entity
		var ent:Int = -1;
		
		if (numentities == 0) {
			//If there are no entities, create a new one
			ent = 0;
			numentities++;
		}else{
			for (i in 0 ... numentities) {
				if (ent == -1) {
					if (!entities[i].active) {
						ent = i;
					}
				}
			}
			
			if (ent == -1) {
				//Create a new one
				ent = numentities;
				numentities++;
			}else {
				//Otherwise, reuse the old one
				entities[ent].reset();
			}
		}
		
		if (ent >= Game.maxentities) {
			throw("ERROR: Too many entities created.");
		}else{
			entities[ent].create(_x, _y, _type);
		}
	}
	
	public static function physics(t:Int) {
		//Physics
		if (entities[t].jumpstate > 0) {
			if (entities[t].vy < 0) entities[t].vy = entities[t].vy + 0.1;
			if (entities[t].vy >= 0) entities[t].vy = 0;
			//if (entities[t].vy > -0.5) entities[t].vy = 0;
			entities[t].jumpstate--;
		}else {
			if (entities[t].gravity) {
				entities[t].vy = entities[t].vy + 0.5;
				if (entities[t].vy >= 2 ) entities[t].vy = 2;
			}
		}
		
		//if (entities[t].gravity) applyfriction(t, 0, 0.5);
	}
	
	public static function mapcollision(t:Int) {
		entities[t].xhitwall = false;
		entities[t].yhitwall = false;
		
		while (!xcollision(t) && entities[t].vx != 0) {
			entities[t].xhitwall = true;
			if (entities[t].vx > 0) {
				entities[t].vx--;
				if (entities[t].vx < 0) entities[t].vx = 0;
			}
			if (entities[t].vx < 0) {
				entities[t].vx++;
				if (entities[t].vx > 0) entities[t].vx = 0;
			}
		}
		
		entities[t].x = entities[t].x + entities[t].vx;
		
		while (!ycollision(t) && entities[t].vy != 0) {
			entities[t].yhitwall = true;
			if (entities[t].vy > 0) {
				entities[t].vy--;
				if (entities[t].vy < 0) entities[t].vy = 0;
			}
			if (entities[t].vy < 0) {
				entities[t].vy++;
				if (entities[t].vy > 0) entities[t].vy = 0;
			}
		}
		
		entities[t].y = entities[t].y + entities[t].vy;
		
		if (collidefloor(t)) {
			entities[t].isonground = 2;
		}else {
			if (entities[t].isonground > 0) entities[t].isonground--;
		}
	}
	
	public static function applyfriction(t:Int, xrate:Float, yrate:Float):Void{
		if (entities[t].vx > 0) entities[t].vx -= xrate;
		if (entities[t].vx < 0) entities[t].vx += xrate;
		if (entities[t].vy > 0) entities[t].vy -= yrate;
		if (entities[t].vy < 0) entities[t].vy += yrate;
		if (entities[t].vy > 2) entities[t].vy = 2;
		if (entities[t].vy < -4) entities[t].vy = -4;
		if (entities[t].vx > 4) entities[t].vx = 4;
		if (entities[t].vx < -4) entities[t].vx = -4;
		
		if (Math.abs(entities[t].vx) <= xrate) entities[t].vx = 0;
		if (Math.abs(entities[t].vy) <= yrate) entities[t].vy = 0;
	}
	
	public static function xcollision(t:Int):Bool {
		//Deal with horizontal map collisions.
		if (Game.checkwall(entities[t].x + entities[t].vx + entities[t].collisionx, 
										 	 entities[t].y + entities[t].collisiony,
											 entities[t].collisionw,
											 entities[t].collisionh)) {		
		  return false;
		}else {
			return true;
		}
	}
	
	public static function ycollision(t:Int):Bool {
		//Deal with vertical map collisions.
		if (Game.checkwall(entities[t].x + entities[t].collisionx, 
										 	 entities[t].y + entities[t].vy + entities[t].collisiony,
											 entities[t].collisionw,
											 entities[t].collisionh)) {		
		  return false;
		}else {
			return true;
		}
	}
	
	// True if entity t collides with the floor
	public static function collidefloor(t:Int):Bool {
		if (Game.checkwall(entities[t].x + entities[t].collisionx, 
										 	 entities[t].y + entities[t].collisiony + 1,
											 entities[t].collisionw,
											 entities[t].collisionh)) return true;
		return false;
	}
}