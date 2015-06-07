#TerryLib

Ssshh! TerryLib is a work in progress. Things might change between now and when it gets properly finished, but if you're feeling adventurous, feel free to try it out!

TerryLib is a tiny haxe programming library for beginners. It's made to accompany a beginners game programming tutorial that I'm currently writing.

TerryLib is designed to give you a simple, beginner friendly, uncluttered starting point to game programming. Hello World in TerryLib looks like this:

```haxe
import terrylib.*;

class Main {
	function update() {
	  Text.display(0, 0, "Hello World!");
	}
}
``` 

Here's a *complete* list of what you can do with TerryLib.

**Graphics:** 
Load in images and draw them, draw simple shapes, and divide images into tilesets! Do simple animations!

**Fonts:**
Load in different fonts at different sizes and display them! Take in simple string input!

**Music:**
Load in music and sound effects! Play them back!

**Input:**
Read in Keyboard and Mouse input!

**Scene Control:**
Easily change between different game scenes!

See reference.txt for a full command list.

For examples, see the included examples folder! Examples are a work in progress - more are on the way!

## Using TerryLib

TerryLib is a Haxe Library, and is built on top of OpenFL. Here is a good starting point for installing Haxe and OpenFL on your machine:

http://www.openfl.org/documentation/getting-started/installing-openfl/

On windows, FlashDevelop is the recommended IDE. 

On Mac, I've made a special compiler tool that comes with the project, TerryCompile. Unzip the "terrycompile.zip" folder into the project you want to complile, then run it! For a code editor on Mac, I like Adobe Brackets.

## Roadmap to 1.0

To do:
 - Make sure TerryLib gives good error messages in as many places as possible.
 - Finish tutorial and make some examples!