// Huge huge thanks to Ruari O'Sullivan (@randomnine) for figuring this stuff out for me!
package terrylib;

import openfl.errors.ArgumentError;

class Scene {
	private static function init():Void {
		scenelist = new Array<Dynamic>();
		//var mainFields:Array<String> = Type.getInstanceFields( Main );
		
		scenelist.push(Type.createInstance(Main, []));
		currentscene = 0;
	}
	
	private static function update():Void {
		callscenemethod(scenelist[currentscene], "update");
	}
	
	private static function callscenemethod(scene:Dynamic, method:String):Void {
		var instanceFunc:Dynamic = Reflect.field(scenelist[currentscene], method);
		if (instanceFunc != null && Reflect.isFunction(instanceFunc)) {
			try {
				Reflect.callMethod(scenelist[currentscene], instanceFunc, []);
			} catch ( e:ArgumentError ) {
				throw( "Error: Couldn't call " + Type.getClassName(scene) + "." + method + "() without any arguments");
			}
			return;
		}
		
		// Now try the static method
		var classFunc:Dynamic = Reflect.field(Type.getClass(scenelist[currentscene]), method);
		if (classFunc != null && Reflect.isFunction(classFunc)) {
			try {
				Reflect.callMethod(scenelist[currentscene], classFunc, []);
			} catch ( e:ArgumentError ) {
				throw( "Error: Couldn't call " + Type.getClassName(scene) + "." + method + "() without any arguments");
			}
			return;
		}
		
		// method didn't exist; complain if necessary
	}
	
	public static function change(newscene:Class<Dynamic>):Void {
		for (i in 0 ... scenelist.length) {
			if (newscene == Type.getClass(scenelist[i])) {
				currentscene = i;
				callscenemethod(scenelist[currentscene], "reset");
				return;
			}
		}
		
		scenelist.push(Type.createInstance(newscene, []));
	}
	
	public static function get<T>(newscene:Class<T>):T {
	  for (i in 0 ... scenelist.length) {
			if (newscene == Type.getClass(scenelist[i])) {
				return scenelist[i];
			}
		}
		
		throw("ERROR: Scene has not been created yet!");
	}
	
	private static var scenelist:Array<Dynamic>;
	private static var currentscene:Int;
}