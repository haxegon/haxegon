/*
 * NIGHT
 * by Stephen Lavelle
 * 
 * This version of the game has been modified from the original (by Terry) to make
 * it work with the final version of the library, and to add some helpful comments!
 * 
 * You can find the original and its source code here:
 * http://www.increpare.com/2015/05/night/
 * 
 * */
import haxegon.*;

class Main {
	//Position variables
	var x:Int;              // X position of the character.
	var y:Int;              // Y position of the character.
	var movespeed:Int;      // How many pixels the character moves when you press a button.
	
	//Animation variables
	var timer:Int;          // Counts the number of ticks since the last animation change.
	var framelength:Int;    // How many ticks to wait before changing the animation frame.
	var currentframe:Int;   // The current animation frame.
	var direction:String;   // Which direction the character moved in last.
	
	// Character boundaries.
	var leftbound:Int;
	var rightbound:Int;
	var topbound:Int;
	var bottombound:Int;

  // new() is a special function that is called on startup.
	function new() {
		//Set some initial values for the game variables.
		timer = 0;            // Counts the number of ticks since the last animation change.
		framelength = 10;     // How many ticks to wait before changing the animation frame.
		
		currentframe = 4;     // The current animation frame.
		direction = "none";   // Which direction the character moved in last.
		movespeed = 5;        // How many pixels the character moves when you press a button.
		
		//Set some boundaries for the player.
		leftbound = 20;
		rightbound = 450;
		topbound = 60;
		bottombound = 235;
		
		//Start by centering the character on the screen.
		x = Math.floor(leftbound + ((rightbound - leftbound) / 2));
		y = Math.floor(topbound + ((bottombound - topbound) / 2));
		
		//Load in the images.
		Gfx.loadimage("background");
		Gfx.loadimage("0");
		Gfx.loadimage("1");
		Gfx.loadimage("2");
		Gfx.loadimage("3");
		Gfx.loadimage("4");
		Gfx.loadimage("5");
		Gfx.loadimage("6");
		Gfx.loadimage("7");
	}

	function update() {
		//First, check input and do the game logic:
		if (Input.pressed(Key.UP)){
			y -= movespeed;
			
			if (y < topbound) {
			  //Stop the player moving too high on the screen.
				y = topbound;
			}
		}
		
		if (Input.pressed(Key.DOWN)){
			y += movespeed;
			
			if (y > bottombound) {
			  //Stop the player moving too low on the screen.
				y = bottombound;
			}
		}
		
		if (Input.pressed(Key.LEFT)){
			x -= movespeed;
			
			if (x < leftbound) {
				//Stop the player moving too far left on the screen
				x = leftbound;
			}else {
				if (direction == "turning left") {
					//Update the animation frame.
					timer++;
					if (timer > framelength) {
						timer = 0;
						currentframe = currentframe - 1;
						if (currentframe < 0 ) currentframe = 0;
					}
				}else {
				  //If direction is set to something other than "turning left",
					//then reset the timer count.
					timer = 0;
				}
				
				direction = "turning left";
			}
		}
		
		if (Input.pressed(Key.RIGHT)) {
			x += movespeed;
			
			if (x > rightbound) {
				//Stop the player moving too far right on the screen
				x = rightbound;
			}else {
				if (direction == "turning right") {
					//Update the animation frame.
					timer++;
					if (timer > framelength) {
						timer = 0;
						currentframe = currentframe + 1;
						if (currentframe > 7) currentframe = 7;
					}
				}else {
					//If direction is set to something other than "turning right",
					//then reset the timer count.
					timer = 0;
				}
				
				direction = "turning right";
			}
		}
		
		//Finally, draw the screen
		Gfx.drawimage(0, 0, "background");
		Gfx.drawimage(x, y, Convert.tostring(currentframe));
	}
}