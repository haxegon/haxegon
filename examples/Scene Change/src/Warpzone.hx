import terrylib.*;

class Warpzone {
	// Some variables for drawing the warp zone effect.
	var offset:Int;
	var warpskip:Int;
	
	// Stores the front and back colours as Ints.
	var frontcol:Int;
	var backcol:Int;
	
	function new() {
		backcol = 0x0D100A;    // A dark green
	  frontcol = 0x142210;   // A slightly less dark green
		
		offset = 0;
		warpskip = 0;
	}
	
	function update() {
		//Change scene when you click the mouse.
		if (Mouse.leftclick()) {
			Scene.change(Space);   // Loads the "Space.hx" file.
		}
		
		//Offset counts to 32, and then is reset.
		//Warpskip alternates between 0 and 1 every time we count up.
		offset += 2; 
		if (offset >= 32) {
			offset -= 32;
			warpskip = (warpskip + 1) % 2;
		}
		
		var i:Int;
		//Draw 12 filled boxes
		i = 12;
		while(i >= 0){
			var temp:Int;
			temp = (i * 32) + offset; // The size of the gap between the boxes
			if (i % 2 == warpskip) {
				Gfx.fillbox(Gfx.screenwidthmid - temp, Gfx.screenheightmid - temp, temp * 2, temp * 2, backcol);
			}else {
				Gfx.fillbox(Gfx.screenwidthmid - temp, Gfx.screenheightmid - temp, temp * 2, temp * 2, frontcol);
			}
			i = i - 1;
		}
		
		Text.changesize(16);
		Text.display(6, Gfx.screenheight - 25, "LEFT CLICK TO CHANGE", Col.GRAY);
		Text.display(Gfx.screenwidth - 6, Gfx.screenheight - 25, "[now running from \"Warpzone.hx\"]", Col.WHITE, { align: Text.RIGHT } );
  }
}