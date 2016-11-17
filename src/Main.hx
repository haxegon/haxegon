import haxegon.*;

class Main {
	var gametime:Float = 0;
	var page:String = "unpacked";
	
	function new() {
		Gfx.resizescreen(384, 240, 2);
		
		Gfx.loadtiles("herotiles", 64, 64);
		Gfx.loadtiles("herotiles2", 64, 64);
	}
	
	function update() {
		gametime+= 1;
		
		if (Input.justpressed(Key.SPACE)) {
		  if (page == "unpacked") {
			  page = "packed";	
			}else {
				page = "unpacked";	
			}
		}
		
		Gfx.clearscreen(Col.NIGHTBLUE);
		
		if (page == "unpacked") {
		  Gfx.drawimage(10, 50, "leftdress");
			Gfx.drawimage(Gfx.screenwidth - 10 - Gfx.imagewidth("rightdress"), 50, "rightdress");
			
			for (j in 0 ... 3) {
				for (i in 0 ... 3) {
					Gfx.drawtile(100 - 4 + i * 68, 25 - 4 + j * 68, "herotiles", Std.int(i + (j * 3) + (gametime / 20)) % Gfx.numberoftiles("herotiles"));
				}
			}
		}else {
		  Gfx.drawimage(10, 50, "leftdress2");
			Gfx.drawimage(Gfx.screenwidth - 10 - Gfx.imagewidth("rightdress2"), 50, "rightdress2");
			
			for (j in 0 ... 3) {
				for (i in 0 ... 3) {
					Gfx.drawtile(100 - 4 + i * 68, 25 - 4 + j * 68, "herotiles2", Std.int(i + (j * 3) + (gametime / 20)) % Gfx.numberoftiles("herotiles"));
				}
			}
		}
		
		Text.setfont("default", 1);
		if(page == "unpacked"){
			Text.display(Text.CENTER, Text.TOP + 2, "UNPACKED (press space to toggle)");
		}else {
			Text.display(Text.CENTER, Text.TOP + 2, "PACKED (press space to toggle)");
		}
		Text.display(Text.CENTER, Text.BOTTOM - 4, "Haxegon testing");
	}
}