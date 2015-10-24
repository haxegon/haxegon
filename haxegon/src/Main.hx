import haxegon.*;

class Main {
	function new(){
	}

	function drawPerson(px:Float,py:Float,params:Dynamic){
		var w:Float = 15*params.weight+10;
		var h:Float = 20*params.height+20;
		var legr:Float = 3+3*params.weight;
		var legheight:Float = 10*params.height+10;
		var legoffset:Float = w/2;
		trace((px - legoffset - legr) + "," + (py + legheight) + "," + legr * 2 + "," + legheight);
		
		Gfx.drawbox(
				px-legoffset-legr,
				py+legheight,
				legr*2,
				legheight,Col.BLUE);
		Gfx.drawbox(
				px+legoffset-legr,
				py+legheight,
				legr*2,
				legheight,Col.BLUE);
}

	function update(){
		var params:Dynamic = {
				hairshade:0.5,//blond-black
				skinshade:0.5,//yellow-black
				hairlength:0.5,//bald - hair
				height:0.5,
				weight:0.5,
				pantscol: 0.5,
				jacketcol: 0.5
		};
		drawPerson(Gfx.screenwidthmid,Gfx.screenheightmid,params);
	}
}