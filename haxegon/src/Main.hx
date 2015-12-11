import haxegon.*;

class Main {
	function new() {
	}

	function inbox(x, y, boxx, boxy, boxw, boxh){
		if(x >= boxx && x < boxx + boxw){
			if(y >= boxy && y < boxy + boxh){
				return true;
			}
		}
		return false;
	}

	function update(){
		Gfx.drawbox(50, 50, 25, 25, Col.WHITE);
		if(inbox(Mouse.x, Mouse.y, 50, 50, 25, 25)){
			Gfx.fillbox(50, 50, 25, 25, Col.RED);
		}
	}
}