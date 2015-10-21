import haxegon.*;

class Main {
	function update() {
		//Change scene when you click the mouse.
		if (Mouse.leftclick()) {
			Scene.change(Space);           // Loads the "Space.hx" file.
		}
		
		//Show the title screen text.
		Text.changesize(32);
		Text.align(Text.LEFT);
		Text.display(Text.CENTER, Gfx.screenheightmid - 30, "SCENE CHANGE EXAMPLE", Col.WHITE);
		Text.changesize(16);
		Text.display(Text.CENTER, Gfx.screenheightmid + 10, "LEFT CLICK TO CHANGE", Col.WHITE);
  }
}