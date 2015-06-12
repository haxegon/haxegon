import terrylib.*;

class Lab {
	//Create some arrays for the box effect in the background.
	var box_x:Array<Int>;
	var box_y:Array<Int>;
	var box_width:Array<Int>;
	var box_height:Array<Int>;
	var box_vx:Array<Int>;
	var box_vy:Array<Int>;
	var brightness:Array<Int>;
	
	function new() {
		//Initalise the arrays, and put some default values in them.
		brightness = [];
		box_x = []; box_y = []; box_width = []; box_height = [];
		box_vx = []; box_vy = [];
		
		for (i in 0 ... 50) {
			box_x.push(Random.int(0, Gfx.screenwidth));  //Random x position on screen
			box_y.push(Random.int(0, Gfx.screenheight)); //Random y position on screen
			box_vx.push(0); box_vy.push(0);              //Start the speeds at 0.
			brightness.push(Random.int(64, 128));        //Random brightness value.
				
			if (Random.bool()) {  // 50-50 chance of picking either a vertical or horizontal box
				//Horizontal: Choose random speed for vx between 8 and 20 pixels per second, 
				//in either left or right direction. vy is zero.
				box_vx[i] = Random.int(4, 10) * Random.pickint( -2, 2);
				//Horizontal box, so set width to 64 and height to 24.
				box_width.push(64);
				box_height.push(24);
			}else {
				//Vertical: Choose random speed for vy between 8 and 20 pixels per second, 
				//in either up or down direction. vx is zero.
				box_vy[i] = Random.int(4, 10) * Random.pickint( -2, 2);
				//Horizontal box, so set width to 24 and height to 64.
				box_width.push(24);
				box_height.push(64);
			}
		}
	}
	
	function update() {
		//Change scene when you click the mouse.
		if (Mouse.leftclick()) {
			Scene.change(Warpzone);   // Loads the "Warpzone.hx" file.
		}
		
		//Clear the screen to a very dark red
		Gfx.cls(Gfx.RGB(16, 0, 0));
		
		Gfx.setlinethickness(2);
		
		for (i in 0 ... 18) {
			//Draw the box with the given x, y, width, height and brightness values.
			Gfx.drawbox(box_x[i], box_y[i], box_width[i], box_height[i], Gfx.RGB(brightness[i], 16, 16));
			
			//Move the box based on it's speed.
			box_x[i] += box_vx[i];
			box_y[i] += box_vy[i];
			
			//If the box is offscreen, wrap it around to the other side of the screen:
			if (box_x[i] < -64) { 
				box_x[i] = Gfx.screenwidth; 
				box_y[i] = Random.int(0, Gfx.screenheight); 
			}
			
			if (box_x[i] > Gfx.screenwidth) { 
				box_x[i] = -64; 
				box_y[i] = Random.int(0, Gfx.screenheight); 
			}
			
			if (box_y[i] < -80) { 
				box_x[i] = Random.int(0, Gfx.screenwidth); 
				box_y[i] = Gfx.screenheight; 
			}
			
			if (box_y[i] > Gfx.screenheight + 40) { 
				box_x[i] = Random.int(0, Gfx.screenwidth);
				box_y[i] = -64; 
			}
		}
		
		Text.changesize(16);
		Text.display(6, Gfx.screenheight - 25, "LEFT CLICK TO CHANGE", Col.GRAY);
		Text.display(Gfx.screenwidth - 6, Gfx.screenheight - 25, "[now running from \"Lab.hx\"]", Col.WHITE, { align: Text.RIGHT } );
  }
}