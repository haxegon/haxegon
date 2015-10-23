import haxegon.*;

class Main {
	var starx:Array<Float>;
	var stary:Array<Float>;
	var starspeed:Array<Float>;
	var numstars:Int;

	var fontlist:Array<String>;
	var fontcredits:Array<String>;
	var currentfont:Int = 0;
	var scrollposition:Int = 0;
	var scrolldelay:Int = 0;
	var counter:Int = 0;
	var coloroffset:Int = 60;

	function new() {
		numstars = 30;
		starspeed = [];
		starx = [];
		stary = [];
		
		for(i in 0 ... numstars){
			starspeed.push(Random.int(15,30));
			starx.push(Random.int(0, Gfx.screenwidth * 2));
			stary.push(Random.int(0, Gfx.screenheight));
		} 

		fontlist = ["04b11", "c64", "comic", "crypt", "default",
								"dos", "ganon", "nokia", "oldenglish", "pixel",
								"pressstart", "retrofuture", "roman", "special",
								"thin", "tiny", "yoster"];

		fontcredits = [];
		fontcredits.push("04B11 by Yuji Oshimoto, 04.jp.org");
		fontcredits.push("Standard C64 font. Converted by ck! of Freaky Fonts as \"Adore64\".");
		fontcredits.push("DeluxePaint II's Comic font. Converted by codeman38, zone38.net");
		fontcredits.push("Crypt of Tomorrow by Anna Antrophy, auntiepixelante.com");
		fontcredits.push("\"Normal\" Font from PC Paint by Mouse Systems. Converted by codeman38, zone38.net");
		fontcredits.push("Standard DOS VGA font. Ported to Zeedonk from Wikipedia's Code page 437 image.");
		fontcredits.push("Inspired by the font from Zelda: A Link to the Past. Converted by codeman38, zone38.net");
		fontcredits.push("As seen in Flixel! Nokia Cellphone font by Zeh Fernando, zehfernando.com");
		fontcredits.push("\"Old English\" Font from PC Paint by Mouse Systems. Converted by codeman38, zone38.net");
		fontcredits.push("Slightly modified version of PixelZim by Zeh Fernando, zehfernando.com");
		fontcredits.push("NAMCO inspired font by codeman38, zone38.net");
		fontcredits.push("Retro Future Heavy, by Cyclone Graphics.");
		fontcredits.push("\"Roman\" Font from PC Paint by Mouse Systems. Converted by codeman38, zone38.net");
		fontcredits.push("\"Special\" Font from PC Paint by Mouse Systems. Converted by codeman38, zone38.net");
		fontcredits.push("Small, thin 3x7 font with lowercase letters! Made for Zeedonk by Terry.");
		fontcredits.push("Useless unreadable 3x3 font! Made for Zeedonk by Terry.");
		fontcredits.push("Inspired by the font from Yoshi's Island. Converted by codeman38, zone38.net");
		
		currentfont = 0;
	}
	
	function update(){
		if(Mouse.leftclick()){
			currentfont = (currentfont + 1) % fontlist.length;
			scrolldelay = 0;
			scrollposition = 0;
		}
		
		if(counter % 2 == 0) updatestars();
		drawstars();

		Text.setfont("pixel", 3);
		Text.display(Text.CENTER, Gfx.screenheight - Text.height() - 4, "Click to change font");
		
		Text.setfont(fontlist[currentfont], 6);
		Text.display(Text.CENTER,Gfx.screenheightmid - Text.height(), "\"" + fontlist[currentfont] + "\"", Gfx.hsl((currentfont * coloroffset), 0.5, 0.5));
		
		Text.setfont(fontlist[currentfont], 3);
		
		if(Text.len(fontcredits[currentfont])< Gfx.screenwidth){
			Text.display(Text.CENTER,Gfx.screenheightmid + 2, fontcredits[currentfont], Gfx.hsl((currentfont * coloroffset), 0.15, 0.4));  
		}else{
			Text.display(10 - scrollposition,Gfx.screenheightmid + 2, fontcredits[currentfont], Gfx.hsl((currentfont * coloroffset), 0.15, 0.4));
		}
		
		//Update scroller position
		counter++;
		if(scrollposition >= Text.len(fontcredits[currentfont]) - Gfx.screenwidth + 20){
			scrolldelay--;
			if(scrolldelay <= 0){
				scrolldelay = 0;
				scrollposition = 0;
			}
		}else{
			scrolldelay++;
			if(scrolldelay >= 45){
				scrolldelay = 45;
				scrollposition+=2;
			}
		}
	}
	
	function updatestars(){
		for(i in 0 ... numstars){
			starx[i] -= starspeed[i];
			if(starx[i] < -10){    
				starspeed[i] = Random.int(15, 30);
				starx[i] = Gfx.screenwidth;
				stary[i] = Random.int(0, Gfx.screenheight);
			}
		}
	}

	var starcol:Int;
	function drawstars(){
		for(i in 0 ... numstars){
			starcol = Convert.toint(255 - (30 - starspeed[i]) * 10);
			Gfx.fillbox(starx[i], stary[i], 3, 3, Gfx.rgb(starcol, starcol, starcol));
		}
	}
}