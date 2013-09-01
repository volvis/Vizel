Vizel
========

This is a work in progress repository. The goal is to create a framework for visual novels, which can then be reworked into games with similar storytelling mechanics.

If the name Ren'Py came to mind, you're not far off. Vizel aims to be more of a framework than a ready solution. A prototype will most likely be implemented using HaxeFlixel, but the main classes will remain agnostic on the underlying engine.

One goal is to make writing the script as intuitive and freeform as possible. Therefore the formatting of the script follows closely to the true and tested screenplay form.

```
INT. JILL'S HOUSE, BEDROOM, DAY

JILL looks out the window. She has a PUZZLED look on her face.

		JILL
	Cheyenne. What's he waiting for
	out there? What's he doing?
	
		CHEYENNE
	He's whittling on a piece of wood.
	
		CHEYENNE (cont.)
	I got a feeling that when he stops
	whittling, something's gonna happen. 
```

When interpreting scripts like these, Vizel looks for general keywords, tabulations and uppercased words to make an educated guess on what should be rendered on screen. Given a list of assets, it tries to figure out the best match for every line.

```
INT. JILL'S HOUSE, BEDROOM, DAY
```

Lines that start with the keywords INT. or EXT. are interpreted as clues for the background. When Vizel runs into line like this, it looks for assets in the <code>backgrounds</code> folder for a match and orders the engine to set it as the backdrop.

```
		JILL (looking ANGRY)
	I'm furious at why nothing
	seems to ever work!
```

Lines starting with two tabulations or eight spaces are interpreted as the character doing the talking. The name may be followed by numerous adjectives (all in uppercase) and Vizel attempts to find a character under the <code>characters</code> folder that suits those best. Vizel also has a <code>Map<String,String></code> key pair of actor names, which can be used to transform the displayed names into something else, for example JILL becomes "Jill McDoughlan".

There are a few special character names (NARRATION, SFX) for cases when the shown dialogue can't be traced to a specific actor.

```
		JILL (VO)
	This is internal monologue.
```

Names can also contain the keyword VO for voice over lines. These can be used to distinguish internal monologue from speech.

The following lines that start with a single tabulation (four spaces) are interpreted as lines of dialogue. It collects all the lines into one string until it comes across a blank line, and sends that along with the speaker's name to the engine.

```
		SHIMON (VO, visibly ANGRY)
	I can't believe this...
			Shout at Scone.
			Gently whisper at Scone. > WHISPER AT SCONE
```

Lines that follow dialogue and are preceded by three tabulations (12 spaces) are interpreted as choices to present the player. Vizel keeps internally track of every choice that the player makes in a <code>Map<String,Bool></code> variable, where String is the chosen option and Bool is always True.

If the option is followed by > and a string of letters, Vizel will store the latter instead of the former. This comes to play when the script is given branching paths.

```
OPT. Shout at Scone.

		SHIMON (SHOUTING)
	Joe! Front desk! Now!

OPT. WHISPER AT SCONE

		SHIMON (WHISPER)
	Joe... *whisper whisper*

OPT.
```

The OPT. keyword signals an optional path. Vizel takes the string that follows the keyword, checks if the player had made a decision with that name, and either proceeds as normal or searches for the next OPT. keyword.

OPT. that doesn't follow a named path serves as an end to diverging paths, and the script will resume as normal.

Optional paths cannot have more optional paths inside them. For that you need to change the script as follows...

```
CUT TO ENDING
```

The keywords "CUT TO" signals Vizel to look for a new script from the <code>scripts</code> folder. It then orders the underlying engine to provide the script that matches best, and the story continues from there.