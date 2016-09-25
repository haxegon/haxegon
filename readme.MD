So! **What is going on with Haxegon**?

I've been using some version of Haxegon for my own projects since I first started using Haxe, back in 2014. Everytime I work on something, Haxegon gets a little better.

However, recently I've been very focused on a much bigger project - so Haxegon hasn't been propely updated in a while. It does work if you wanna mess with it, but still pretty far from being at a point where anyone can just pick it up and have a smooth experience with it. 

My current project is leading me in a direction that will require some really fundamental changes to how this framework works, so future updates might make it a little unstable - but it should come out the other side of that faster, more powerful and more portable than it currently is.

- Terry, 25th September 2016

=-=-=-=-=-

<p align="center"><img src="haxegon.png"/></p>
<p align="center"><img src="supportedplatforms.png"/></p>

[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

**Haxegon is a work in progress!** Feel free to give it a whirl, but be warned that some things might change between now and launch... **The documentation is currently very, very out of date, sorry!**

Haxegon is a tiny haxe programming library for beginners. It's made to accompany a beginners game programming tutorial that I'm currently writing.

Haxegon is designed to give you a simple, beginner friendly, uncluttered starting point to game programming. Hello World in Haxegon looks like this:

```haxe
import haxegon.*;

class Main {
	function update() {
	  Text.display(0, 0, "Hello World!");
	}
}
``` 

Here's a *complete* list of what you can do with Haxegon.

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

**Loading Text:**
Easily load in text files!

See reference.txt for a full command list.

For examples, see the included examples folder! Examples are a work in progress - more are on the way!

## Using Haxegon

Haxegon is a Haxe Library, and is built on top of OpenFL. Here is a good starting point for installing Haxe and OpenFL on your machine:

http://www.openfl.org/documentation/getting-started/installing-openfl/

On windows, FlashDevelop is the recommended IDE. 

On Mac, I've made a special compiler tool that comes with the project, TerryCompile. Unzip the "terrycompile.zip" folder into the project you want to complile, then run it! For a code editor on Mac, I'm still figuring out exactly what to recommend. Sublime Text, maybe!

Haxegon can target Flash and Desktop platforms. A HTML5 target is working, but currently has a lot of bugs. iOS and Android targets are possible in future, but are not currently supported.

## Roadmap to 1.0

To do:
 - Work to make HTML5 target stable.
 - Make sure Haxegon gives good error messages in as many places as possible.
 - Finish tutorial and make some examples!
