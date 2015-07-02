class Ent {
	//Static entity control class
	public static var entities:Array<Entityclass>;
	public static var numentities:Int;
	public static var maxentities:Int;
	
	public static function init() {
		maxentities = 100;
		
		entities = [];
		for (i in 0 ... maxentities) {
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
		_x = _x * World.tilewidth;
		_y = _y * World.tileheight;
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
		
		if (ent >= maxentities) {
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
			entities[t].jumpstate--;
		}else {
			if (entities[t].gravity) {
				entities[t].vy = entities[t].vy + 0.5;
				if (entities[t].vy >= 2 ) entities[t].vy = 2;
			}
		}
	}
	
	public static function mapcollision(t:Int) {
		Collision.check_xcollision(t);
		Collision.check_ycollision(t);
		
		Collision.check_stepoffleft(t);
		Collision.check_stepoffright(t);
		
		Collision.check_onfloor(t);
	}
	
	public static function cleanup() {
		if (numentities > 0) {
			if (!entities[numentities - 1].active) {
				numentities--;
				cleanup();
			}
		}
	}
	
	public static function entitycollision(a:Int) {
		//check for entity v entity collisions
		if (entities[a].checkentitycollision) {
			for (b in 0 ... numentities) {
				if (a != b) {
					if (Collision.collideentity(a, b)) {
						if (entities[a].rule == "player") {
							if (entities[b].rule == "enemy") {
								Game.restart();
							}else if (entities[b].rule == "item") {
								entities[b].active = false;
							}
						}
					}
				}
			}
		}
	}
}