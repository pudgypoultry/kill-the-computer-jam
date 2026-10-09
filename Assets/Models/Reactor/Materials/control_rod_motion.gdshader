shader_type spatial;

uniform sampler2D albedo: filter_nearest_mipmap, source_color;
uniform sampler2D orm: filter_nearest_mipmap;
uniform sampler2D normal_map: filter_nearest_mipmap;

uniform sampler2D noise_tex;

uniform float wave_time;
uniform float max_move : hint_range(0.0, 5.0) = 1.0;
uniform float chaos : hint_range(0.0, 5.0) = 1.0;

void vertex() {
	float noise_sample = texture(noise_tex, vec2(INSTANCE_CUSTOM.b / 2.0 * PI, INSTANCE_CUSTOM.a / 13.0)).r;
	float noise_sample2 = texture(noise_tex, vec2(INSTANCE_CUSTOM.r / 13.0, INSTANCE_CUSTOM.g / 13.0)).r;
	VERTEX.y += max_move * noise_sample * sin(-wave_time * TAU + INSTANCE_CUSTOM.a + noise_sample2 * chaos);
}

void fragment() {
	vec3 albedo_sample = texture(albedo, UV).rgb;
	vec3 orm_sample = texture(orm, UV).rgb;
	vec3 normal_sample = texture(normal_map, UV).rgb;

	ALBEDO = albedo_sample;
	AO = orm_sample.r;
	ROUGHNESS = orm_sample.g;
	METALLIC = orm_sample.b;
	NORMAL_MAP = normal_sample;
}
