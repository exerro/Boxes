
local v = {}
local h = {}
local b = {}
local size = { width = 0, height = 0 }

local STATE_NONE = 0
local STATE_PLAYER_ONE = 1
local STATE_PLAYER_TWO = 2
local STATE_HOVER = 3

local PLAYER_NONE = 0
local PLAYER_ONE = 1
local PLAYER_TWO = 2

local MODE_HORIZONTAL = 0
local MODE_VERTICAL = 1
local MODE_NONE = 2

local colours = {
	node = { 160 / 255, 160 / 255, 160 / 255 };
	connection_inactive = { 230 / 255, 230 / 255, 230 / 255 };
	connection_player_one = { 100 / 255, 150 / 255, 220 / 255 };
	connection_player_two = { 255 / 255, 90 / 255, 100 / 255 };
	connection_hovered = { 140 / 255, 180 / 255, 240 / 255 };
	player_one = { 100 / 255, 150 / 255, 220 / 255 };
	player_two = { 255 / 255, 90 / 255, 100 / 255 };
}

local grid = {
	PLAYER_ONE = PLAYER_ONE;
	PLAYER_TWO = PLAYER_TWO;
	PLAYER_NONE = PLAYER_NONE;
}

local fonts = {}

function grid.prep( width, height )
	v, h = {}, {}
	b = {}
	size.width, size.height = width, height

	for r = 1, height do
		h[r] = {}
		for c = 1, width - 1 do
			h[r][c] = STATE_NONE
		end
	end

	for r = 1, height - 1 do
		v[r] = {}
		for c = 1, width do
			v[r][c] = STATE_NONE
		end
	end

	for r = 1, height - 1 do
		b[r] = {}
		for c = 1, width - 1 do
			b[r][c] = PLAYER_NONE
		end
	end
end

function grid.draw()

	local width, height = getScreenDimensions()
	local spacing = math.floor( math.min( ( width - 100 ) / size.width, ( height - 200 ) / size.height ) )
	local lineWidth = math.max( spacing / 8, 8 )

	fonts[spacing] = fonts[spacing] or love.graphics.newFont( "res/font.otf", spacing * 3 / 4 )

	local gridw, gridh = spacing * ( size.width - 1 ), spacing * ( size.height - 1 )
	local ox, oy = width / 2 - gridw / 2, height / 2 - gridh / 2

	local mx, my = love.mouse.getPosition()
	local m, hx, hy = grid.getConnection( mx, my )

	local font = fonts[spacing]
	local fheight = font:getHeight()

	for r = 1, size.height do
		for c = 1, size.width - 1 do
			local s = h[r][c]

			if s == STATE_NONE and m == MODE_HORIZONTAL and hx == c and hy == r then
				s = STATE_HOVER
			end

			love.graphics.setColor( colours["connection_" .. ((s == STATE_NONE and "inactive") or (s == STATE_PLAYER_ONE and "player_one") or (s == STATE_PLAYER_TWO and "player_two") or (s == STATE_HOVER and "hovered"))] )
			love.graphics.rectangle( "fill", (c-1) * spacing + ox, (r-1) * spacing - lineWidth / 2 + oy, spacing, lineWidth )
		end
	end

	for r = 1, size.height - 1 do
		for c = 1, size.width do
			local s = v[r][c]

			if s == STATE_NONE and m == MODE_VERTICAL and hx == c and hy == r then
				s = STATE_HOVER
			end

			love.graphics.setColor( colours["connection_" .. ((s == STATE_NONE and "inactive") or (s == STATE_PLAYER_ONE and "player_one") or (s == STATE_PLAYER_TWO and "player_two") or (s == STATE_HOVER and "hovered"))] )
			love.graphics.rectangle( "fill", (c-1) * spacing + ox - lineWidth / 2, (r-1) * spacing + oy, lineWidth, spacing )
		end
	end

	love.graphics.setColor( colours.node )

	for r = 1, size.height do
		for c = 1, size.width do
			love.graphics.circle( "fill", (r - 1) * spacing + ox, (c - 1) * spacing + oy, lineWidth )
		end
	end

	love.graphics.setFont( font )

	for r = 1, size.height - 1 do
		for c = 1, size.width - 1 do
			local player = b[r][c]

			if player == PLAYER_ONE then
				love.graphics.setColor( colours.player_one )
				love.graphics.print( "1", ox + (c-1) * spacing + spacing / 2 - font:getWidth "1" / 2, oy + (r-1) * spacing + spacing / 2 - fheight / 2 )
			elseif player == PLAYER_TWO then
				love.graphics.setColor( colours.player_two )
				love.graphics.print( "2", ox + (c-1) * spacing + spacing / 2 - font:getWidth "2" / 2, oy + (r-1) * spacing + spacing / 2 - fheight / 2 )
			end
		end
	end
end

function grid.getConnection( x, y )
	local width, height = getScreenDimensions()
	local spacing = math.floor( math.min( ( width - 100 ) / size.width, ( height - 200 ) / size.height ) )

	local ox = width / 2 - spacing * ( size.width - 1 ) / 2
	local oy = height / 2 - spacing * ( size.height - 1 ) / 2

	x, y = x - ox, y - oy

	local nx, ny = math.floor( x / spacing ) + 1, math.floor( y / spacing ) + 1

	local difft = y - (ny-1) * spacing
	local diffb = ny * spacing - y
	local diffl = x - (nx-1) * spacing
	local diffr = nx * spacing - x

	local diffx = math.min( diffl, diffr )
	local diffy = math.min( difft, diffb )

	local lx = diffl < diffr and nx-1 or nx
	local ly = difft < diffb and ny-1 or ny

	if diffx < diffy and lx >= 0 and lx < size.width and ny > 0 and ny <= size.height then
		return MODE_VERTICAL, lx + 1, ny
	elseif diffx >= diffy and ly >= 0 and ly < size.height and nx > 0 and nx <= size.width then
		return MODE_HORIZONTAL, nx, ly + 1
	else
		return MODE_NONE
	end
end

function grid.activate( player, mode, x, y )
	if mode == MODE_VERTICAL or mode == MODE_HORIZONTAL then
		local t = ( mode == MODE_VERTICAL and v ) or h
		if t[y] and t[y][x] then
			if t[y][x] == STATE_NONE then
				t[y][x] = player == PLAYER_ONE and STATE_PLAYER_ONE or STATE_PLAYER_TWO
				return true
			else
				return false
			end
		end
	end
end

function grid.check( player )
	local changed = false

	for r = 1, size.height - 1 do
		for c = 1, size.height - 1 do
			if b[r][c] == PLAYER_NONE then
				if v[r][c] ~= STATE_NONE and h[r][c] ~= STATE_NONE and h[r + 1][c] ~= STATE_NONE and v[r][c + 1] ~= STATE_NONE then
					b[r][c] = player
					changed = true
				end
			end
		end
	end

	return changed
end

function grid.finished()
	for r = 1, size.height - 1 do
		for c = 1, size.height - 1 do
			if b[r][c] == PLAYER_NONE then
				return false
			end
		end
	end
	return true
end

function grid.getWinner()
	local player_one = 0
	local player_two = 0
	for r = 1, size.height - 1 do
		for c = 1, size.height - 1 do
			if b[r][c] == PLAYER_ONE then
				player_one = player_one + 1
			else
				player_two = player_two + 1
			end
		end
	end
	return ( player_one > player_two and PLAYER_ONE ) or ( player_one < player_two and PLAYER_TWO ) or PLAYER_NONE
end

return grid
