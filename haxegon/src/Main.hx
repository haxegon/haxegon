import haxegon.*;

class Main {
	function new() {
	}
	
	var textwidth:Int = 400;
	
	function update(){
		Text.changesize(16);
		Text.display(0, 0, "Word wrap example!");
		
		Text.changesize(12);
		Text.wordwrap(textwidth);
		
		var bigtext:String = "What is Lorem Ipsum? Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
		Gfx.fillbox(18, 38, textwidth + 4, 4 + Text.height(bigtext), Col.DARKBLUE);
		Text.display(20, 40, bigtext);
		
		if (Input.pressed(Key.LEFT)) {
		  textwidth -= 5;	
		}else if (Input.pressed(Key.RIGHT)) {
		  textwidth += 5;	
		}
		
		Text.wordwrap();
	}
}