shader_type spatial;

// add texture
uniform sampler2D pattern;
uniform vec2 uv_scale = vec2( 1.0, 1.0 );

void fragment() {
	// Place fragment code here.
	vec4 pattern_tex = texture(pattern, UV * uv_scale);
	
	ALBEDO = pattern_tex.rgb;
}
