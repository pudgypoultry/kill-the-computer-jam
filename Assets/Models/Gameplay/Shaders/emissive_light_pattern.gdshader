shader_type spatial;

uniform sampler2D albedo : filter_nearest_mipmap, source_color;
uniform sampler2D orm : filter_nearest_mipmap;
uniform sampler2D normal_map : filter_nearest_mipmap;
uniform sampler2D emissive_mask : filter_nearest_mipmap;

uniform vec3 emissive_color : source_color;
uniform float emissive_strength : hint_range(0.0, 20.0) = 5.0;

uniform float grid_1_1: hint_range(0.0, 1.0) = 0.0;
uniform float grid_2_1: hint_range(0.0, 1.0) = 0.0;
uniform float grid_3_1: hint_range(0.0, 1.0) = 0.0;
uniform float grid_4_1: hint_range(0.0, 1.0) = 0.0;
uniform float grid_5_1: hint_range(0.0, 1.0) = 0.0;

uniform float grid_1_2: hint_range(0.0, 1.0) = 0.0;
uniform float grid_2_2: hint_range(0.0, 1.0) = 0.0;
uniform float grid_3_2: hint_range(0.0, 1.0) = 0.0;
uniform float grid_4_2: hint_range(0.0, 1.0) = 0.0;
uniform float grid_5_2: hint_range(0.0, 1.0) = 0.0;

uniform float grid_1_3: hint_range(0.0, 1.0) = 0.0;
uniform float grid_2_3: hint_range(0.0, 1.0) = 0.0;
uniform float grid_3_3: hint_range(0.0, 1.0) = 0.0;
uniform float grid_4_3: hint_range(0.0, 1.0) = 0.0;
uniform float grid_5_3: hint_range(0.0, 1.0) = 0.0;

uniform float grid_1_4: hint_range(0.0, 1.0) = 0.0;
uniform float grid_2_4: hint_range(0.0, 1.0) = 0.0;
uniform float grid_3_4: hint_range(0.0, 1.0) = 0.0;
uniform float grid_4_4: hint_range(0.0, 1.0) = 0.0;
uniform float grid_5_4: hint_range(0.0, 1.0) = 0.0;

uniform float grid_1_5: hint_range(0.0, 1.0) = 0.0;
uniform float grid_2_5: hint_range(0.0, 1.0) = 0.0;
uniform float grid_3_5: hint_range(0.0, 1.0) = 0.0;
uniform float grid_4_5: hint_range(0.0, 1.0) = 0.0;
uniform float grid_5_5: hint_range(0.0, 1.0) = 0.0;

float mask_threshold(vec2 in_value, vec2 mask_value, float threshold)
{
	float r_val = step(mask_value.r - threshold, in_value.r) * step(1.0 - (mask_value.r + threshold), 1.0 - in_value.r);
	float g_val = step(mask_value.g - threshold, in_value.g) * step(1.0 - (mask_value.g + threshold), 1.0 - in_value.g);
	
	return r_val * g_val;
}

void fragment() {
	vec3 albedo_sample = texture(albedo, UV).rgb;
	vec3 orm_sample = texture(orm, UV).rgb;
	vec3 normal_sample = texture(normal_map, UV).rgb;
	vec4 emissive_sample = texture(emissive_mask, UV);
	
	ALBEDO = albedo_sample;
	AO = orm_sample.r;
	ROUGHNESS = orm_sample.g;
	METALLIC = orm_sample.b;
	NORMAL_MAP = normal_sample.rgb;

	vec3 emissive_total = emissive_color * emissive_strength * emissive_sample.a;
	
	float threshold = 0.05;
	
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.0, 0.0), threshold) * grid_1_1;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.25, 0.0), threshold) * grid_2_1;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.5, 0.0), threshold) * grid_3_1;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.75, 0.0), threshold) * grid_4_1;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(1.0, 0.0), threshold) * grid_5_1;

	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.0, 0.25), threshold) * grid_1_2;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.25, 0.25), threshold) * grid_2_2;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.5, 0.25), threshold) * grid_3_2;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.75, 0.25), threshold) * grid_4_2;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(1.0, 0.25), threshold) * grid_5_2;

	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.0, 0.5), threshold) * grid_1_3;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.25, 0.5), threshold) * grid_2_3;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.5, 0.5), threshold) * grid_3_3;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.75, 0.5), threshold) * grid_4_3;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(1.0, 0.5), threshold) * grid_5_3;

	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.0, 0.75), threshold) * grid_1_4;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.25, 0.75), threshold) * grid_2_4;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.5, 0.75), threshold) * grid_3_4;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.75, 0.75), threshold) * grid_4_4;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(1.0, 0.75), threshold) * grid_5_4;

	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.0, 1.0), threshold) * grid_1_5;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.25, 1.0), threshold) * grid_2_5;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.5, 1.0), threshold) * grid_3_5;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(0.75, 1.0), threshold) * grid_4_5;
	EMISSION += emissive_total * mask_threshold(emissive_sample.rg, vec2(1.0, 1.0), threshold) * grid_5_5;
}