function IsSprite( )
	return app.sprite
end


function IsActiveBox( )
	return app.layer and app.layer.data == "boxeres" and not app.layer.isGroup
end


function IsActiveCel( )
	return app.cel and app.cel.data == "boxeres"
end


function ColorToTable( color )
	return { color.red, color.green, color.blue, color.alpha }
end


function RectToTable( rect )
	return { rect.x, rect.y, rect.w, rect.h }
end


function GetBoxGroup( )
	
	for i, v in ipairs( app.sprite.layers ) do
		if v.isGroup and v.data == "boxeres" then
			return v
		end
	end
	return nil
end


function DrawRect( rect, color )
	
	local toolAttrs = { 
		tool = "rectangle", 
		brush = Brush( 1 ),
		points = { { rect.x, rect.y }, { rect.x + rect.w - 1, rect.y + rect.h - 1 } }	
	}
	app.fgColor = color
	app.useTool( toolAttrs )

end


function DrawBoxRects( color )
	if not IsActiveCel( ) then
		return
	end
	
	toolAttrs = {
		tool = "rectangle",
		brush = Brush( 1 ),
	}
	app.fgColor = color

	for i = 1, app.cel.properties.rectCount, 1 do
		local rect = app.cel.properties[ "rect" .. i ]
		local points = { { rect.x, rect.y }, { rect.x + rect.w - 1, rect.y + rect.h - 1 } }
		toolAttrs.points = points
		app.useTool( toolAttrs )
	end

end


function AddBox( )
	
	if not app.sprite then
		return
	end

	local boxGroup = GetBoxGroup( )
	if not boxGroup then
		boxGroup = app.sprite:newGroup( )
		boxGroup.data = "boxeres"
		boxGroup.isEditable = false
	end

	local box = app.sprite:newLayer( )
	box.color = Color{ r = 0, g = 0, b = 0, a = 255 }
	box.data = "boxeres"
	box.parent = boxGroup
end


function AddRect( )

	if not IsActiveBox( ) then
		return
	end
	
	local rect = app.sprite.selection.bounds
	if rect.isEmpty then
		return
	end
	
	DrawRect( rect, app.layer.color )
	app.refresh( )

	if app.cel.data ~= "boxeres" then
		app.cel.data = "boxeres"
		app.cel.properties.rectCount = 0
	end
	
	app.cel.properties.rectCount = app.cel.properties.rectCount + 1
	app.cel.properties[ "rect" .. app.cel.properties.rectCount ] = rect
end


function RemoveRects( )
	
	if not IsActiveBox( ) or app.cel.data ~= "boxeres" then
		return
	end

	local rect = app.sprite.selection.bounds
	if rect.isEmpty then
		return
	end

	app.sprite.selection:selectAll( )
	local offset = 0
	for i = 1, app.cel.properties.rectCount, 1 do
		
		local celRect = app.cel.properties[ "rect" .. i ]
		if rect:intersects( celRect ) then
			app.cel.properties[ "rect" .. i ] = nil
			DrawRect( celRect, Color{ r = 0, g = 0, b = 0, a = 0 } )
			offset = offset + 1
		else
			local temp = app.cel.properties[ "rect" .. i ]
			app.cel.properties[ "rect" .. i ] = nil
			app.cel.properties[ "rect" .. i - offset ] = temp
		end
	end

	if not app.cel then
		return
		app.refresh( )
	end
	app.cel.properties.rectCount = app.cel.properties.rectCount - offset
	DrawBoxRects( app.layer.color )
	app.refresh( )
	
end


function ShowRects( )
	
	if not IsActiveBox( ) or not app.cel or app.cel.data ~= "boxeres" then
		return
	end
	
	celProperties = app.cel.properties
	properties = { rectCount = celProperties.rectCount }
	for i = 1, properties.rectCount, 1 do
		properties[ "rect" .. i ] = celProperties[ "rect" .. i ]
	end

	app.command.ClearCel( )
	for i = 1, properties.rectCount, 1 do
		DrawRect( properties[ "rect" .. i ] )
		app.cel.properties[ "rect" .. i ] = properties[ "rect" .. i ]
	end
	app.cel.data = "boxeres"
	app.cel.properties.rectCount = properties.rectCount
end


function SaveAs( filepath )
	
	local boxGroup = GetBoxGroup( )

	if not boxGroup then
		return
	end	
	
	local data = { boxes = { }, tags = { } }
	for i, layer in ipairs( boxGroup.layers ) do
		data.boxes[ layer.name ] = { color = ColorToTable( layer.color ), rects = { } }
		for j = 1, #app.sprite.frames do
			cel = layer:cel( j )
			if not cel then
				data.boxes[ layer.name ].rects[ j ] = 0
			else
				data.boxes[ layer.name ].rects[ j ] = { }
				for k = 1, cel.properties.rectCount, 1 do
					data.boxes[ layer.name ].rects[ j ][ k ] = RectToTable( cel.properties[ "rect" .. k ] )
				end
			end
		end
	end

	for i, tag in ipairs( app.sprite.tags ) do
		data.tags[ tag.name ] = { tag.fromFrame.frameNumber - 1, tag.frames }
	end

	local file = io.open( filepath, "w" )
	io.output( file )
	io.write( json.encode( data ) )
	io.close( )
end


function init( plugin )
	print( "Initializing..." )

	local boxeresGroupID = "boxeres_id"

	plugin:newMenuSeparator {
		group = "layer_merge"
	}

	plugin:newMenuGroup {

		id = boxeresGroupID,
		title = "Boxeres",
		group = "layer_merge"
	
	}

	plugin:newCommand {
		
		id = "new_box_id",
		title = "New Box",
		group = boxeresGroupID,
		onclick = AddBox,
		onenabled = IsSprite	

	}

	plugin:newMenuSeparator {
		group = boxeresGroupID
	}

	plugin:newCommand {
	
		id = "add_rect_id",
		title = "Add Rect",
		group = boxeresGroupID,
		onclick = AddRect,
		onenabled = IsSprite	
	}

	plugin:newCommand {
	
		id = "remove_rects_id",
		title = "Remove Rects",
		group = boxeresGroupID,
		onclick = RemoveRects,
		onenabled = IsSprite
	}

	plugin:newMenuSeparator {
		group = boxeresGroupID
	}

	plugin:newCommand {
		
		id = "show_rects_id",
		title = "Show Rects",
		group = boxeresGroupID,
		onclick = ShowRects,
		onenabled = IsSprite

	}

	plugin:newMenuSeparator {
		group = boxeresGroupID
	}

	plugin:newCommand {
		
		id = "save_as_id",
		title = "Save As",
		group = boxeresGroupID,
		onclick = function( )
			local dlg = Dialog( "Save" )
			
			dlg:file { 
				id = "file_path",
				label = "This is a label:",
				title = "This is a title",
				save = true,
				filetypes = { "json" }
			}
			dlg:button {
				id = "save",
				text = "Save"
			}
			dlg:button {
				id = "cancel",
				text = "Cancel"	   
			}
			dlg:show( )
			local data = dlg.data
			
			if data.file_path == "" then
				return
			end
			
			if data.save then
				SaveAs( data.file_path )
			end

		end,
		onenabled = IsSprite

	}

	print( "Initialized." )
end


function exit( plugin )
	
	print( "Quit." )
end

