import terrylib.*;

class Main {
	var playername:String;         // String containing the playername typed in.
	var nameentered:Bool;          // true once you've typed in the name, false otherwise.
	
  // new() is a special function that is called on startup.
	function new() {
		playername = "";
		nameentered = false;
	}
	
  function update() {
		Gfx.cls(Col.NIGHTBLUE);
		
		if (nameentered) {
			//If the name has been entered, then check for Key.ENTER before asking again.
			if (Input.justpressed(Key.ENTER)) {
				playername = "";
				nameentered = false;
			}
			
			//Display the name you typed in at the top of the screen.
			Text.changesize(16);
			Text.display(5, 5, "NAME:", Col.YELLOW);
			Text.display(60, 5, playername, Col.WHITE);
			
			Text.display(Gfx.screenwidth - 5, 5, "[press ENTER to change]", Col.GRAY, { align: Text.RIGHT } );
		}else {
			//Display the ENTER YOUR NAME prompt in the middle of the screen.
			Text.changesize(32);
			//Text.input is true when the player presses Key.ENTER.
			if (Text.input(Gfx.CENTER, Gfx.CENTER, "ENTER YOUR NAME: ", Col.YELLOW, Col.WHITE)) {
				//Text.getinput() is a function that contains the text from Text.input().
				playername = Text.getinput();
				nameentered = true;
			}
		}
  }
}