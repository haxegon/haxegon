import terrylib.*;

class Main {
  // new() is a special function that is called on startup.
	function new() {
		// These fonts are located in the data/fonts/ directory.
		
		// For most target platforms, you only need a TTF file, but HTML5, you need webfont
		// formats like .eof and .woff. You can create these using a generator like this:
		// http://www.fontsquirrel.com/tools/webfont-generator
		
		Text.addfont("inconsolata", 16);
		Text.addfont("inconsolata_bold", 16);
		Text.addfont("shadowsintolight", 16);
		Text.addfont("oswald", 32);
	}
	
	function update() {
		// Draw a white background
		Gfx.fillbox(0, 0, Gfx.screenwidth, Gfx.screenheight, Col.WHITE);
		
		//When changing font, it's usually best to change both the fontface and the size!
		Text.changefont("oswald");
		Text.changesize(32);
		Text.display(Text.CENTER, 5, "TerryLib Font examples:", Col.BLACK);
		Text.display(10, 80, "Oswald", Col.BLACK);
		
		Text.changesize(16);
		Text.display(10, 120, "The quick brown fox jumps over the lazy dog.", Col.BLACK);
		
		Text.changefont("inconsolata");
		Text.changesize(32);
		Text.display(10, 180, "Inconsolata", Col.BLACK);
		
		Text.changesize(16);
		Text.display(10, 220, "Amazingly few discotheques provide jukeboxes.", Col.BLACK);
		
		Text.changefont("inconsolata_bold");
		Text.changesize(32);
		Text.display(10, 280, "Inconsolata Bold", Col.BLACK);
		
		Text.changesize(16);
		Text.display(10, 320, "Heavy boxes perform quick waltzes and jigs.", Col.BLACK);
		
		Text.changefont("shadowsintolight");
		Text.changesize(32);
		Text.display(10, 380, "Shadows Into Light", Col.BLACK);
		
		Text.changesize(16);
		Text.display(10, 420, "Jackdaws love my big sphinx of quartz.", Col.BLACK);
	}
}
