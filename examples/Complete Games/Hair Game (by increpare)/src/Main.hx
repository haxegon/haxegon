/*
 * HAIR GAME
 * by Stephen Lavelle
 * 
 * This version of the game has been modified from the original (by Terry) to make
 * it work with the final version of the library, and to add some helpful comments!
 * 
 * You can find the original and its source code here:
 * http://www.increpare.com/2015/05/hair-game/
 * 
 * */
import haxegon.*;

class Main {
	// Position values defining the layout of the head of hair.
	var xmargin:Float;
	var ymargin:Float;
	var xdistancebetweenhair:Float;
	var ydistancebetweenhair:Float;
	var hairwidth:Int;
	var hairheight:Int;

	// Position and size of the bald patch
	var xbaldpatch:Float;
	var ybaldpatch:Float;
	var baldpatchsize:Float;
	
  // These arrays are two dimensional over a grid of hair (hairwidth X hairheight).
	var angles:Array<Float>;           // The angles of each strand of hair.
	var attachedtohead:Array<Bool>;    // Whether or not it's attached to the head.
	var falling:Array<Float>;          // How far a strand of hair has fallen.

	var oldmousex:Int;         // Stores the old mouse position. Used for hair combing.
	var oldmousey:Int;
	
	var hairlength:Int;        // The length in pixels of a strand of hair.
	var scragginess:Float;     // How much the hair can change direction when we generate it.

	var radius:Float;          // How close to the mouse a hair has to be to be combed.
	var fallchance:Float;      // Odds of a hair falling out when you comb over it.
	var sensitivity:Float;     // How sensitive a hair is to changing angles.
  
  // new() is a special function that is called on startup.
	function new() {
		// Hair generation
		hairlength = 70;                        // The length in pixels of a strand of hair.
    scragginess = (60 * Math.PI) / 180.0;   // How much the hair can change direction when we generate it.
	  
		// Position variables
		xmargin = 20;               // The left hand border         
	  ymargin = 20;               // The top border
	  xdistancebetweenhair = 10;  // X Distance in pixels between strands of hair
	  ydistancebetweenhair = 10;  // Y Distance in pixels between strands of hair
	  hairwidth = 50;             // Number of hairs horizontally
	  hairheight = 30;            // Number of hairs vertically
		
		// Bald patch variables
	  baldpatchsize = 40;         // Radius of the bald patch
	  fallchance = 0.03;          // Odds of a hair falling out when you comb over it (3%)
	  radius = 30;                // How close to the mouse a hair has to be to be combed.
	  sensitivity = 5;            // How sensitive a hair is to changing angles.
		
		// Define the position of the baldpatch.
		xbaldpatch = xmargin + (hairwidth * xdistancebetweenhair) - (baldpatchsize * 2);
	  ybaldpatch = ymargin + (hairheight * ydistancebetweenhair) - (baldpatchsize * 2);
		
		oldmousex = Mouse.x;
		oldmousey = Mouse.y;
		
		// Create some empty arrays, and fill them with default values.
		angles = new Array<Float>();
		falling = new Array<Float>();
		attachedtohead = new Array<Bool>();
		// These arrays are two dimensional over a grid of hair (hairwidth X hairheight).
		for (x in 0 ... hairwidth) {
			for (y in 0 ... hairheight) {
				angles.push(Random.float(0, 360));   // Each hair starts with a random angle.
				falling.push(0);                     // At first, none of the hairs are falling.
				attachedtohead.push(true);           // At first, all of the hairs are attached.
			}
		}
		
		// Create a blank tileset called "hair", and fill it with 360 tiles.
		Gfx.createtiles("hair", (hairlength * 2) + 1, (hairlength * 2) + 1, 360);
		Gfx.changetileset("hair");
		
		for (i in 0 ... 360) {
			// For each angle between 0 and 360, let's draw a hair in that direction to the tile!
			var x:Float = hairlength;
			var y:Float = hairlength;
			var a:Float = i * Math.PI / 180.0;
			
			Gfx.drawtotile(i);
			for (j in 0 ... hairlength) {
				//Draws a random hair! We draw a line from 0 to hairlength, changing
				//angle slighly every five pixels.
				if (j % 5 == 0) {
					a = ((i * Math.PI) / 180.0) + Random.float(-scragginess, scragginess);
				}
				// This draws a single pixel at point x, y of colour 0xEE7733 (a light brown).
				Gfx.fillbox(Math.floor(x), Math.floor(y), 1, 1, 0xEE7733);
				// Move the (x,y) position in the hair forward with some trigonometry.
				x += Math.cos(a);
				y += Math.sin(a);
			}
		}
		
		// After this, we have a tileset "hair" with 360 tiles, each tile containing a 
		// randomly drawn hair facing in that angle.
		
		// Now that everything's set up, we start drawing to the screen again.
		Gfx.drawtoscreen();
	}
	
