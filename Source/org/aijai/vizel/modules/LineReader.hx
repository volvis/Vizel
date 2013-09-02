package org.aijai.vizel.modules;

enum LineType
{
	UNKNOWN(source:String, position:Int);
	EMPTY(source:String, position:Int);
	LOCATION(source:String, position:Int);
	CONDITION(source:String, position:Int);
	ACTOR(source:String, position:Int);
	DIALOGUE(source:String, position:Int);
	EVENT(source:String, position:Int);
	OPTION(source:String, position:Int);
	SCRIPT(source:String, position:Int);
	CAMERA(source:String, position:Int);
}

/**
 * ...
 * @author Pekka Heikkinen
 */
class LineReader
{
	private var source:Array<String>;
	public var lineNumber:Int;
	
	public function new(sourceText:String, line:Int = 0) 
	{
		source = sourceText.split("\n");
		lineNumber = line;
	}
	
	public function iterator():Iterator<LineType>
	{
		return this;
	}
	
	public function hasNext():Bool
	{
		return lineNumber < source.length;
	}
	
	public function next():LineType
	{
		var filepos = lineNumber;
		var lineSource:String = source[lineNumber++];
		var src:String = StringTools.trim(lineSource);
		
		if (!~/\w/.match(lineSource))
		{
			return EMPTY(src, filepos);
		}
		
		var numTabs:Int = countStartingTabs(lineSource);
		
		if (numTabs == 0)
		{
			
			var locationExpr:EReg = ~/^INT\.|EXT\./;
			if (locationExpr.match(lineSource))
			{
				return LOCATION(src, filepos);
			}
			var cameraExpr:EReg = ~/^CAM\.|^CAMERA/;
			if (cameraExpr.match(lineSource))
			{	
				return CAMERA(src, filepos);
			}
			var conditionExpr:EReg = ~/^OPT\./;
			if (conditionExpr.match(lineSource))
			{
				return CONDITION(src, filepos);
			}
			var cutExpr:EReg = ~/^(CUT TO)/;
			if (cutExpr.match(lineSource))
			{
				return SCRIPT(src, filepos);
			}
			var eventExpr:EReg = ~/^\w+/;
			if (eventExpr.match(lineSource))
			{
				return EVENT(src, filepos);
			}
		}
		else if (numTabs == 1)
		{
			return DIALOGUE(src, filepos);
		}
		else if (numTabs == 2)
		{
			return ACTOR(src, filepos);
		}
		else if (numTabs == 3)
		{
			return OPTION(src, filepos);
		}

		return UNKNOWN(lineSource, filepos);
	}
	
	private function countStartingTabs(str):Int
	{
		var tabs:Int = 0;
		var spacesPerTab:Int = 4;
		if (str.charCodeAt(0) == 9)
		{
			while (str.charCodeAt(tabs) == 9)
			{
				tabs++;
			}
		}
		else if (str.charCodeAt(0) == 32)
		{
			while (str.charCodeAt(tabs*spacesPerTab) == 32)
			{
				tabs++;
			}
		}
		return tabs;
	}
	
	
	
}