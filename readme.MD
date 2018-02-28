# Haxegon (version 0.12.0 (2018-02-28))

Haxegon is a tiny haxe programming library aimed at beginners. Haxegon is starting to get pretty stable, so you can expect the API not to change too much more before 1.0!

The current update, 0.12.0, focuses on **plugin support** and **structure**. The next update, 0.13.0, will focus on **documentation**.

Haxegon compiles natively to **HTML5** and **Desktop** (Win, Mac, Linux). **Flash** is also supported as a legacy/development platform.

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. You can also extend Haxegon with <a href="http://www.haxegon.com/plugins/">plugins, available here</a>.  More coming soon!

# Last Updates

0.12.0 (2018-02-28)
------------------

### Migrating to 0.12.0 from older versions of Haxegon

This update was focused on making some final calls about the structure of the library. From here on out, you can expect Haxegon's API to stay pretty stable!
 
Here are the main things you'll need to change to migrate to 0.12.0:
  * Download the new <a href="https://github.com/haxegon/haxegon/raw/master/blankproject.zip">blankproject.zip</a> file, and copy your project source and data files into the new folder. This should hopefully be the last time the project file changes. Make sure you have a *plugin/* folder after you do this!
  * `Text.align` is now a variable instead of a function, so change `Text.align(Text.CENTER)` to `Text.align = Text.CENTER`.
  * The `offset` parameter of `Music.play()` and `Sound.play()` has been moved, so you should check that you have the parameters in the right order.
 
### New features
 * Haxegon now supports a **plugin** system, inspired by OpenFrameworks! Plugins allow you to expand the funtionality of Haxegon. There are three available right now (keep an eye on <a href="http://www.haxegon.com/plugins/">http://www.haxegon.com/plugins/</a> for an up to date list.) The three initial plugins:
   * <a href="https://github.com/haxegon/plugin_layers">Layers</a>: A simplified display list. 
   * <a href="https://github.com/haxegon/plugin_filters">Filters</a>: A fullscreen post-processing shader plugin.  
   * <a href="https://github.com/haxegon/plugin_imgui">imGui</a>: A simple imgui library.
   
 * The <a href="https://github.com/haxegon/haxegon/raw/master/blankproject.zip">blankproject.zip</a> file has been updated again, hopefully for the last time! Updating <a href="https://github.com/haxegon/haxegon/raw/master/blankproject.zip">blankproject.zip</a> to the latest version is required to support **plugins**.
 * Haxegon is now an organisation on github! See <a href="http://github.com/haxegon/">http://github.com/haxegon/</a> for all related Haxegon plugins and projects.
 * Haxegon is now licenced under <a href="https://github.com/haxegon/haxegon/blob/master/LICENSE">the MIT licence</a>.
 * Haxegon now uses *.mp3* files for all browsers in HTML5. *.ogg* files are no longer required for HTML builds (though they're still required for Native builds for the time being). Alternatively, *.wav* files work on all platforms.
 * Haxegon can now read **JSON** and **XML** files! They're loaded from the *data/text/* directory, same as TXT and CSV files. Check out the new <a href="https://github.com/haxegon/haxegon-samples/tree/master/simple/09%20-%20json%20and%20xml%20loading">JSON and XML parsing</a> to see how to parse them.
 * `Text.align` is now a variable instead of a function. Instead of `Text.align(Text.CENTER)`, you type `Text.align = Text.CENTER`. (This means it's now possible to check the current Text alignment.)
 * You can read all inputted keys from the new `Text.inputbuffer` String. This is basically a low level version of the `Text.input()` system for if you want to do something fancy.
 * Removed `Gfx.keeppixelratio`. As a replacement, `Gfx.resizescreen(w, h)` has been changed to `Gfx.resizescreen(w, h[, keeppixelratio])`.
 * Added `Gfx.onwindowresized()`, which is `true` when the window has been resized this frame.
 * Haxegon's random number generator has been replaced with an implementation of Xorshift, which should mean that it gives better results than the old system, and gives predictible results for any given seed on every target platform.
 * You can now use string based seeds for `Random.seed`, in addition to numbers. e.g. `Random.seed = "winter"`, `Random.seed = 1234;` both work.
 * Added a new function, `Random.weighted([options], [odds])` - inspired by <a href="http://chancejs.com/#weighted">chance.js</a>.
 * Removed `offsettime` as a variable from `Sound` and `Music` functions.
 * Added `volume` as a parameter to `Sound.play()`.
 * Added all previous haxe `Math` function to `Geom`. They're exactly the same, except they use degrees instead of radians. Haxegon now uses degrees everywhere. (e.g. You can call `Geom.sin()` instead of `Math.sin()`)
 * The `Filters` class has been removed. `Filters` is now a plugin, and has several new settings: https://github.com/haxegon/plugin_filters
 * Added `Core.version`.

### Bug fixes/Tweaks
 * Fixed a bug where `Convert.toint()` could give an incorrect value for large negative numbers.
 * Fixed a situational crash bug with changing `Gfx.drawto()` targets in `update()` functions.
 * Fixed a crash bug where Haxegon would crash on some platforms if `Gfx.drawimage()` or `Gfx.drawtile()` draw an image or tile that doesn't exist.
 * Fixed a bug with `Gfx.linethickness`.
 * Fixed a crash bug on HTML5 when trying to display arrays with `Text.display()`.
 * Haxegon now releases all keypresses when it loses focus (thanks @randomnine)
 * Removed the old Ctrl + Click behavior for Flash to simulate a right click.
 * Haxegon uses "top left" as the default pivot point for all scales and rotations now.
 * Removed `Scene.get()`. It encouraged bad behaviour that probably doesn't reliably work anyway (i.e. non static scene classes).
 * Removed `Scene.name`. (same reason)

0.11.1 (2018-01-17)
------------------

### Bug fixes/Tweaks
* This is a minor bugfix release for yesterday's big update.
* Updated to work correctly with the newest versions of OpenFL and Lime (OpenFL 7.0 and Lime 6.0.1).
* Fixed `Debug.log()` not displaying if you don't have a render function.
* Fixed a crash bug if you changed drawing surfaces in `Main.init()` AFTER resizing the screen.
* Fixed a bug where the wrong screensize was getting reported in `Main.init()` on HTML5. (thanks, @TheSpydog)

0.11.0 (2018-01-16)
------------------

### New features
* This is the biggest update to Haxegon in more than a year! This update will probably break compatibility with your older haxegon projects. I recommend starting over with a new <a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a> folder, and transferring your assets and source code across. The main things to watch out for are the new data/ folder structure, and changes to Music/Sound.
* Haxegon has been updated to work with ~~OpenFL 7.0~~ and Starling 2.0.
* The project structure has changed. There is a new `project.xml` file for haxegon projects, and a `data/` folder with a new, flatter, simpler layout. Grab the new <a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a> file to get started. The data folder inside contains a guide for adding assets to your haxegon project.
* `Gfx.resizescreen(width, height)` has had an upgrade, and is now a lot more flexible. The following settings are now possible:
``` haxe
  //Create a 640x360 pixel screen, which is streched and letterboxed to the current window.
  Gfx.resizescreen(640, 360);
  
  //Create a screen which MATCHES the current window size. When the window size changes,
  //update Gfx.screenwidth and Gfx.screenheight to the new values.
  Gfx.resizescreen(0, 0);
  
  //Create a dynamic screen of height 360, but with a floating width that matches the scale
  //of the current window and updates Gfx.screenwidth to match:
  Gfx.resizescreen(0, 360);
  
  //Create a dynamic screen of width 640, but with a floating height that matches the scale
  //of the current window and updates Gfx.screenheight to match:
  Gfx.resizescreen(640, 0);
```
* Setting `Gfx.keeppixelratio` to **true** tells haxegon to keep a 1:1 pixel ratio when stretching the screen to fit a window, even if this creates black bars on all sides. Possibly good for very low resolution games!
* `Text.input()` is now a little simplier:
``` haxe
  if(Text.input(x, y)){
    trace(Text.inputresult);
  }
```
* Added support for **.wav** files.
* There's a brand new music engine in Haxegon rewritten from scratch. It's now possible to crossfade music, layer multiple looping sounds, control the panning of each sound, as well as lots of other cool complex stuff that wasn't possible before.
``` haxe
  //Play an explosion sound effect.
  Sound.play("explosion");
  
  //Stop all sound effects:
  Sound.stop();
  
  //Stop only the "explosion" sound effects, and fade them out over 0.2 seconds:
  Sound.stop("explosion", 0.2);
  
  //Play the "backgroundtheme".
  Music.play("backgroundtheme");
  
  //Play the "backgroundtheme", but fade in over 3 seconds.
  Music.play("backgroundtheme", 0, 3.0);
  
  //Stop the music, fading out over 3 seconds.
  Music.stop(3);
  
  //Set the position of the current song to 15 and a half seconds in:
  Music.currentposition = 15.5;
```
* Replaced `Data.blank2darray(w, h)` with `Data.create2darray(w, h, defaultvalue)`, and made the function work correctly for all types - Ints, Strings, Bools, custom classes, whatever.
* Added `Scene.restart(Myscene)`, which discards and reloads a named scene.


### Bug fixes/Tweaks
* The default window size has been changed to a **720p** friendly **1280x720**.
* On native platforms, on dual Nvidia/Intel devices, Haxegon will now use your Nvidia card instead of your integrated intel one. 
* Removed `Core` extension functions. They still exist, but now require `@:access(haxegon.Core)` at the start of your class to discourage unnecessary use.
* Haxegon now works correctly on high dpi devices.
* `Filter.blur` is now a **Float** instead of a **Bool**, and supports different degrees of bluriness.
* Speed improvements to `Gfx.getpixel()`.
* Re-added `Text.setfont(font, size)` to allow you to change font and size at the same time.
* Right click context menu is disabled in HTML5.
* Added an `Input.getkeyfromcharacter()` function as a reverse of `Input.getchar()`.
* `Text.typingsound` lets you associate a sound effect with typing.
* Fixed alignment on text rotations.
* Lots and lots of other long running tiny bugs fixed.

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
