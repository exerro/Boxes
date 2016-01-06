
local states = {}
local animations = {}
local active = 1
local duration = .3

local function ease( u, d, t )
	return u + d * ( 3 * t * t - 2 * t * t * t )
end

local function animation_new( state, initial, final, duration, callback )
	local t  = {
		state = state;
		initial = initial;
		difference = final - initial;
		duration = duration;
		clock = 0;
		callback = callback;
	}

	for i = #animations, 1, -1 do
		if animations[i].state == state then
			animations[i] = t
			return
		end
	end

	animations[#animations + 1] = t
end

local function animation_update( dt )

	for i = #animations, 1, -1 do
		local v = animations[i]
		local t = v.clock / v.duration
		local n = v.initial + v.difference * ( 3 * t * t - 2 * t * t * t )

		v.callback( n )
		v.clock = v.clock + dt

		if v.clock > v.duration then
			v.callback( v.initial + v.difference )
			table.remove( animations, i )
		end
	end

end

local function getByName( name )
	for i = #states, 1, -1 do
		if states[i].name == name then
			return states[i]
		end
	end
end

local function getIndex( state )
	for i = #states, 1, -1 do
		if states[i] == state then
			return i
		end
	end
end

local state = {}

function state:new( name )
	local s = {
		name = name;
		position = #states * love.window.getMode();
		switchTo = self.switchTo;
	}

	states[#states + 1] = s

	return s
end

function state:switchTo()
	if type( self ) == "string" then
		return state.switchTo( getByName( self ) or error( "no such state '" .. self .. "'" ) )
	elseif type( self ) ~= "table" then
		return error( "expected table state, got " .. type( self ) )
	end

	local index = getIndex( self )

	if active == index then
		return
	end

	animation_new( self, self.position, 0, duration, function( value ) self.position = value end )

	if active > 0 then
		local s = states[active]

		if active > index then
			animation_new( s, s.position, love.window.getMode(), duration, function( value ) s.position = value end )
		else
			animation_new( s, s.position, -love.window.getMode(), duration, function( value ) s.position = value end )
		end
	end

	if states[index].focussed then
		states[index]:focussed()
	end
	active = index
end

function state.get( name )
	return getByName( name )
end

function state.setTransitionDuration( n )
	if type( n ) ~= "number" then
		return error( "expected number duration, got " .. type( n ) )
	end

	duration = n
end

function state.mousepressed( x, y, button )
	local width = love.window.getMode()

	for i = #states, 1, -1 do
		if x >= states[i].position and x <= states[i].position + width and states[i].mousepressed then
			states[i]:mousepressed( x - states[i].position, y, button )
		end
	end
end

function state.mousereleased( x, y, button )
	local width = love.window.getMode()

	for i = #states, 1, -1 do
		if x >= states[i].position and x <= states[i].position + width and states[i].mousereleased then
			states[i]:mousereleased( x - states[i].position, y, button )
		end
	end
end

function state.mousemoved( x, y )
	local width = love.window.getMode()

	for i = #states, 1, -1 do
		if x >= states[i].position and x <= states[i].position + width and states[i].mousemoved then
			states[i]:mousemoved( x - states[i].position, y )
		end
	end
end

function state.touchpressed( id, x, y, pressure )
	local width = love.window.getMode()

	for i = #states, 1, -1 do
		if x >= states[i].position and x <= states[i].position + width and states[i].touchpressed then
			states[i]:touchpressed( id, x - states[i].position, y, pressure )
		end
	end
end

function state.touchreleased( id, x, y, pressure )
	local width = love.window.getMode()

	for i = #states, 1, -1 do
		if x >= states[i].position and x <= states[i].position + width and states[i].touchreleased then
			states[i]:touchreleased( id, x - states[i].position, y, pressure )
		end
	end
end

function state.touchmoved( id, x, y, pressure )
	local width = love.window.getMode()

	for i = #states, 1, -1 do
		if x >= states[i].position and x <= states[i].position + width and states[i].touchmoved then
			states[i]:touchmoved( id, x - states[i].position, y, pressure )
		end
	end
end

function state.draw()

	local width, height = love.window.getMode()

	for i = #states, 1, -1 do
		if states[i] and states[i].draw and states[i].position > -width and states[i].position < width then
			local sx, sy, sw, sh = love.graphics.getScissor()

			love.graphics.translate( states[i].position, 0 )
			love.graphics.setScissor( states[i].position, 0, width, height )

			states[i]:draw()

			love.graphics.translate( -states[i].position, 0 )
			love.graphics.setScissor( sx, sy, sw, sh )
		end
	end
end

function state.update( dt )
	animation_update( dt )

	if states[active] and states[active].update then
		states[active]:update( dt )
	end
end

function state.hook()
	love.update = state.update
	love.draw = state.draw
	love.mousepressed = state.mousepressed
	love.mousereleased = state.mousereleased
	love.mousemoved = state.mousemoved
	love.touchpressed = state.touchpressed
	love.touchreleased = state.touchreleased
	love.touchmoved = state.touchmoved
end

return setmetatable( state, { __call = state.new } )
