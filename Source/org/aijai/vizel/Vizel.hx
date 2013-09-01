package org.aijai.vizel;
using org.aijai.vizel.utils.VizelString;
import org.aijai.vizel.modules.AssetFilter;
import org.aijai.vizel.modules.LineReader;

enum VizelCommands
{
	CreateObject(id:String);
	SetGraphic(id:String, asset:String);
	SetPivot(id:String, x:Float, y:Float);
	SetPosition(id:String, x:Float, y:Float);
	FadeIn(id:String);
	FadeOut(id:String);
	ClearAll;
	ChangeScript(asset:String);
	Hide(id:String);
	Pass;
	EOF;
	SetOptions(options:Array<String>);
	Wait(seconds:Float);
	WaitForInput;
	SetSpeaker(name:String);
	ClearSpeaker;
	SetDialogue(dialog:String);
	VoiceOver;
	Speak;
	Narration;
	SFX;
	LineNumber(ln:Int);
}

/**
 * ...
 * @author Pekka Heikkinen
 */
class Vizel
{
	/**
	 * An iterable containing lines from the script. Returns LineType enums.
	 */
	public var lineReader:Iterable<LineType>;
	/**
	 * An object that provides asset suggestions based on keywords.
	 */
	public var assetFilter:IAssetFilter;
	/**
	 * Map of name pairs that tells if the name used in the script should be replaced with another form of spelling.
	 */
	public var actorNames:Map<String, String>;
	/**
	 * Storage referencing past events and storing new ones
	 */
	public var history:Map<String, Bool>;
	
	private static inline var BackgroundID:String = "_VizelBackground_";
	private var objects:Map<String, Bool>;
	private var actors:Map<String, String>;
	
	public function new() 
	{
		objects = new Map<String, Bool>();
		actors = new Map<String, String>();
		actorNames = new Map<String, String>();
		history = new Map<String, Bool>();
		dialogueCache = [];
		optionCache = new Map<String, String>();
		optionFlag = false;
		activeCondition = true;
	}
	
	public function setOption(str:String):Void
	{
		history.set(optionCache.get(str), true);
		optionCache = new Map<String, String>();
		optionFlag = false;
	}
	
	public function iterator():Iterator<Array<VizelCommands>>
	{
		return this;
	}
	
	public function hasNext():Bool
	{
		return lineReader.iterator().hasNext();
	}
	
	private var dialogueCache:Array<String>;
	private var optionCache:Map<String, String>;
	private var optionFlag:Bool;
	private var activeCondition:Bool;
	
	public function next():Array<VizelCommands>
	{
		var commands:Array<VizelCommands> = [];
		var line:LineType = lineReader.iterator().next();
		if (activeCondition == false)
		{
			switch(line)
			{
				case CONDITION(source, position):
					if (source == "OPT.")
					{
						activeCondition = true;
						if(hasNext()) commands = commands.concat(next());
					}
					else
					{
						activeCondition = history.exists(source.substring(5));
					}
				default: null;
			}
		}
		else
		{
			switch(line)
			{
				case SCRIPT(source, position):
					commands.push(ChangeScript(assetFilter.getScript(source.collectKeywords())));
				case CONDITION(source, position):
					if (source == "OPT.")
					{
						activeCondition = true;
						if(hasNext()) commands = commands.concat(next());
					}
					else
					{
						activeCondition = history.exists(source.substring(5));
					}
				case LOCATION(source, position):
					commands = commands.concat(changeLocation(source, position));
				case ACTOR(source, position):
					commands = commands.concat(changeActor(source, position));
					commands = commands.concat(next());
				case DIALOGUE(source, position):
					dialogueCache.push(source);
				case OPTION(source, position):
					var options:Array<String> = source.split(" > ");
					if (options.length == 1) options.push(source);
					optionCache.set(options[0], options[1]);
					optionFlag = true;
				case EMPTY(source, position):
					if (dialogueCache.length != 0)
					{
						if (currentActor != "NARRATION" && currentActor != "SFX")
						{
							commands.push(SetSpeaker((actorNames.exists(currentActor) ? actorNames.get(currentActor) : currentActor)));
						}
						commands.push(SetDialogue(dialogueCache.join("/n")));
						dialogueCache = [];
					}
					if (optionFlag)
					{
						var textOnly:Array<String> = [];
						for (key in optionCache.keys())
						{
							textOnly.push(key);
						}
						commands.push(SetOptions(textOnly));
					}
				default: //Do Nothing;
			}
		}
		
		if (commands.length == 0 && hasNext())
		{
			commands = commands.concat(next());
		}
		
		return commands;
	}
	
	
	private var currentActor:String = "NARRATION";
	private function changeActor(source:String, position:Int):Array<VizelCommands>
	{
		var commands:Array<VizelCommands> = [];
		var firstSpaceCharacter:Int = source.indexOf(" ");
		
		if (firstSpaceCharacter != -1) currentActor = source.substring(0, firstSpaceCharacter);
		else currentActor = source;
		
		if (currentActor == "NARRATION")
		{
			commands.push(Narration);
		}
		else if (currentActor == "SFX")
		{
			commands.push(SFX);
		}
		else
		{
			if (!objects.exists(currentActor))
			{
				commands.push(CreateObject(currentActor));
				commands.push(SetPivot(currentActor, 0.5, 1));
				objects.set(currentActor, true);
			}
			commands.push(SetGraphic(currentActor, assetFilter.getActor(source.collectKeywords())));
			
			var voiceOverExpr:EReg = ~/\WVO\W/;
			if (voiceOverExpr.match(source))
			{
				commands.push(VoiceOver);
			}
			else
			{
				commands.push(Speak);
			}
		}
		
		
		
		return commands;
	}
	
	private function changeLocation(source:String, position:Int):Array<VizelCommands>
	{
		var commands:Array<VizelCommands> = [];
		
		if (!objects.exists(BackgroundID))
		{
			commands.push(CreateObject(BackgroundID));
			commands.push(SetPivot(BackgroundID, 0, 0));
			commands.push(SetPosition(BackgroundID, 0, 0));
			commands.push(Hide(BackgroundID));
			objects.set(BackgroundID, true);
		}
		else
		{
			commands.push(FadeOut(BackgroundID));
		}
		
		commands.push(SetGraphic(BackgroundID, assetFilter.getBackground(source.collectKeywords())));
		commands.push(FadeIn(BackgroundID));
		return commands;
	}
	
}