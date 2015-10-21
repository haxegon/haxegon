import haxegon.*;

class Main {
	var animationlist:Array<String>;    // An array of strings, used to store animation names.
	var currentanimation:Int;           // Current animation on screen.
	
  // new() is a special function that is called on startup.
	function new() {
		//Load in a tileset.
		Gfx.loadtiles("jay", 64, 80);
		
		//Define some animations based on the tileset.
		//The three numbers at the end are Start frame, End frame, and Delay between frames.
		//If Start and End frames are the same, Gfx.drawanimation() will just show a single frame.
		Gfx.defineanimation("facing left", "jay", 3, 3, 1);
		Gfx.defineanimation("facing right", "jay", 0, 0, 1);
		Gfx.defineanimation("walking left", "jay", 4, 5, 12);
		Gfx.defineanimation("walking right", "jay", 1, 2, 12);
		Gfx.defineanimation("talking left", "jay", 8, 9, 6);
		Gfx.defineanimation("talking right", "jay", 6, 7, 6);
		Gfx.defineanimation("angry", "jay", 10, 11, 6);
		Gfx.defineanimation("happy", "jay", 12, 13, 64);
		
		//animationlist[] is an array. Initilising it with animation names!
		animationlist = ["facing left", "walking left", "talking left", 
		                 "facing right", "walking right", "talking right",
										 "angry", "happy"];
		currentanimation = 0;
	}
	
  function update() {
		//Take input, change the animation when you press left and right.
		if (Input.justpressed(Key.LEFT)) {
			currentanimation--;
			if (currentanimation < 0) {
				currentanimation = currentanimation + animationlist.length;
			}
		}else if (Input.justpressed(Key.RIGHT)) {
			currentanimation++;
			if (currentanimation >= animationlist.length) {
				currentanimation = currentanimation - animationlist.length;
			}
		}
		
		//Clears the screen.
		Gfx.clearscreen(Col.GRAY);
		
		//Draw the animation. animationlist[] contains a list of animation names to draw.
		Gfx.scale(4, 4);
		Gfx.drawanimation(Gfx.screenwidthmid, Gfx.screenheightmid - 40, animationlist[currentanimation]);
		
		//Draw the footer, with information about the current animation.
		Gfx.fillbox(0, Gfx.screenheight - 80, Gfx.screenwidth, 80, Gfx.rgb(96, 96, 96));
		Text.changesize(32); Text.display(Text.CENTER, Gfx.screenheight - 80, (currentanimation + 1) + ": \"" + animationlist[currentanimation] + "\"", Col.WHITE);
		Text.changesize(16); Text.display(Text.CENTER, Gfx.screenheight - 30, "press left and right to change", Col.LIGHTBLUE);
  }
}