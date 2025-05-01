# Boxeres
An extension to manage and edit hitbox, hurtbox in Aseprite

**NOTE: This is my first time writting a README.md file and my English is really bad. Sorry for the inconvenients.**

***WARNING: This extension takes advantage of Aseprite's user-defined properties ( You can check it out here: [ user-defined_properties ]( https://www.aseprite.org/api/properties#properties ) ), Which mean when there is no more pixel on canvas all rect datas will be gone, but you can undo it and run the Show Rects command or just keep the box group lock.***

<br>

## Functionalities

Boxeres menu is located in bottom of Layer toolbar.


- New Box
	- Add box layer to box group( group layer )( If box group isn't exist, a box group will be created ( lock by default ) ).

- Add Rect
	- Add rect to current box cel using Selection tool.
	- Select what rect you want to create then run the command.

- Remove Rects
	- Remove rects from current box cel using Selection tool.
	- Select what rects you want to remove from cel then run the command.

- Show Rects
	- Redraw current rects in current box cel ( If canvas is empty, this command won't work. You better undo until it shows atleast 1 pixel on canvas ).

- Save As
	- Save data to json format.


## Json Format

```json
{
	"boxes":
	{
		"hitbox": // layer name
		{
			"color": [ 255, 0, 0, 255 ], // rgba format
			"rects": [ [ 1, 41, 1, 5 ], [ 4, 1, 4, 5 ] ], // First Frame. Rect: x, y, w, h
					 [ [ 1, 5, 1, 5 ] ]					  // Second Frame and so on...
					 0                                    // This means cel is empty
		},
		"hurtbox":
		{
		}
	},

	"tags":
	{
		"idle": [ 1, 10 ]   // "idle" is tag name. [ first frame number - 1, frame count ]
	}
}
```
