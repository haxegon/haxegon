import terrylib.*;

class Main {
	var soundlist:Array<String>;
	var currentsoundeffect:Int;
	var songplaying:Bool;
	
	// new() is a special function that is called on startup.
	function new() {
		//Load in a background image
		Gfx.loadimage("dontlookback");
		
		//Initilise the array"
		soundlist = [];
		//Push sound effect names into the array
		soundlist.push("baddie_hurt");
		soundlist.push("big1");
		soundlist.push("big2");
		soundlist.push("cdie");
		soundlist.push("cgrowl");
		soundlist.push("cgrowl2");
		soundlist.push("cgrowl3");
		soundlist.push("eurydie");
		soundlist.push("euryfind");
		soundlist.push("fireball");
		soundlist.push("gunshot");
		soundlist.push("hadesdie");
		soundlist.push("hadeshurt");
		soundlist.push("hadesintro");
		soundlist.push("land_echo");
		soundlist.push("land_hard");
		soundlist.push("land_soft");
		soundlist.push("land_veryhard");
		soundlist.push("ledge");
		soundlist.push("nogo");
		soundlist.push("restart");
		soundlist.push("roar");
		soundlist.push("run_echo");
		soundlist.push("run_hard");
		soundlist.push("run_soft");
		soundlist.push("snakedie");
		soundlist.push("snakehiss");
		soundlist.push("stalic");
		
		//Load in all the sounds with the names we just added to the array.
		for (i in 0 ... soundlist.length) {
			Music.addsound(soundlist[i]);
		}
		
		currentsoundeffect = 0;
		
		//Load in a song.
		Music.addsong("ascent_chiptune");
		
		//Play the song!
		Music.play("ascent_chiptune");
		songplaying = true;
	}
	
  function update() {
		//Take input, change the current sound when you press left and right.
		if (Input.justpressed(Key.LEFT)) {
			currentsoundeffect--;
			if (currentsoundeffect < 0) {
				currentsoundeffect = currentsoundeffect + soundlist.length;
			}
		}else if (Input.justpressed(Key.RIGHT)) {
			currentsoundeffect++;
			if (currentsoundeffect >= soundlist.length) {
				currentsoundeffect = currentsoundeffect - soundlist.length;
			}
		}
		
		//Play the current sound effect when you press space.
		if (Input.justpressed(Key.SPACE)) {
			Music.playsound(soundlist[currentsoundeffect]);
		}
		
		//Stop and start the song when you press enter.
		if (Input.justpressed(Key.ENTER)) {
			if (songplaying) {
				Music.stop();
				songplaying = false;
			}else {
				Music.play("ascent_chiptune");
				songplaying = true;
			}
		}
		
		//Draw the background image
		Gfx.drawimage(0, 0, "dontlookback");
		
		//Display some text showing the song that's playing, and the current sound effect.
		Text.changesize(16);
		if (songplaying) {
		  Text.display(Gfx.screenwidth - 10, 5, "[NOW PLAYING] Don't Look Back: Ascent (Chiptune version)", 0xf19599, { rightalign: true } );	
			Text.display(Gfx.screenwidth - 10, 25, "Press ENTER to stop.", 0xf19599, { rightalign: true } );
		}else {
			Text.display(Gfx.screenwidth - 10, 5, "[STOPPED] Don't Look Back: Ascent (Chiptune version)", 0xf19599, { rightalign: true } );	
			Text.display(Gfx.screenwidth - 10, 25, "Press ENTER to restart.", 0xf19599, { rightalign: true } );
		}
		
		Text.display(10, 5, (currentsoundeffect + 1) + ": \"" + soundlist[currentsoundeffect]+ "\"", 0xf19599);	
		Text.display(10, 25, "Press LEFT and RIGHT to change.", 0xf19599);
		Text.display(10, 45, "Press SPACE to play.", 0xf19599);
  }
}