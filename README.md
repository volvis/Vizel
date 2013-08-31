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

When interpreting scripts like these, Vizel looks for general keywords, tabulations and uppercased words to make an educated guess on what should be rendered on screen. Given a list of assets, it tries to figure out the best match for every line. For example, it picks the keywords JILL and PUZZLED from the second line, and it might conclude that perhaps the character JILL should look like the graphic from 'assets/characters/jill_puzzled.png'.

More as the project progresses!