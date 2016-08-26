// Huge huge thanks to Ruari O'Sullivan (@randomnine) for figuring this stuff out for me!
#if !haxegonweb
package haxegon;

import openfl.errors.ArgumentError;

class Scene {
	private static function init() {
		scenelist = new Array<Dynamic>();
		currentscene = 0;
		#if neko
		  try{
		    scenelist.push(Type.createInstance(Main, []));
			}catch (e:Dynamic) {
				throw("ERROR: Neko builds require that Main.hx has a \"new()\" function.");
			}
		#else
		  scenelist.push(Type.createInstance(Main, []));
		#end
	}
	
	private static function update() {
		callscenemethod(scenelist[currentscene], "update");
	}
	
	private static function callscenemethod(scene:Dynamic, method:String) {
		var instanceFunc:Dynamic = Reflect.field(scenelist[currentscene], method);
		if (instanceFunc != null && Reflect.isFunction(instanceFunc)) {
			try {
				Reflect.callMethod(scenelist[currentscene], instanceFunc, []);
			} catch ( e:ArgumentError ) {
				throw( "ERROR: Couldn't call " + Type.getClassName(scene) + "." + method + "() without any arguments.");
			}
			return;
		}
		
		// Now try the static method
		var classFunc:Dynamic = Reflect.field(Type.getClass(scenelist[currentscene]), method);
		if (classFunc != null && Reflect.isFunction(classFunc)) {
			try {
				Reflect.callMethod(scenelist[currentscene], classFunc, []);
			} catch ( e:ArgumentError ) {
				throw( "ERROR: Couldn't call " + Type.getClassName(scene) + "." + method + "() without any arguments.");
			}
			return;
		}
		
		// method didn't exist; complain if necessary
	}
	
	public static function findscene<T>(findscene:Class<T>):Int {
		for (i in 0 ... scenelist.length) {
			if (findscene == Type.getClass(scenelist[i])) {
				return i;
			}
		}
		
		#if neko
			try{
				scenelist.push(Type.createInstance(findscene, []));
			}catch (e:Dynamic) {
				throw("ERROR: Neko builds require all classes to have a \"new()\" function.");
			}
		#else
			scenelist.push(Type.createInstance(findscene, []));
		#end
		
		return scenelist.length - 1;
	}
	
	public static function change<T>(newscene:Class<T>):T {
		currentscene = findscene(newscene);
		callscenemethod(scenelist[currentscene], "reset");
		return cast scenelist[currentscene];
	}
	
	public static function get<T>(newscene:Class<T>):T {
		return cast scenelist[findscene(newscene)];
	}
	
	public static function getcurrentscene():String {
		return Type.getClassName(Type.getClass(scenelist[currentscene]));
	}
	
	public static function getcurrentsceneclass():Dynamic {
		return cast scenelist[currentscene];
	}
	
	private static var scenelist:Array<Dynamic>;
	private static var currentscene:Int;
}

#end