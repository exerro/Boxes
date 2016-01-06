
local state = require "state"
local button = require "button"
local animation = require "animation"
local main = state "main"

local width, height = getScreenDimensions()

local small = button( width / 2 - 150, height / 2 - 80, 300, 50, "Small Game" )
local large = button( width / 2 - 150, height / 2, 300, 50, "Large Game" )
local help = button( width / 2 - 150, height / 2 + 80, 300, 50, "How To Play" )
local quit = button( width / 2 - 150, height / 2 + 160, 300, 50, "Quit" )
local debug = button( 10, 10, 100, 50, "Beta" )

local title = love.graphics.newText( love.graphics.newFont( "res/font.otf", 60 ) )

title:setf( "Boxes", width, "center" )

function small:onClick()
	state.get "game" .prep( 5, 5 )
	state.switchTo "game"
end

function large:onClick()
	state.get "game" .prep( 8, 8 )
	state.switchTo "game"
end

function help:onClick()
	state.switchTo "help"
end

function quit:onClick()
	love.event.quit()
end

function debug:onClick()
	state.switchTo "newgame"
end

local buttons = { small, large, help, quit, debug }

for i = 1, #buttons do
	buttons[i].font = love.graphics.newFont( "res/font.otf", 30 )
end

function main:mousepressed( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mousedown( x, y ) then
				break
			end
		end
	end
end

function main:mousereleased( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mouseup( x, y ) then
				break
			end
		end
	end
end

function main:update( dt )
	animation.update( dt )
end

function main:draw()
	love.graphics.setColor( 0, 0, 0, 200 )
	love.graphics.draw( title, 0, 75 )
	for i = 1, #buttons do
		buttons[i]:draw()
	end
end
