
local state = require "state"
local button = require "button"
local animation = require "animation"
local help = state "help"

local width, height = getScreenDimensions()

local title = love.graphics.newText( love.graphics.newFont( "font.otf", 40 ) )
local text = love.graphics.newText( love.graphics.newFont( "font.otf", 25 ) )
local back = button( width / 2 - 100, height - 100, 200, 50, "Back" )

title:setf( "How to play", width, "center" )

text:setf( [[
The aim of the game is to mark as many boxes as you can. By filling in the lines around a box, you mark it with either a '1' or '2', depending on which player you are. The person to fill in the last line around a box marks the box, and gets another go to fill another line. The person in the end with the most boxes marked wins.
]], width * 4/5, "center", 0, 100 )

function back:onClick()
	state.switchTo "main"
end

local buttons = { back }

for i = 1, #buttons do
	buttons[i].font = love.graphics.newFont( "font.otf", 30 )
end

function help:mousepressed( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mousedown( x, y ) then
				break
			end
		end
	end
end

function help:mousereleased( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mouseup( x, y ) then
				break
			end
		end
	end
end

function help:update( dt )
	animation.update( dt )
end

function help:draw()
	love.graphics.setColor( 0, 0, 0, 200 )
	love.graphics.draw( title, 0, 50 )
	love.graphics.draw( text, width * 1/10, height / 2 - text:getHeight() / 2 )
	for i = 1, #buttons do
		buttons[i]:draw()
	end
end
