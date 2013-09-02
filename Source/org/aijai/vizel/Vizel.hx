package org.aijai.vizel;
using org.aijai.vizel.utils.VizelString;
import org.aijai.vizel.modules.AssetFilter;
import org.aijai.vizel.modules.LineReader;

enum VizelCommands
{
	CreateObject(id:String);
	SetGraphic(id:String, asset:String);
	SetPivot(id:String, x:Float, y:Float);
	SetPosition(id:String, screen:VizelDirections, position:VizelPositions);
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
	MakeBackground(id:String);
	Move(id:String, screen:VizelDirections, position:VizelPositions);
	Pan(screen:VizelDirections, ?immediate:Bool);
	LineNumber(ln:Int);
	Hold;
}

enum VizelDirections
{
	North;
	Northeast;
	East;
	Southeast;
	South;
	Southwest;
	West;
	Northwest;
	Center;
}

enum VizelPositions
{
	Left;
	Right;
	Middle;
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
	
	private var screen:VizelDirections;
	
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
		screen = VizelDirections.Center;
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
				case CAMERA(source, position):
					var dirExpr:EReg = ~/(?<!\w)(((NORTH|SOUTH)(EAST|WEST)?)|(EAST|WEST)|CENTER)(?!\w)/;
					if (dirExpr.match(source))
					{
						var match:String = VizelString.capitalize(dirExpr.matched(1));
						screen = Type.createEnum(VizelDirections, match, []);
						commands.push(Pan(screen));
					}
				case EVENT(source, position):
					commands = commands.concat(processEvent(source));
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
	
	private var subject:String = "";
	private function processEvent(source:String):Array<VizelCommands>
	{
		var commands:Array<VizelCommands> = [];
		var phraseExpr:EReg = ~/(?<=[\.!\?;]) /g;
		var phrases:Array<String> = phraseExpr.split(source);
		//var subject:String = "";
		var object:String = "";
		for (phrase in phrases)
		{
			var keywords:Array<String> = VizelString.collectKeywords(phrase);
			var subjectSet:Bool = false;
			
			// Test for she/he pronouns.. If match, use last known.
			if (subject != "")
			{
				var subjectExpr:EReg = ~/(^| )(she|he)( |')/i;
				if (subjectExpr.match(phrase))
				{
					subjectSet = true;
					keywords.push(subject);
				}
			}
			
			// Determine if the phrase has a subject
			if (!subjectSet)
			{
				for (keyword in keywords)
				{
					if (actorNames.exists(keyword)) 
					{
						if (subjectSet == false)
						{
							subjectSet = true;
							subject = keyword;
						}
						else
						{
							object = keyword;
						}
					}
				}
			}
			
			if (subjectSet)
			{
				if (objects.exists(subject) == false)
				{
					commands.push(CreateObject(subject));
					commands.push(SetPivot(subject, 0.5, 1));
					commands.push(Hide(subject));
					objects.set(subject, true);
					if (!actorNames.exists(subject))
					{
						actorNames.set(subject, subject);
					}
				}
				commands.push(SetGraphic(subject, assetFilter.getActor(keywords)));
				
				
				
				var region:VizelDirections = screen;
				var position:VizelPositions = VizelPositions.Middle;
				var positionChange:Bool = false;
				
				var dirExpr:EReg = ~/(?<!\w)(((NORTH|SOUTH)(EAST|WEST)?)|(EAST|WEST)|CENTER)(?!\w)/;
				if (dirExpr.match(source))
				{
					var match:String = VizelString.capitalize(dirExpr.matched(1));
					region = Type.createEnum(VizelDirections, match, []);
					positionChange = true;
				}
				
				var posExpr:EReg = ~/(?<!\w)(LEFT|RIGHT|MIDDLE)(?!\w)/;
				if (posExpr.match(source))
				{
					var match:String = VizelString.capitalize(posExpr.matched(1));
					position = Type.createEnum(VizelPositions, match, []);
					positionChange = true;
				}
				
				if (positionChange)
				{
					var moveExpr:EReg = ~/MOVE|WALK|ARRIVE/;
					if (moveExpr.match(source))
					{
						commands.push(Move(subject, region, position));
					}
					else
					{
						commands.push(SetPosition(subject, region, position));
					}
				}
				
				
				
				var fadeExpr:EReg = ~/FADE(S) (IN|OUT)/;
				if (fadeExpr.match(phrase))
				{
					if (fadeExpr.matched(2) == "IN")
					{
						commands.push(FadeIn(subject));
					}
					else
					{
						commands.push(FadeOut(subject));
					}
				}
				
				var from:String, to:String;
			}
			
			// If the phrase ends with "...", count the dots and send a Wait command.
			if (StringTools.endsWith(phrase, ".."))
			{
				var waitLength:Int = 0;
				var strIndex:Int = phrase.length;
				while (phrase.charAt(--strIndex) == ".") waitLength++;
				commands.push(Wait(0.3*waitLength));
			}
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
				commands.push(Hide(subject));
				objects.set(currentActor, true);
				if (!actorNames.exists(currentActor))
				{
					actorNames.set(currentActor, currentActor);
				}
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
		//screen = VizelDirections.Center;
		
		if (!objects.exists(BackgroundID))
		{
			commands.push(CreateObject(BackgroundID));
			commands.push(Hide(BackgroundID));
			objects.set(BackgroundID, true);
		}
		else
		{
			commands.push(FadeOut(BackgroundID));
			commands.push(Hold);
		}
		commands.push(SetGraphic(BackgroundID, assetFilter.getBackground(source.collectKeywords())));
		commands.push(MakeBackground(BackgroundID));
		
		var dirExpr:EReg = ~/(?<!\w)(((NORTH|SOUTH)(EAST|WEST)?)|(EAST|WEST)|CENTER)(?!\w)/;
		if (dirExpr.match(source))
		{
			var match:String = VizelString.capitalize(dirExpr.matched(1));
			screen = Type.createEnum(VizelDirections, match, []);
			commands.push(Pan(screen, true));
		}
		
		commands.push(FadeIn(BackgroundID));
		
		return commands;
	}
	
}