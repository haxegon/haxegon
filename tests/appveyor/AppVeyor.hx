import sys.FileSystem.*;
import haxe.io.*;
import sys.io.*;
import hxcpp.StaticStd;
import hxcpp.StaticZlib;
import hxcpp.StaticRegexp;
using StringTools;

class AppVeyor
{

	public function new()
	{
	}

	static function main()
	{
		Sys.putEnv('PATH', Sys.getEnv('PATH') + ';C:\\HaxeToolkit\\neko;C:\\HaxeToolkit\\haxe');
		Sys.putEnv('HAXEPATH', 'C:\\HaxeToolkit\\haxe');
		Sys.putEnv('NEKO_INSTPATH', 'C:\\HaxeToolkit\\neko');
		switch (Sys.args()[0])
		{
			case 'setup':
				setup();
			case 'build':
				build();
			case 'hxcpp':
				setupHxcpp();
			case 'run':
				var args = Sys.args();
				args.shift();
				var c = args.shift();
				cmd(c,args);
			case 'retry':
				var args = Sys.args();
				args.shift();
				var c = args.shift();
				cmd(c,args,3);
			case 'download':
				var args = Sys.args();
				download(args[1], args[2]);
			case 'untar':
				var args = Sys.args();
				untar(args[1], args[2]);
			case 'test':
				test();
		}
	}

	static function test()
	{
		var targetDir = Sys.getEnv("TARGET_DIR");
		if (targetDir == null)
			targetDir = Sys.getCwd();
		while (true)
		{
			switch (targetDir.charAt(targetDir.length-1))
			{
				case '/' | '\\':
					targetDir = targetDir.substr(0,targetDir.length-1);
				default:
					break;
			}
		}

		var built = Sys.args()[1];
		if (built == '' || built.trim() == '') built = null;
		for (target in Sys.getEnv("TARGET").split(" "))
		{
			switch target
			{
				case 'js':
					var built = built;
					if (built == null) built = '$targetDir/js.js';
					if (Sys.getEnv("NODECMD") != null)
					{
						cmd('node',['-e',Sys.getEnv("NODECMD")]);
					} else {
						cmd('node',[built]);
					}
				case 'neko':
					var built = built;
					if (built == null) built = '$targetDir/neko.n';
					cmd('neko',[built]);
				case 'python':
					var built = built;
					if (built == null) built = '$targetDir/python.py';
					var pcmd = Sys.getEnv("PYTHONCMD");
					if (pcmd == null)
						if (Sys.getEnv("ARCH") == "x86_64")
							pcmd = "C:\\Python34-x64\\python";
						else
							pcmd = "C:\\Python34\\python";
					cmd(pcmd,[built]);
				case 'cpp' | 'cs':
					var built = built;
					if (built == null)
					{
						if (target == 'cpp')
							built = '$targetDir/$target';
						else
							built = '$targetDir/$target/bin';
					}

					var found = false;
					if (isDirectory(built))
					{
						for (file in readDirectory(built))
						{
							if (file.endsWith('.exe'))
							{
								found = true;
								cmd('$built/$file',null);
								break;
							}
						}
						if (!found)
							throw 'File not found at dir $built. Files in there: ${readDirectory(built)}';
						continue;
					}
					cmd(built,[]);
				case 'java':
					var built = built;
					if (built == null) built = '$targetDir/java';
					var found = false;
					if (isDirectory(built))
					{
						for (file in readDirectory(built))
						{
							if (file.endsWith('.jar'))
							{
								found = true;
								if (Sys.getEnv("ARCH") == 'i686' || Sys.getEnv("ARCH") == 'x86')
								{
									var last = Sys.getEnv("PATH");
									Sys.putEnv('PATH','C:\\Program Files (x86)\\Java\\jdk1.7.0\\bin;$last');
									cmd('java',['-jar','$built/$file']);
									Sys.putEnv('PATH',last);
								} else {
									cmd('java',['-jar','$built/$file']);
								}
								break;
							}
						}
						if (!found)
							throw 'File not found at dir $built. Files in there: ${readDirectory(built)}';
						continue;
					}
					cmd('java',['-jar','$built']);
				case 'interp' | 'macro': // do nothing, already tested when building
			}
		}
	}

	static function build()
	{
		var flags = Sys.getEnv("HXFLAGS");
		if (flags == null)
			flags = "";

		var flags = flags.split(' ');
		var targetDir = Sys.getEnv("TARGET_DIR");
		if (targetDir == null)
			targetDir = Sys.getCwd();
		for (target in Sys.getEnv("TARGET").split(" "))
		{
			if (target == 'cpp' || target == 'cs' || target == 'java')
			{
				var targetDir = targetDir + '/' + target;
				if (exists(targetDir))
				{
					for (file in readDirectory(targetDir))
					{
						if (!isDirectory(targetDir + '/' + file))
						{
							try
							{
								deleteFile(targetDir + '/' + file);
							}
							catch(e:Dynamic) {}
						}
					}
				}
			}
			var extra = Sys.getEnv("HXFLAGS_EXTRA");
			if (extra == null)
				extra = switch target
				{
					case 'neko':
						'-neko $targetDir/neko.n';
					case 'python':
						'-python $targetDir/python.py';
					case 'js':
						'-js $targetDir/js.js -D nodejs';
					case 'cpp' if(Sys.getEnv("ARCH") == "x86_64"):
						'-D HXCPP_M64 -cpp $targetDir/$target';
					case 'cs' if(Sys.getEnv("ARCH") == "x86" || Sys.getEnv("ARCH") == "i686"):
						'-D arch=x86 -cs $targetDir/$target';
					case 'cpp' |'java' | 'cs':
						'-$target $targetDir/$target';
					case 'interp':
						'--interp';
					case 'macro':
						Sys.getEnv("MACROFLAGS") == null ? "" : Sys.getEnv("MACROFLAGS");
					case _:
						trace("unkown target ", target);
						null;
				};
			if (extra != null)
				cmd('haxe',flags.concat(extra.split(' ')));
		}
	}

