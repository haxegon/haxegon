import haxegon.*;

class Main {
	var leftdresseffect:Int;  // Current effect we're using for the left dress
	var rightdresseffect:Int; // Current effect we're using for the right dress
	var totaleffects:Int;     // Total number of effects
	
	var leftdressx:Float;     // X position of the left dress
	var leftdressy:Float;     // Y position of the left dress
	
	var rightdressx:Float;    // X position of the right dress
	var rightdressy:Float;    // Y position of the right dress
	
	var pulse:Int;            // A variable that counts from 0 to 20 and back.
	var pulsedir:String;      // Controls the direction of the pulse.
	
	// new() is a special function that is called on startup.
	function new() {
		Gfx.loadimage("leftdress");
		Gfx.loadimage("rightdress");
		
		leftdresseffect = 1;
		rightdresseffect = 1;
		totaleffects = 5;
		
		leftdressx = (Gfx.screenwidthmid / 2) - (Gfx.imagewidth("leftdress") / 2);
		leftdressy = Gfx.screenheightmid - (Gfx.imageheight("leftdress") / 2);
		rightdressx = Gfx.screenwidthmid + (Gfx.screenwidthmid / 2) - (Gfx.imagewidth("rightdress") / 2);
		rightdressy = Gfx.screenheightmid - (Gfx.imageheight("rightdress") / 2);
		
		pulse = 0;
		pulsedir = "up";
	}
	
  function update() {
		//If we click on the left side of the screen, change the left dress: 
		//Otherwise, change the right dress.
		if (Mouse.leftclick()) {
			if (Mouse.x < Gfx.screenwidthmid) {
				leftdresseffect = leftdresseffect + 1;
				if (leftdresseffect > totaleffects) leftdresseffect = 1;
			}else{
				rightdresseffect = rightdresseffect + 1;
				if (rightdresseffect > totaleffects) rightdresseffect = 1;
			}
		}
		
		//Change the value of "pulse" every frame.
		if (pulsedir == "up") {
			pulse++;
			if (pulse >= 20) pulsedir = "down";
		}else if (pulsedir == "down") {
			pulse--;
			if (pulse <= 0)	pulsedir = "up";
		}
		
		//Clear the screen
		Gfx.fillbox(0, 0, Gfx.screenwidthmid, Gfx.screenheight, Gfx.rgb(32, 64, 64));
		Gfx.fillbox(Gfx.screenwidthmid, 0, Gfx.screenwidthmid, Gfx.screenheight, Gfx.rgb(64, 32, 64));
		
		Text.changesize(24);
		
		//Start with zero rotation, 100% alpha and no color tinting for the left dress
		Gfx.rotation(0);
		Gfx.imagealpha(1.0);
		Gfx.imagecolor();
		
		//Draw the left dress
		if (leftdresseffect == 1) {
			Text.align(Text.CENTER);
			Text.display(Gfx.screenwidthmid / 2, 40, "[SCALE x3]");
			
			//Since the dress is drawn quite small, we scale it up x3 in each example.
			Gfx.scale(3, 3);
			Gfx.drawimage(leftdressx, leftdressy, "leftdress");
		}else if (leftdresseffect == 2) {
		  Text.align(Text.CENTER);
			Text.display(Gfx.screenwidthmid / 2, 40, "[SCALE x3, WITH ROTATION]");
			
			Gfx.scale(3, 3);
			Gfx.rotation((pulse-10) * 4);
			Gfx.drawimage(leftdressx, leftdressy, "leftdress");
		}else if (leftdresseffect == 3) {
			Text.align(Text.CENTER);
		  Text.display(Gfx.screenwidthmid / 2, 40, "[DIFFERENT X AND Y SCALES]");
			
			Gfx.scale(2 + (pulse/10), 4 - (pulse/10));
			Gfx.drawimage(leftdressx, leftdressy, "leftdress");
		}else if (leftdresseffect == 4) {
			Text.align(Text.CENTER);
		  Text.display(Gfx.screenwidthmid / 2, 40, "[ALPHA TRANSPARANCY]");
			
			Gfx.scale(3, 3);
			Gfx.rotation(0);
			Gfx.imagealpha(1.0 - (pulse / 20));
			Gfx.drawimage(leftdressx, leftdressy, "leftdress");
		}else if (leftdresseffect == 5) {
			Text.align(Text.CENTER);
			Text.align(Text.CENTER);
		  Text.display(Gfx.screenwidthmid / 2, 40, "[CHANGING GREEN MULTIPLER]");
			
			Gfx.scale(3, 3);
			Gfx.imagecolor(Gfx.rgb(255, Convert.toint((pulse * 255)/20),255));
			
			Gfx.drawimage(leftdressx, leftdressy, "leftdress");
		}
		
		//Start with zero rotation, 100% alpha and no color tinting for the right dress
		Gfx.rotation(0);
		Gfx.imagealpha(1.0);
		Gfx.imagecolor();
		
		//Draw the right dress, same as above
		if (rightdresseffect == 1) {
			Text.align(Text.CENTER);
			Text.display(Gfx.screenwidthmid + (Gfx.screenwidthmid / 2), 40, "[SCALE x3]");
			
			Gfx.scale(3, 3);
			Gfx.drawimage(rightdressx, rightdressy, "rightdress");
		}else if (rightdresseffect == 2) {
			Text.align(Text.CENTER);
		  Text.display(Gfx.screenwidthmid + (Gfx.screenwidthmid / 2), 40, "[SCALE x3, WITH ROTATION]");
			
			Gfx.scale(3, 3);
			Gfx.rotation((pulse-10) * 4);
			Gfx.drawimage(rightdressx, rightdressy, "rightdress");
		}else if (rightdresseffect == 3) {
			Text.align(Text.CENTER);
		  Text.display(Gfx.screenwidthmid + (Gfx.screenwidthmid / 2), 40, "[DIFFERENT X AND Y SCALES]");
			
			Gfx.scale(2 + (pulse/10), 4 - (pulse/10));
			Gfx.drawimage(rightdressx, rightdressy, "rightdress");
		}else if (rightdresseffect == 4) {
			Text.align(Text.CENTER);
		  Text.display(Gfx.screenwidthmid + (Gfx.screenwidthmid / 2), 40, "[ALPHA TRANSPARANCY]");
			
			Gfx.scale(3, 3);
		  Gfx.imagealpha(1.0 - (pulse / 20));
			Gfx.drawimage(rightdressx, rightdressy, "rightdress");
		}else if (rightdresseffect == 5) {
			Text.align(Text.CENTER);
		  Text.display(Gfx.screenwidthmid + (Gfx.screenwidthmid / 2), 40, "[CHANGING BLUE MULTIPLER]");
			
			Gfx.scale(3, 3);
			Gfx.imagecolor(Gfx.rgb(255, 255, Convert.toint((pulse * 255)/20)));
			Gfx.drawimage(rightdressx, rightdressy, "rightdress");
		}
		
		Gfx.fillbox(0, Gfx.screenheight - 30, Gfx.screenwidth, 30, Gfx.rgb(64, 64, 64));
		
		Text.changesize(16);
		Text.display(Gfx.CENTER, Gfx.screenheight - Text.height("") - 5, "CLICK ON A DRESS TO CHANGE EFFECTS", Col.WHITE);
  }
}