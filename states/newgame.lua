
local state = require "state"
local button = require "button"
local animation = require "animation"
local newgame = state "newgame"

local width, height = getScreenDimensions()
local back = button( width / 2 - 100, height - 100, 200, 50, "Back" )
local title = love.graphics.newText( love.graphics.newFont( "res/font.otf", 50 ) )
local subtext = love.graphics.newText( love.graphics.newFont( "res/font.otf", 30 ) )
local add = button( width / 2 - 150, 150, 300, 50, "Add Player" )
local playerfont = love.graphics.newFont( "res/font.otf", 30 )
local buttons
local players = {}
local delete = love.graphics.newImage "res/del_player.png"

local function addPlayer( label )
	players[#players + 1] = label
	animation.new( "add-button", add.y, 150 + #players * 70, .3, function( v )
		add.y = v
	end )
	if #players == 5 then
		buttons[2] = nil
	end
end

local function removePlayer( label )
	players[#players] = nil
	animation.new( "add-button", add.y, 150 + #players * 70, .3, function( v )
		add.y = v
	end )
	buttons[2] = add
end

title:setf( "New Game", width, "center" )
subtext:setf( "Players", width, "center" )

function back:onClick()
	state.switchTo "main"
end

function add:onClick()
	addPlayer( "dude" .. #players + 1 )
end

buttons = { back, add }

for i = 1, #buttons do
	buttons[i].font = love.graphics.newFont( "res/font.otf", 30 )
end

function newgame:focussed()
	players = {}
	add.y = 150
	buttons[2] = add
end

function newgame:mousepressed( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mousedown( x, y ) then
				break
			end
		end
	end
end

function newgame:mousereleased( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mouseup( x, y ) then
				break
			end
		end
	end
end

function newgame:update( dt )
	animation.update( dt )
end

function newgame:draw()
	local y = 150

	love.graphics.setColor( 0, 0, 0, 200 )
	love.graphics.draw( title, 0, 20 )
	love.graphics.setColor( 0, 0, 0, 130 )
	love.graphics.draw( subtext, 0, 90 )
	love.graphics.setColor( 0, 0, 0, 200 )

	for i = 1, #players do
		love.graphics.print( players[i], width / 2 - playerfont:getWidth( players[i] ) / 2, 165 + (i - 1) * 70 - playerfont:getHeight() / 2 )
		y = y + 70
	end

	love.graphics.setColor( 255, 255, 255 )

	for i = 1, #players do
		love.graphics.draw( delete, width * 4/5, 149 + (i - 1) * 70, 0, .5, .5 )
	end

	for i = 1, #buttons do
		buttons[i]:draw()
	end
end
