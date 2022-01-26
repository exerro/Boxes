
local state = require "state"
local rotate = love.system.getOS() == "Android" or love.system.getOS() == "iOS"

love.graphics.setBackgroundColor( 240 / 255, 240 / 255, 240 / 255 )

function getScreenWidth()
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()
	return rotate and height or width
end

function getScreenHeight()
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()
	return rotate and width or height
end

function getScreenDimensions()
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()
	if rotate then
		return height, width
	else
		return width, height
	end
end

if rotate then
	local getPosition = love.mouse.getPosition

	function love.mouse.getPosition()
		local x, y = getPosition()
		return getScreenWidth() - y, x
	end
end

function love.mousepressed( x, y, button )
	if rotate then
		x, y = getScreenWidth() - y, x
	end

	state.mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
	if rotate then
		x, y = getScreenWidth() - y, x
	end

	state.mousereleased( x, y, button )
end

function love.mousemoved( x, y )
	if rotate then
		x, y = getScreenWidth() - y, x
	end

	state.mousemoved( x, y )
end

function love.update( dt )
	state.update( dt )
end

function love.draw()
	if rotate then
		local width, height = getScreenDimensions()
		love.graphics.rotate( -math.pi / 2 )
		love.graphics.translate( -width, 0 )
	end

	state.draw()
end

require "states.main"
require "states.game"
require "states.help"
require "states.finished"
require "states.newgame"
