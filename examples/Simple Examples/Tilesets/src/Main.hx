import haxegon.*;

class Main {
	var level:Array<Int>;          //An array to hold the level data in.
	
	// new() is a special function that is called on startup.
	function new() {
		//Load in the "herotiles.png" file, and split it into 64x64 tiles.
		Gfx.loadtiles("herotiles", 64, 64);
		
		//Change to "herotiles" tileset. All Gfx.drawtile() functions will now use this tileset.
		Gfx.changetileset("herotiles");
		
		
		//There are 9 tiles in the tileset, which are:
		// 0 - Grass
		// 1 - Flower
		// 2 - Tree (base)
		// 3 - Tree (top)
		// 4 - Roof 
		// 5 - Window
		// 6 - Door
		// 7 - Door (top)
		// 8 - Roof/Wall Joint
		level = [ 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
							3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 3, 3,
							3, 3, 3, 3, 2, 2, 3, 8, 7, 8, 3, 3,
							3, 3, 3, 2, 0, 0, 2, 5, 6, 5, 3, 3,
							3, 3, 2, 0, 0, 1, 0, 0, 0, 0, 3, 3,
							3, 3, 0, 1, 0, 0, 0, 0, 0, 0, 2, 3,
							3, 3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 3,
							3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3 ];
	}
	
	function update() {
	  for (y in 0 ... 8) {
			for (x in 0 ... 12) {
				//Place a tile every 64 pixels from the data in level[].
				Gfx.drawtile(x * 64, y * 64, level[x + (y * 12)]);
			}
		}
  }
}