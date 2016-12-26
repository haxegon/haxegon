[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.5.0 (2016-12-26))

Haxegon is a tiny haxe programming library aimed at beginners. It's currently in alpha, so things are changing fast and stuff might be broken. Haxegon uses haxe to compile natively to make games for **html5**, **desktop** and **Flash/AIR**.

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

0.5.0 (2016-12-26)
------------------
### New features
* Native targets now work! As Haxegon now works on all of its target plaforms (HTML5, Native and Flash/AIR), I've dropped the *-alpha* tag from the version number. Exciting! Things are still pretty unstable and will be until 1.0.0, but the library is now at a point where it's basically useable.
* Added new functions to Data for loading and saving key/value pairs:
``` haxe
  Data.save(key, value);             //e.g. Data.save("highscore", highscore);
  Data.load(key);                    //e.g. highscore = Data.load("highscore");
  Data.savefile = "mygame_slot1";    //Sets a name for your savefile (optional! default is "haxegongame".)
  Data.deletesave(filename:String);  //Delete a save file (leaving parameter blank deletes the default)
  ```
  
### Bug fixes/Tweaks
* Asset loading doesn't care about being case sensitive anymore.
* Fixed bug where HTML5 build always displayed a fullscreen warning at startup.
* General library cleanups.

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