	static function setupHxcpp()
	{
		cmd('haxelib', ['git','hxcpp','https://github.com/HaxeFoundation/hxcpp'],3);
		cd('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\tools\\hxcpp');
		cmd('haxe',['compile.hxml']);
		cd('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\project');
		if (Sys.getEnv("ARCH") == "x86_64")
		{
			cmd('haxelib',['run','hxcpp','Build.xml','-Dwindows','-DHXCPP_M64','-Dstatic_link']);
			cmd('haxelib',['run','hxcpp','Build.xml','-Dwindows','-DHXCPP_M64']);
			mkdir('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\bin\\Windows');
			mkdir('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\lib\\Windows');
			for (file in readDirectory('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\bin\\Windows64'))
				copy('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\bin\\Windows64\\$file','C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\bin\\Windows\\$file');
			for (file in readDirectory('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\lib\\Windows64'))
				copy('C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\lib\\Windows64\\$file','C:\\HaxeToolkit\\haxe\\lib\\hxcpp\\git\\lib\\Windows\\$file');
		} else {
			cmd('neko', ['build.n']);
		}
	}

	private static function copy(from:String,to:String)
	{
		sys.io.File.saveBytes(to,sys.io.File.getBytes(from));
	}

	private static function mkdir(dir:String)
	{
		if (!exists(dir)) createDirectory(dir);
	}

	static function setup()
	{
		var toolkit = "C:\\HaxeToolkit";
		createDirectory('C:\\HaxeToolkit');
		// download neko
		download('http://waneck-pub.s3-website-us-east-1.amazonaws.com/unitdeps/neko-latest-win.tar.gz', '$toolkit/neko.tar.gz');
		untar('$toolkit/neko.tar.gz', '$toolkit');
		for (file in readDirectory(toolkit))
		{
			if (file.startsWith('neko') && isDirectory('$toolkit/$file'))
			{
				rename('$toolkit/$file', '$toolkit/neko');
				break;
			}
		}

		// download haxe
		trace('download haxe');
		download('http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/windows/haxe_latest.tar.gz', '$toolkit/haxe.tar.gz');
		untar('$toolkit/haxe.tar.gz', '$toolkit');
		for (file in readDirectory(toolkit))
		{
			if (file.startsWith('haxe') && isDirectory('$toolkit/$file'))
			{
				rename('$toolkit/$file', '$toolkit/haxe');
				break;
			}
		}

		trace('setup haxelib');
		// setup haxelib
		createDirectory('$toolkit/haxe/lib');
		cmd('haxelib',['setup','$toolkit/haxe/lib']);

		cmd('haxe',[]); //check if it's installed correctly
		cmd('neko',['-version']);
		trace('configuring target');
		for (target in Sys.getEnv("TARGET").split(" "))
		{
			switch target
			{
				case 'cpp':
					setupHxcpp();
				case 'cs':
					cmd('haxelib', ['git','hxcs','https://github.com/HaxeFoundation/hxcs'],3);
				case 'java':
					cmd('haxelib', ['git','hxjava','https://github.com/HaxeFoundation/hxjava'],3);
					cmd('javac',['-version']);
			}
		}
	}

	static function download(url:String,target:String,?retry=3)
	{
		trace('[$retry]','download',url,target);
		do
		{
			var req = new haxe.Http(url);
			var err = null;
			req.onError = function(msg) err = msg;
			var out = sys.io.File.write(target);
			req.customRequest(false, out);
			out.close();
			if (err != null && retry <= 0)
				throw 'Cannot download $url : $err';
		} while (retry-- > 0);
	}

	static function untar(filename:String, target:String)
	{
		trace('untar',filename,target);
		var file = sys.io.File.read(filename);
		var gz = new format.gz.Reader(file);
		var out = new BytesOutput();
		gz.readHeader();
		gz.readData(out);
		var tar = new format.tar.Reader(new BytesInput(out.getBytes()));
		for (entry in tar.read())
		{
			createDirectory(target + '/' + Path.directory(entry.fileName));
			// trace(entry.fileName,entry.data.length,entry.fileSize);
			if (entry.data != null && entry.data.length > 0 && entry.fileSize > 0)
			{
				File.saveBytes( target + '/' + entry.fileName, entry.data );
			}
		}
	}

	static function cd(dir:String)
	{
		trace('cd',dir);
		Sys.setCwd(dir);
	}

	static function cmd(cmd:String,args:Array<String>,retry=0,throwOnError=true)
	{
		trace('[$retry,$throwOnError]',cmd,args == null ? "" :args.join(" "));
		if (cmd.startsWith('haxe'))
		{
			cmd = 'C:\\HaxeToolkit\\haxe\\' + cmd;
		} else if (cmd.startsWith('neko')) {
			cmd = 'C:\\HaxeToolkit\\neko\\' + cmd;
		}
		var ret = -1;
		do
		{
			ret = Sys.command(cmd,args);
			if (ret == 0 || ret < 0)
			{
				return 0;
			}
		} while(retry-- > 0);
		if (throwOnError)
			throw '$cmd response: $ret';
		return ret;
	}

}
