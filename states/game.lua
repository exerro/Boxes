
local state = require "state"
local button = require "button"
local animation = require "animation"
local game = state "game"

local grid = require "grid"

local down = false
local downx, downy = 0, 0
local width, height = love.window.getMode()
local player = grid.PLAYER_ONE

local back = button( width - 200, 0, 200, 50, "Back" )
local title = love.graphics.newText( love.graphics.newFont( "font.otf", 30 ) )

title:setf( "Player One", width - 200, "center" )

function back:onClick()
	state.switchTo "main"
end

local buttons = { back }

for i = 1, #buttons do
	buttons[i].font = love.graphics.newFont( "font.otf", 30 )
end

local function switchPlayer()
	player = player == grid.PLAYER_ONE and grid.PLAYER_TWO or grid.PLAYER_ONE
	title:setf( player == grid.PLAYER_ONE and "Player ONE" or "Player TWO", width - 200, "center" )
end

function game:mousepressed( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mousedown( x, y ) then
				return
			end
		end

		down = true
		downx = x
		downy = y
	end
end

function game:mousereleased( x, y, button )
	if button == 1 then
		for i = #buttons, 1, -1 do
			if buttons[i]:mouseup( x, y ) then
				return
			end
		end

		if down then
			if (x-downx) ^ 2 + (y - downy) ^ 2 < 16 then -- moved less than 4 pixels
				if grid.activate( grid.getConnection( x, y ) ) then
					if grid.check( player ) then
						if grid.finished() then
							local winner = grid.getWinner()

							if winner == grid.PLAYER_ONE then
								print "Player ONE won!"
								require "states.finished" "Player ONE won!"
							elseif winner == grid.PLAYER_TWO then
								print "Player TWO won!"
								require "states.finished" "Player TWO won!"
							elseif winner == grid.PLAYER_NONE then
								print "It's a draw!"
								require "states.finished" "It's a draw!"
							end

							state.switchTo "finished"
						end
					else
						switchPlayer()
					end
				end
			end
		end
	end
end

function game:update( dt )
	animation.update( dt )
end

function game:draw()
	grid.draw()

	love.graphics.setColor( 0, 0, 0, 200 )
	love.graphics.draw( title, 0, 10 )
	for i = 1, #buttons do
		buttons[i]:draw()
	end
end

function game.prep( width, height )
	title:setf( "Player One", love.window.getMode() - 200, "center" )
	player = grid.PLAYER_ONE
	grid.prep( width, height )
end
