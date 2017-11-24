package haxegon;

import openfl.display.*;
import openfl.events.Event;
import starling.core.Starling;

@:cppFileCode('
#if defined(HX_WINDOWS)
   extern "C" {
      _declspec(dllexport) unsigned long NvOptimusEnablement = 0x00000001;
      _declspec(dllexport) int AmdPowerXpressRequestHighPerformance = 1;
   }
   #endif
')

@:access(haxegon.Core)
@:keep class Load extends Sprite{
	var starling:Starling;
	
	public function new () {
		super();
		
		if (stage != null) start();
		else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(event:Dynamic) {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		start();
	}
	
	private function start() {
		starling = new Starling(Core, stage);
    starling.start();
	}
}