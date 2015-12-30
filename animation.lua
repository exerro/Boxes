
local animations = {}

local function ease( u, d, t )
	return u + d * ( 3 * t * t - 2 * t * t * t )
end

local animation = {}

function animation.new( name, initial, final, duration, callback, easing )
	animations[name] = {
		initial = initial;
		difference = final - initial;
		duration = duration;
		clock = 0;
		callback = callback;
		easing = easing or ease;
	}
end

function animation.update( dt )
	local k, v = next( animations )
	local finished = {}

	while k do
		v.callback( v.easing( v.initial, v.difference, v.clock / v.duration ) )
		v.clock = v.clock + dt

		if v.clock > v.duration then
			finished[#finished + 1] = k
		end

		k, v = next( animations, k )
	end

	for i = 1, #finished do
		animations[finished[i]] = nil
	end
end

return animation
