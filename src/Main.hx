import haxegon.*;

class Main {
	var gametime:Float = 0;
	function update() {
		gametime+= 1;
		
		for (i in 0 ... 24) {
		  Gfx.fillbox(i * 10, i * 10, Gfx.screenwidth - (i * 20), Gfx.screenheight - (i * 20), 
			            Gfx.hsl((gametime + i * 15) % 360, 0.5, 0.5));
		}
		
		Text.setfont("default", 2);
		Text.display(Text.CENTER + 1, Text.CENTER + 1, "Haxegon testing", Col.BLACK);
		Text.display(Text.CENTER, Text.CENTER, "Haxegon testing");
	}
}