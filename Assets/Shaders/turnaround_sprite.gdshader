shader_type spatial;

uniform sampler2D sprite_texture : filter_nearest, repeat_disable;
uniform sampler2D sprite_emissive : filter_nearest, repeat_disable;
uniform float frames : hint_range(0.0, 64.0, 1.0) = 8;
uniform float current_frame : hint_range(0.0, 64.0, 1.0) = 0;
uniform float emissive_power : hint_range(0.0, 10.0) = 1.0;

varying float frame;

void vertex() {
	mat4 inv_modelview = inverse(MODEL_MATRIX);
	
	// via https://godotshaders.com/shader/local-space-y-billboard-shader/
	vec3 up_vec = MODEL_MATRIX[1].xyz;
	
	vec4 ax = vec4(normalize(cross(up_vec, INV_VIEW_MATRIX[2].xyz)), 0.0);
	vec4 ay = vec4(up_vec.xyz, 0.0);
	vec4 az = vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, up_vec)), 0.0);
	
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(ax, ay, az, MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);	
	
	vec3 test = normalize((inv_modelview * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz);
	float atan_val = (atan(test.x, test.z) + PI);
	atan_val = mod(atan_val + PI/8.0 + PI, 2.0 * PI);
	atan_val = fract(atan_val/(2.0 * PI));
	frame = mod(clamp(atan_val, 0.0, 1.0), 1.0);
	frame = floor(frame * frames);
}

void fragment() {
	vec2 adjusted_uv = UV;
	float sprite_width = 1.0 / frames;
	float sprite_offset = sprite_width * frame;
	adjusted_uv.x = (UV.x * sprite_width) + sprite_offset;
	
	vec4 tex_sample = texture(sprite_texture, adjusted_uv);
	ALBEDO = tex_sample.rgb;
	ALPHA = tex_sample.a;

	vec4 emissive_sample = texture(sprite_emissive, adjusted_uv);
	EMISSION = emissive_sample.rgb * emissive_power * emissive_sample.a;
}