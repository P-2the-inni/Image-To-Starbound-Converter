local weaponHeld = nil

function init()
	weaponHeld = world.entityHandItem( player.id(), "primary" )
end

function update()
	if weaponHeld ~= world.entityHandItem( player.id(), "primary" ) then -- closes if the weapon is put away
		pane.dismiss()
	end
	weaponHeld = world.entityHandItem( player.id(), "primary" )
end

function foregroundButton()
	world.sendEntityMessage( player.id(), "paster_setMode", "foreground" )
	pane.dismiss()
end

function backgroundButton()
	world.sendEntityMessage( player.id(), "paster_setMode", "background" )
	pane.dismiss()
end

function uninit() end