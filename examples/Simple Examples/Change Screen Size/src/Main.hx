import terrylib.*;

class Main {
	// new() is a special function that is called on startup.
	function new() {
		//Set up the screen to be 160x144 (gameboy resolution), and scaled up 4 times.
		//The entire window size, then, is 640x576, which we have to then set up seperately in
		//the project.xml file.
		Gfx.resizescreen(160, 144, 4);
		
		Gfx.loadimage("starrynight");
	}
	
	function update() {
	  Gfx.drawimage(0, 0, "starrynight");
  }
}