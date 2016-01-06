
local button = {}
local animation = require "animation"
local shadow_scale = 3
local image = love.graphics.newImage( love.image.newImageData( 1, 1 ) )
local use_shader = pcall( love.graphics.newShader, love.filesystem.read "shadow.glsl", nil ) and false

function button:new( ... )
	local b = setmetatable( {}, { __index = self } )
	b:init( ... )
	return b
end

function button:init( x, y, width, height, text )
	self.x = x
	self.y = y
	self.z = 3
	self.width = width
	self.height = height
	self.text = text
	self.colour = { 50, 120, 190, 255 }
	self.colour_held = self.colour or { 110, 160, 230, 255 }
	self.colour_text = { 255, 255, 255 }
	self.font = love.graphics.newFont "font.otf"
	self.shadow = use_shader and love.graphics.newShader( love.filesystem.read "shadow.glsl", nil )
	self.held = false
	self.down_x = 0
	self.down_y = 0

	if use_shader then
		self.shadow:send( "horizontal", self.z * shadow_scale / self.width )
		self.shadow:send( "vertical", self.z * shadow_scale / self.height )
	end
end

function button:animate( attribute, from, to, time )
	animation.new( tostring( self ) .. "-" .. attribute, from, to, time, function( value )
		self[attribute] = value
	end )
end

function button:animateZ( from, to, time )
	animation.new( tostring( self ) .. "-z", from, to, time, function( value )
		self.z = value

		if use_shader then
			self.shadow:send( "horizontal", self.z * shadow_scale / self.width )
			self.shadow:send( "vertical", self.z * shadow_scale / self.height )
		end
	end )
end

function button:draw()
	love.graphics.setColor( 0, 0, 0, 100 )
	if use_shader then
		love.graphics.setShader( self.shadow )
		love.graphics.draw( image, self.x - self.z * shadow_scale, self.y - 0.5 * self.z * shadow_scale, 0, self.width + 2 * self.z * shadow_scale, self.height + 2 * self.z * shadow_scale )
		love.graphics.setShader()
	end

	love.graphics.setColor( self.held and self.colour_held or self.colour )
	love.graphics.rectangle( "fill", self.x, self.y, self.width, self.height )

	love.graphics.setFont( self.font )
	love.graphics.setColor( self.colour_text )
	love.graphics.print( self.text, self.x + self.width / 2 - self.font:getWidth( self.text ) / 2, self.y + self.height / 2 - self.font:getHeight() / 2 )
end

function button:mousedown( x, y )
	if x >= self.x and y >= self.y and x < self.x + self.width and y < self.y + self.height then
		self.held = true
		self.down_x = x - self.x
		self.down_y = y - self.y

		self:animateZ( self.z, 1, .1 )

		return true
	end
end

function button:mouseup( x, y )
	if self.held then
		self.held = false

		self:animateZ( self.z, 3, .1 )

		if self.onClick then
			self:onClick()
		end

		return true
	end
end

return setmetatable( button, { __call = button.new } )
