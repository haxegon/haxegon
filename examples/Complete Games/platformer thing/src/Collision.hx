import haxegon.*;

class Collision {
	//Some handy temporary variables
	public static var tx1:Float;
	public static var ty1:Float;
	public static var tx2:Float;
	public static var ty2:Float;
	public static var tx3:Float;
	public static var ty3:Float;
	public static var temp:Int;
	
	public static function getgridpoint(t:Float, gridwidth:Int):Int {
		t = ((t - (t % gridwidth)) / gridwidth);
		return Convert.toint(t);
	}
	
	public static function tilecollide(x:Int, y:Int):Bool {
		//Check if tile at x, y is a collision tile.
		temp = World.tileat(x, y);
		if (temp > -1) {
		  return World.tilecollision[temp];	
		}
		return true;
	}
	
	public static function pointcollide(x:Float, y:Float):Bool {
		//Check if a point collides with the map
		if (tilecollide(getgridpoint(x, World.tilewidth), getgridpoint(y, World.tileheight))) return true;
		return false;
	}
	
	public static function checkwall(x:Float, y:Float, w:Float, h:Float):Bool {
		//Check key points in the rectangle to see if there's a collision.
		//Corners
		if (pointcollide(x, y)) return true;
		if (pointcollide(x + w - 1, y)) return true;
		if (pointcollide(x, y + h - 1)) return true;
		if (pointcollide(x + w - 1, y + h - 1)) return true;
		
		//Half way points
		if (pointcollide(x + 8, y)) return true;
		if (pointcollide(x + 8, y + h - 1)) return true;
		if (pointcollide(x, y + 8)) return true;
		if (pointcollide(x + w - 1, y + 8)) return true;
		
		return false;
	}
	
	public static function check_xcollision(t:Int) {
		Ent.entities[t].xhitwall = false;
		
		while (!xcollision(t) && Ent.entities[t].vx != 0) {
			Ent.entities[t].xhitwall = true;
			if (Ent.entities[t].vx > 0)	Ent.entities[t].vx--;
			if (Ent.entities[t].vx < 0) Ent.entities[t].vx++;
			if (Ent.entities[t].vx > -1 && Ent.entities[t].vx < 1) Ent.entities[t].vx = 0;
		}
		
		Ent.entities[t].x = Ent.entities[t].x + Ent.entities[t].vx;
	}
	
	public static function xcollision(t:Int):Bool {
		//Deal with horizontal map collisions.
		if (checkwall(Ent.entities[t].x + Ent.entities[t].vx + Ent.entities[t].collisionx, 
								 Ent.entities[t].y + Ent.entities[t].collisiony,
								 Ent.entities[t].collisionw,
								 Ent.entities[t].collisionh)) {		
		  return false;
		}else {
			return true;
		}
	}
	
	public static function check_ycollision(t:Int) {
		Ent.entities[t].yhitwall = false;
		
		while (!ycollision(t) && Ent.entities[t].vy != 0) {
			Ent.entities[t].yhitwall = true;
			if (Ent.entities[t].vy > 0)	Ent.entities[t].vy--;
			if (Ent.entities[t].vy < 0) Ent.entities[t].vy++;
			if (Ent.entities[t].vy > -1 && Ent.entities[t].vy < 1) Ent.entities[t].vy = 0;
		}
		
		Ent.entities[t].y = Ent.entities[t].y + Ent.entities[t].vy;
	}
	
	public static function ycollision(t:Int):Bool {
		//Deal with vertical map collisions.
		if (checkwall(Ent.entities[t].x + Ent.entities[t].collisionx, 
										 	 Ent.entities[t].y + Ent.entities[t].vy + Ent.entities[t].collisiony,
											 Ent.entities[t].collisionw,
											 Ent.entities[t].collisionh)) {		
		  return false;
		}else {
			return true;
		}
	}
	
	// True if entity t collides with the floor
	public static function collidefloor(t:Int):Bool {
		if (checkwall(Ent.entities[t].x + Ent.entities[t].collisionx, 
													  Ent.entities[t].y + Ent.entities[t].collisiony + 1,
														Ent.entities[t].collisionw,
														Ent.entities[t].collisionh)) return true;
		return false;
	}
	
	//True if point px, py is in box x1, y1 - x2, y2
	public static function collidebox(px:Float, py:Float, x1:Float, y1:Float, x2:Float, y2:Float):Bool {
		if (px >= x1 && px <= x2) {
			if (py >= y1 && py <= y2) {
				return true;
			}
		}
		return false;
	}
	
	// True if entity a collides with entity b
	public static function collideentity(a:Int, b:Int):Bool {
		tx1 = Ent.entities[b].x + Ent.entities[b].collisionx;
		ty1 = Ent.entities[b].y + Ent.entities[b].collisiony;
		tx2 = Ent.entities[b].x + Ent.entities[b].collisionw;
		ty2 = Ent.entities[b].y + Ent.entities[b].collisionh;
		
		//Top left point
		tx3 = Ent.entities[a].x + Ent.entities[a].collisionx;
		ty3 = Ent.entities[a].y + Ent.entities[a].collisiony;
		if (collidebox(tx3, ty3, tx1, ty1, tx2, ty2)) return true;
		
		//Top right point
		tx3 = Ent.entities[a].x + Ent.entities[a].collisionw;
		ty3 = Ent.entities[a].y + Ent.entities[a].collisiony;
		if (collidebox(tx3, ty3, tx1, ty1, tx2, ty2)) return true;
		
		//Bottom left point
		tx3 = Ent.entities[a].x + Ent.entities[a].collisionx;
		ty3 = Ent.entities[a].y + Ent.entities[a].collisionh;
		if (collidebox(tx3, ty3, tx1, ty1, tx2, ty2)) return true;
		
		//Bottom right point
		tx3 = Ent.entities[a].x + Ent.entities[a].collisionw;
		ty3 = Ent.entities[a].y + Ent.entities[a].collisionh;
		if (collidebox(tx3, ty3, tx1, ty1, tx2, ty2)) return true;
		
		return false;
	}
	
	// Check if entity t's bottom left corner is off the ledge
	public static function check_stepoffleft(t:Int) {
		Ent.entities[t].stepoffleft = !pointcollide(
				Ent.entities[t].x + Ent.entities[t].collisionx, 
				Ent.entities[t].y + Ent.entities[t].collisiony + Ent.entities[t].collisionh + 1);
	}
	
	// Check if entity t's bottom right corner is off the ledge
	public static function check_stepoffright(t:Int) {
		Ent.entities[t].stepoffright = !pointcollide(
				Ent.entities[t].x + Ent.entities[t].collisionx + Ent.entities[t].collisionw, 
				Ent.entities[t].y + Ent.entities[t].collisiony + Ent.entities[t].collisionh + 1);
	}
	
	public static function check_onfloor(t:Int) {
		if (collidefloor(t)) {
			Ent.entities[t].isonground = 2;
		}else {
			if (Ent.entities[t].isonground > 0) Ent.entities[t].isonground--;
		}
	}
}