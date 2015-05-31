#TerryLib

Ssshh! TerryLib is a work in progress. Things might change between now and when it gets properly finished, but if you're feeling adventureous, feel free to try it out!

TerryLib is a tiny haxe programming library for beginners. It's made to accompany a beginners game programming tutorial that I'm currently writing.

TerryLib is designed to give you a simple, beginner friendly, uncluttered starting point to game programming. Hello World in TerryLib looks like this:

```haxe
import terrylib.*;

class Main {
	function new() {
	
	}
	
	function update() {
	  Text.print(0, 0, "Hello World!");
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

See reference.txt for a full command list.

There are no official examples available yet, but there should be some soon! Increpare has made some simple games with this which are open source, available here:

http://www.increpare.com/2015/05/night/
http://www.increpare.com/2015/05/body-paint/
http://www.increpare.com/2015/05/hair-game/

## Using TerryLib

TerryLib is a Haxe Library, and is built on top of OpenFL. Here is a good starting point for installing Haxe and OpenFL on your machine:

http://www.openfl.org/documentation/getting-started/installing-openfl/

## Roadmap to 1.0

To do:
 - Also do proper tinting
 - Make sure TerryLib gives good error messages in as many places as possible.
 - Finish tutorial and make some examples!