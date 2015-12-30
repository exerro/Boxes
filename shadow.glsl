
extern number horizontal;
extern number vertical;

vec4 effect(vec4 colour, Image texture, vec2 tCoord, vec2 sCoord) {
	number left   = tCoord.x < horizontal ? tCoord.x / horizontal : 1;
	number right  = (1-tCoord.x) < horizontal ? (1-tCoord.x) / horizontal : 1;
	number top    = tCoord.y < vertical ? tCoord.y / vertical : 1;
	number bottom = (1-tCoord.y) < vertical ? (1-tCoord.y) / vertical : 1;

	return vec4( colour.r, colour.g, colour.b, colour.a * left * right * top * bottom );
}
