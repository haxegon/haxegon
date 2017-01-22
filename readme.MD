[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.7.0 (2017-01-22))

Haxegon is a tiny haxe programming library aimed at beginners. It's currently in alpha, so things are changing fast and stuff might be broken. 

Haxegon compiles natively to **HTML5**, **Desktop** (Win, Mac) and **Flash/AIR**. (Linux support is currently broken, but <a href="https://github.com/openfl/starling/issues/38">is being worked on!</a>)

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

0.7.0 (2017-01-22)
------------------
### New features
* Added a new simple example to the <a href="https://github.com/TerryCavanagh/haxegon-samples">haxegon-samples</a> repo: **Truetype Fonts**.
* Added `Core.delaycall(f:Function, time:Float)`, which calls a function after a specified number of seconds. E.g.
``` haxe
trace("go!");
Core.delaycall(callmelater, 2.5);

function callmelater(){
  trace("two and half seconds have passed!");
}
```
* Added a couple of useful helper functions in a new Help class. (Suggestions for a better class name welcome!)
``` haxe
  Help.inbox(x, y, rectx, recty, rectw, recth);  //True if point (x, y) is in rectangle
  Help.overlap(x1, y1, w1, h1, x2, y2, w2, h2);  //True if rectangles overlap
  Help.distance(x1, y1, x2, y2);                 //Distance in pixels between two points
  Help.getangle(x1, y1, x2, y2);                 //Angle [0-360] between two points
  Help.clamp(value, min, max);                   //Clamps a value between [min, max]
  ```
* Added `Mouse.deltax` and `Mouse.deltay`, which return the change in mouse position since the last frame.

### Bug fixes/Tweaks
* Removed `Mouse.previousx` and `Mouse.previousy`.
* Passing no arguments to `Input.forcerelease()` releases all keys currently being held.
* Sped up `Data.loadtext()` on native targets.
* Sped up bitmap font rendering (using starling QuadBatches).
* Improvements to drawtile quadbatching. 

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
