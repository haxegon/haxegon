package haxegon;

import openfl.display.*;
import openfl.events.Event;
import starling.core.Starling;

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