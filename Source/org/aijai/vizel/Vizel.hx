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
	Hide(id:String);
	Pass;
	EOF;
	Wait(seconds:Float);
	WaitForInput;
	SetSpeaker(name:String);
	SetDialogue(dialog:String);
}

/**
 * ...
 * @author Pekka Heikkinen
 */
class Vizel
{
	public var lineReader:Iterable<LineType>;
	public var assetFilter:IAssetFilter;
	
	private static inline var BackgroundID:String = "_VizelBackground_";
	
	private var objects:Map<String, Bool>;
	private var actors:Map<String, String>;
	
	public function new() 
	{
		objects = new Map<String, Bool>();
		actors = new Map<String, String>();
	}
	
	public function iterator():Iterator<Array<VizelCommands>>
	{
		return this;
	}
	
	public function hasNext():Bool
	{
		return lineReader.iterator().hasNext();
	}
	
	public function next():Array<VizelCommands>
	{
		var commands:Array<VizelCommands> = [];
		var line:LineType = lineReader.iterator().next();
		switch(line)
		{
			case LOCATION(source, position):
				commands = commands.concat(changeLocation(source, position));
			case ACTOR(source, position):
				commands = commands.concat(changeActor(source, position));
				commands = commands.concat(next());
			case DIALOGUE(source, position):
				commands.push(SetSpeaker(currentActor));
				commands.push(SetDialogue(source));
			default: //Do Nothing;
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
		if (firstSpaceCharacter != -1)
		{			
			currentActor = source.substring(0, firstSpaceCharacter);
		}
		else
		{
			currentActor = source;
		}
		if (currentActor != "NARRATION" && currentActor != "SFX")
		{
			if (!objects.exists(currentActor))
			{
				commands.push(CreateObject(currentActor));
				commands.push(SetPivot(currentActor, 0.5, 1));
				objects.set(currentActor, true);
			}
			commands.push(SetGraphic(currentActor, assetFilter.getActor(source.collectKeywords())));
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