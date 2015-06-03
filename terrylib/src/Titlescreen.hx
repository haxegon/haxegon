import terrylib.*;

class Titlescreen {
  function update(){
		if (Mouse.leftclick()) {
			Scene.change(Main);
		}
		
		Text.display(0, 0, "Titlescene");
  }
}