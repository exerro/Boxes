
local state = require "state"
local button = require "button"
local animation = require "animation"
local finished = state "finished"

local width, height = love.window.getMode()

local title = love.graphics.newText( love.graphics.newFont( "font.otf", 40 ) )
local back = button( width / 2 - 100, height * 4 / 5, 200, 50, "Back" )

function back:onClick()
	state.switchTo "main"
end

local buttons = { back }

for i = 1, #buttons do
	buttons[i].font = love.graphics.newFont( "font.otf", 30 )
end

function finished:mousepressed( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mousedown( x, y ) then
				break
			end
		end
	end
end

function finished:mousereleased( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mouseup( x, y ) then
				break
			end
		end
	end
end

function finished:update( dt )
	animation.update( dt )
end

function finished:draw()
	love.graphics.setColor( 0, 0, 0, 200 )
	print( height / 2 - title:getHeight() / 2, title:getHeight() )
	love.graphics.draw( title, 0, height / 2 - title:getHeight() / 2 )
	for i = 1, #buttons do
		buttons[i]:draw()
	end
end

return function( text )
	title:setf( text, width, "center" )
end
