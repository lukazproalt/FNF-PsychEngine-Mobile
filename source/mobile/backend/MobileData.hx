package mobile.backend;

import haxe.ds.Map;
import tjson.TJSON as Json;
import haxe.io.Path;
import openfl.utils.Assets;

class MobileData
{
	public static var actionModes:Map<String, VirtualPadButtonsData> = new Map();
	public static var dpadModes:Map<String, VirtualPadButtonsData> = new Map();
	public static var extraActions:Map<String, ExtraActions> = new Map();

	public static function init()
	{
		readDirectory(Paths.getSharedPath('mobile/DPadModes'), dpadModes);
		readDirectory(Paths.getSharedPath('mobile/ActionModes'), actionModes);
		#if MODS_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'mobile/'))
		{
			readDirectory(Path.join([folder, 'DPadModes']), dpadModes);
			readDirectory(Path.join([folder, 'ActionModes']), actionModes);
		}
		#end

		for (data in ExtraActions.createAll())
			extraActions.set(data.getName(), data);
	}

	public static function readDirectory(folder:String, map:Dynamic)
	{
		#if MODS_ALLOWED if(FileSystem.exists(folder)) #end
			for (file in Paths.readDirectory(folder))
			{
				var fileWithNoLib:String = file.contains(':') ? file.split(':')[1]) : file;
				if (Path.extension(fileWithNoLib) == 'json')
				{
				 	#if MODS_ALLOWED file = Path.join([folder, Path.withoutDirectory(file)]); #end
					var str = #if MODS_ALLOWED File.getContent(file) #else Assets.getText(file) #end;
					var json:VirtualPadButtonsData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(fileWithNoLib));
					trace(mapKey);
					map.set(mapKey, json);
				}
			}
	}
}

typedef VirtualPadButtonsData =
{
	buttons:Array<ButtonsData>
}

typedef ButtonsData =
{
	button:String, // what FlxButton should be used, must be a valid FlxButton var from FlxVirtualPad as a string.
	graphic:String, // the graphic of the button, usually can be located in the VirtualPad xml .
	x:Float, // the button's X position on screen.
	y:Float, // the button's Y position on screen.
	width:Int, // the button's width, default value is 132.
	height:Int, // the button's height, default value is 127.
	color:String // the button color, default color is white.
}

enum ExtraActions
{
	SINGLE;
	DOUBLE;
	NONE;
}
