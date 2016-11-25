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
		
		checkforrenderfunction();
	}
	
	private static function checkforrenderfunction() {
		//When we change to a scene, check if this class contains a "render" method.
		//If so, allow seperation of update and render
		hasseperaterenderfunction = (Reflect.field(scenelist[currentscene], "render") != null);
		if (!hasseperaterenderfunction) {
		  //Also check for the static function
		  hasseperaterenderfunction = (Reflect.field(Type.getClass(scenelist[currentscene]), "render") != null);
		}
	}
	
	private static function update() {
		callscenemethod(scenelist[currentscene], "update");
	}
	
	private static function render() {
		callscenemethod(scenelist[currentscene], "render");
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
		
		checkforrenderfunction();
		
		return cast scenelist[currentscene];
	}
	
	public static function get<T>(requiredscene:Class<T>):T {
		return cast scenelist[findscene(requiredscene)];
	}
	
	public static function name<T>(requiredscene:Class<T>):String {
		return Type.getClassName(Type.getClass(scenelist[findscene(requiredscene)]));
	}
	
	private static function getcurrentsceneclass():Dynamic {
		return cast scenelist[currentscene];
	}
	
	private static var scenelist:Array<Dynamic>;
	private static var currentscene:Int;
	private static var hasseperaterenderfunction:Bool;
}
