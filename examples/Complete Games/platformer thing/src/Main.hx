import terrylib.*;

class Main {
	var player:Int;
	
	function new() {
		Gfx.resizescreen(384, 240, 2);
		
		Game.init();
		Ent.init();
		
	  Gfx.loadtiles("tiles", World.tilewidth, World.tileheight);	
		
		Gfx.defineanimation("player", "tiles", 20, 20, 1);
		Gfx.defineanimation("guard", "tiles", 21, 21, 1);
		Gfx.defineanimation("coin", "tiles", 22, 22, 1);
		
		Game.restart();
	}
	
	function update() {
		input();
		logic();
		render();
  }
	
	function input() {
		//Check for input
	  player = Ent.getentity("player");
		
		if (player > -1) {
			if (Input.pressed(Key.LEFT) || Input.pressed(Key.A)) {
				Ent.entities[player].vx = -2;
			}else if (Input.pressed(Key.RIGHT) || Input.pressed(Key.D)) {
				Ent.entities[player].vx = 2;
			}else {
				Ent.entities[player].vx = 0;
			}
			
			if (Input.justpressed(Key.UP) || Input.justpressed(Key.W)) {
				Game.jumppressed = 5; 
			}
			
			if (Game.jumppressed > 0) {
				Game.jumppressed--;
				if (Ent.entities[player].isonground > 0 && Ent.entities[player].jumpstate == 0) {
					Ent.entities[player].vy = -3;
					Ent.entities[player].jumpstate = 25;
				}
			}
		}
	}

	function logic() {
		//Update the game
		for (i in 0 ... Ent.numentities) {
			Ent.physics(i);
			Ent.mapcollision(i);
			Ent.entities[i].update();
			Ent.entitycollision(i);
		}
		
		Ent.cleanup();
	}
	
	function render() {
		//Draw the screen
		drawbackground();
		drawentities();
	}	

	function drawentities() {
		for (i in 0 ... Ent.numentities) {
			if (Ent.entities[i].active) {
				Gfx.drawanimation(Convert.toint(Ent.entities[i].x), Convert.toint(Ent.entities[i].y), Ent.entities[i].animation);
			}
		}
		
		//Draw the player over everything
		player = Ent.getentity("player");
		if (Ent.entities[player].active) {
			Gfx.drawanimation(Convert.toint(Ent.entities[player].x), Convert.toint(Ent.entities[player].y), Ent.entities[player].animation);
		}
	}
	
	function drawbackground() {
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				Gfx.drawtile(i * World.tilewidth, j * World.tileheight, World.currentlevel[i + (j * World.mapwidth)]);
			}
		}
	}
}