	// Returns the distance between two points.
	function dist(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		var d_x = x2 - x1;
		var d_y = y2 - y1;
		return Math.sqrt((d_x * d_x) + (d_y * d_y));
	}

	// Lerping between two numbers means to find a number between them.
	// If t = 0.0, the lerp returns a, if t = 0.5 the lerp returns a number half 
	// way between a and b, if t = 1.0 it returns b, etc.
	function lerp(a:Float, b:Float, t:Float):Float {
		return a + ((b - a) * t);
	}
	
	// Lerpangle is like lerp, but for angles between 0-360 which loop around!
	// For example, it's better that half way between 350 degrees and 10 degrees is 0, not 180.
	function lerpangle(a:Float, b:Float, t:Float):Float {
		var num = repeat(b - a, 360);	
		if (num > 180){
			num -= 360;
		}
		
		if (t < 0) t = 0;
		if (t > 1) t = 1;
		
		return a + num * t;
	}
	
	// Helper function for lerpangle - returns an angle in the bounds [0 -> length].
	// For example, repeat(450, 360) would return 90.
	function repeat(t:Float, length:Float):Float {
		while (t < length) t += length;
		while (t > length) t -= length;
		return t;
	}
	
	// The game's main logic function - changes the direction of each indiviual hair,
	// and detaches them where needed.
	function haircomb(){
		if (oldmousex == Mouse.x && oldmousey == Mouse.y) {
			//If the player hasn't moved the mouse, stop here.
			return;
		}
		
		// xdiff and ydiff are set to the mouse distance changed since the last haircomb.
		var xdiff = Mouse.x - oldmousex;
		var ydiff = Mouse.y - oldmousey;
		
		for (x in 0 ... hairwidth){
			for (y in 0 ... hairheight) {
				if (attachedtohead[hairindex(x, y)]) {
					// xhair and yhair are set to the hair's position on screen.
					var xhair:Float = xmargin + (x * xdistancebetweenhair) + hairlength;
					var yhair:Float = ymargin + (y * ydistancebetweenhair) + hairlength;
					
					// distance in pixels between the mouse cursor and this strand of hair.
					var distancebetweenmouseandhair:Float = Math.min(dist(Mouse.x, Mouse.y, xhair, yhair), dist(oldmousex, oldmousey, xhair, yhair));
					
					// If that distance is less than a defined radius (30 pixels, defined above!)
					// then change its direction. We only want to change the hair around the mouse 
					// cursor, which is why we do this check.
					if (distancebetweenmouseandhair < radius) {
						//Figure out a new angle for this strand of hair with a fancy bit of trigonometry.
						var a:Float = Math.atan2(ydiff, xdiff) * 180 / Math.PI;
						var froma:Float = angles[hairindex(x, y)] ;
						a = lerpangle(a, froma, (distancebetweenmouseandhair - sensitivity) / (radius - sensitivity));
						a = ((a % 360) + 360) % 360;
						angles[hairindex(x, y)] = a;
						
						//There's a random chance this hair could fall out! We pick a random
						//number - if it's less than the earlier defined "fallchance" 
						//(which is 0.03, or 3%), then we continue checking:
						if (Random.float(0, 1) <= fallchance) {
							//If the distance between the mouse cursor and the center of the
							//baldpatch is less than the patchsize, then this strand of hair is no
							//longer attached to the head.
							if (dist(Mouse.x, Mouse.y, xbaldpatch, ybaldpatch) <= baldpatchsize) {
								attachedtohead[hairindex(x, y)] = false;
							}
						}
					}
				}
			}
		}
		
		oldmousex = Mouse.x;
		oldmousey = Mouse.y;
	}

	//Given an (x,y) position of hair, return an array index for it.
	function hairindex(x:Int, y:Int):Int {
		return x + (hairwidth * y);
	}
	
	function update() {
		var hairframe:Int;              // The tile for the current strand of hair
		var currenthair:Int;            // The index in the array for the current strand of hair
		var xhair:Float;                // The x position of the current strand
		var yhair:Float;                // The y position of the current strand
		
		for (x in 0 ... hairwidth) {
			for (y in 0 ... hairheight) {	
				// Get the array index of the current strand of hair
				currenthair = hairindex(x, y);
				// Get the tile for this hair angle
				hairframe = Convert.toint(angles[currenthair]);
				
				// Get the (x, y) position for this strand of hair on the screen
				xhair = xmargin + (xdistancebetweenhair * x);
				yhair = ymargin + (ydistancebetweenhair * y);
				
				if (attachedtohead[currenthair]) {
					// If it's attached to the head, draw it normally
					Gfx.drawtile(xhair, yhair, hairframe);
				}else {
					// If it's not, have it fall a little and draw it fallen.
					falling[currenthair]++;
					Gfx.drawtile(xhair, yhair + falling[currenthair], hairframe);
				}
			}
		}
		
		// Check for hair combing with mouse movement!
		haircomb();
	}
}