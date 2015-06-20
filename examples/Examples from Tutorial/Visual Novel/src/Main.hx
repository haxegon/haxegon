import terrylib.*;

class Main {
	var currentscene:Int;
	var decisiontime:Bool;
	var currentbranch:String;
	var nextbranch:String;
	
	var titlescreen:Bool;
	
	var firstoption:String;
	var secondoption:String;
	var firstdestination:String;
	var seconddestination:String;
	
	var dialogue:String;
	var character:String;
	var sprite:String;
	var background:String;
	
	function new() {
		//Load in background images
		Gfx.loadimage("walkway");
		
		//Load in character images
		Gfx.loadimage("ren_normal");
		Gfx.loadimage("ren_happy");
		Gfx.loadimage("ren_sad");
		Gfx.loadimage("ren_shocked");
		
    //Default dialogue
		titlescreen = true;
		currentbranch = "start";
		currentscene = 0;
		decisiontime = false;
		changescene();
	}
	
	function update() {
		//Take input
		if (Mouse.leftclick()) {
			if (decisiontime) {
				if (Mouse.y >= 210) {
					if (Mouse.y <= 250) {
						//Option 1!
						currentbranch = firstdestination;
						currentscene = 0;
						changescene();
					}
				}
				
				if (Mouse.y >= 270) {
					if (Mouse.y <= 310) {
						//Option 2!
						currentbranch = seconddestination;
						currentscene = 0;
						changescene();
					}
				}
			}else {
				if (nextbranch == "none") {
				  currentscene = currentscene + 1;	
				}else {
					currentbranch = nextbranch;
					currentscene = 0;
				}
				
				changescene();
			}
		}
		
		if (titlescreen) {
			drawtitle();
		}else if (decisiontime) {
			drawchoice();
		}else{
			drawscreen();
		}
	}
	
	function changescene() {
		//Add some default values first
		nextbranch = "none";
		decisiontime = false;
		titlescreen = false;
		
		background = "walkway";
		character = "Ren";
		
		if (currentbranch == "start") {
			if (currentscene == 0) {				
				titlescreen = true;
			}else if (currentscene == 1) {				
				dialogue = "Hey, how are you today?";
				sprite = "ren_normal";
			}else if (currentscene == 2) {				
				decisiontime = true;
				
				firstoption = "I'm good!";
				firstdestination = "good";
				
				secondoption = "I'm bad...";
				seconddestination = "bad";
			}
		}else if (currentbranch == "good") {
			if (currentscene == 0) {				
				dialogue = "I'm glad! I'm also doing good!";
				sprite = "ren_happy";
			}else if (currentscene == 1) {	
				dialogue = "This is how real humans talk, I'm sure of it!";
				sprite = "ren_happy";
				
				nextbranch = "start";
			}
		}else if (currentbranch == "bad") {
			if (currentscene == 0) {				
				dialogue = "Oh no! Have the humans discovered you?";
				sprite = "ren_shocked";
			}else if (currentscene == 1) {			
				dialogue = "Quickly, let's make our way to the underground tunnels!";
				sprite = "ren_sad";
				
				nextbranch = "start";
			}
		}
	}
	
	function drawscreen() {
		//Draw background
		Gfx.drawimage(0, 0, background);
		//Draw character
		Gfx.drawimage(Gfx.CENTER, 0, sprite);
		//Draw the textbox
		Gfx.fillbox(0, 340, 768, 140, Col.NIGHTBLUE, 0.75);
		//Draw character name
		Text.display(20, 350, character, Col.YELLOW);
		//Draw some text
		Text.display(60, 380, dialogue);
	}
	
	function drawchoice() {
		//Draw background
		Gfx.drawimage(0, 0, background);
		//Draw character
		Gfx.drawimage(Gfx.CENTER, 0, sprite);
		
		//Draw first option
		Gfx.fillbox(0, 210, 768, 40, Col.NIGHTBLUE, 0.75);
		Text.display(Text.CENTER, 210, firstoption, Col.WHITE);
		
		//Draw second option
		Gfx.fillbox(0, 270, 768, 40, Col.NIGHTBLUE, 0.75);
		Text.display(Text.CENTER, 270, secondoption, Col.WHITE);
	}
	
	function drawtitle() {
		Text.changesize(48);
		Text.display(Gfx.CENTER, Gfx.CENTER, "REN'S STORY");
		Text.changesize(24);
	}
}