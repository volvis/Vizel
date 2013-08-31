package org.aijai.ds;

/**
 * An abstract data source for *.ini format. Builds a Map<String, Map<String, String>>
 * from text and wraps it with accessor functions.
 * @author Pekka Heikkinen
 */
abstract INI(Map < String, Map < String, String >>)
{
	public inline function new(a:Map < String, Map < String, String >> )
	{	
		this = a;
	}
	
	public inline static var rootID:String = "__Root__";
	
	@:from public inline static function ofString(Str:String):INI
	{
		var lines:Array<String> = Str.split("\n");
		var sections:Map<String, Map<String, String>> = new Map<String, Map<String, String>>();
		var variables = new Map<String, String>();
		var currentSection:String = "__Root__";
		sections.set(currentSection, new Map<String, String>());
		for (dLine in lines)
		{
			var line:String = StringTools.trim(dLine);
			if (StringTools.startsWith(line, "["))
			{
				currentSection = line.substring(1, line.length - 1);
				sections.set(currentSection, new Map<String, String>());
			}
			else if (StringTools.startsWith(line, ";") == false)
			{
				var parts = line.split("=");
				if (parts.length == 2)
				{
					sections.get(currentSection).set(StringTools.trim(parts[0]), StringTools.trim(parts[1]));
				}
			}
		}
		if (sections.exists(rootID) == false)
		{
			sections.set(rootID, new Map<String,String>());
		}
		return new INI(sections);
	}
	
	@:to public inline function toString():String
	{
		var sections:Array<String> = new Array<String>();
		var stringBlock:String = "";
		for (section in this.keys())
		{
			stringBlock = "";
			for (key in this.get(section).keys())
			{
				stringBlock += '$key = ${Std.string(this.get(section).get(key))}\n';
			}
			if (stringBlock != "")
			{
				if (section == rootID)
				{
					sections.unshift(stringBlock);
				}
				else
				{
					stringBlock = '[$section]\n' + stringBlock;
					sections.push(stringBlock);
				}
			}
		}
		
		return sections.join("\n");
	}
	
	public inline function request(Category:String, Variable:String, Default:String = null):String
	{
		if (hasCategory(Category) && this.get(Category).exists(Variable))
		{
			var c:INICategory = category(Category);
			return c.request(Variable);
		}
		else
		{			
			return Default;
		}
	}
	
	public inline function hasCategory(Category:String):Bool
	{
		return this.exists(Category);
	}
	
	public inline function category(Category:String = rootID):INICategory
	{
		if (hasCategory(Category))
		{			
			return new INICategory(this.get(Category));
		}
		else
		{
			return new INICategory(this.get(rootID));
		}
	}
	
	public inline function categories():Iterator<String>
	{
		return this.keys();
	}
	
	@:to public inline function toMap():Map < String, Map < String, String >>
	{
		return this;
	}
}

abstract INICategory(Map<String,String>)
{
	public inline function new(a:Map<String,String>)
	{
		this = a;
	}
	
	public inline function hasVariable(Variable:String):Bool
	{
		return this.exists(Variable);
	}
	
	public inline function variables():Iterator<String>
	{
		return this.keys();
	}
	
	public inline function request(Variable:String, Default:String = null):String
	{
		if (hasVariable(Variable))
		{			
			return this.get(Variable);
		}
		else
		{			
			return Default;
		}
	}
	
	public inline function requestInt(Variable:String, Default:Int = 0):Int
	{
		if (hasVariable(Variable))
		{			
			var i:Int = Std.parseInt(request(Variable, null));
			if (Math.isNaN(i))
			{
				return Default;
			}
			else
			{				
				return i;
			}
		}
		else
		{			
			return Default;
		}
	}
	
	public inline function requestFloat(Variable:String, Default:Float = 0):Float
	{
		if (hasVariable(Variable))
		{			
			var i:Float = Std.parseFloat(request(Variable, null));
			if (Math.isNaN(i))
			{
				return Default;
			}
			else
			{
				return i;
			}
		}
		else
		{			
			return Default;
		}
	}
	
	public inline function requestBool(Variable:String, Default:Bool = false):Bool
	{
		var v:String = request(Variable, null);
		if (v == "1" || v == "true")
		{
			return true;
		}
		else
		{			
			return Default;
		}
	}
	
	public inline function requestMultipart(Variable:String):INIMultipart
	{
		var outAr:Array<INIVariable> = new Array<INIVariable>();
		var v:String = request(Variable, null);
		var ar:Array<String> = v.split(" ");
		for (str in ar.iterator())
		{
			outAr.push(new INIVariable(str));
		}
		return new INIMultipart(outAr);
	}
}

abstract INIMultipart(Array<INIVariable>)
{
	public inline function new(a:Array<INIVariable>)
	{
		this = a;
	}
	
	public inline function getX():Float
	{
		if (this.length == 2)
		{
			return this[0].toFloat();
		}
		else
		{
			return 0;
		}
	}
	
	public inline function getY():Float
	{
		if (this.length == 2)
		{
			return this[1].toFloat();
		}
		else
		{
			return 0;
		}
	}
}

abstract INIVariable(String)
{
	public inline function new(a:String)
	{
		this = a;
	}
	
	public inline function toInt(Default:Int = 0):Int
	{
		var i:Int = Std.parseInt(this);
		if (Math.isNaN(i))
		{
			return Default;
		}
		else
		{			
			return i;
		}
	}
	
	public inline function toFloat(Default:Float = 0):Float
	{
		var i:Float = Std.parseFloat(this);
		if (!Math.isNaN(i))
		{
			return i;
		}
		else
		{			
			return Default;
		}
	}
	
	public inline function toBool(Default:Bool = false):Bool
	{
		if (this == "1" || this == "true")
		{
			return true;
		}
		else
		{			
			return Default;
		}
	}
	
	@:to public inline function toString():String
	{
		return this;
	}
}