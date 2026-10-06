shader_type spatial;

uniform sampler2D albedo : filter_nearest_mipmap, source_color;
uniform sampler2D orm : filter_nearest_mipmap;
uniform sampler2D normal_map : filter_nearest_mipmap;

uniform sampler2D tiling_albedo : filter_nearest_mipmap, source_color;
uniform sampler2D tiling_orm : filter_nearest_mipmap;
uniform sampler2D tiling_normal_map : filter_nearest_mipmap;

uniform float tiling_amount : hint_range(1.0, 10.0) = 1.0;

// RNM blending via the old classic: https://blog.selfshadow.com/publications/blending-in-detail/
vec3 blend_normals(vec3 base_normals, vec3 tiling_normals)
{
	vec3 reconstructed_base = base_normals;
	float normal_length = length(base_normals);
	reconstructed_base.z = sqrt(1.0 - (normal_length * normal_length));

	vec3 reconstructed_tiling = tiling_normals;
	normal_length = length(tiling_normals);
	reconstructed_tiling.z = sqrt(1.0 - (normal_length * normal_length));

	reconstructed_base = reconstructed_base * vec3( 2,  2, 2) + vec3( -1,  -1, 0);
    reconstructed_tiling = reconstructed_tiling * vec3(-2, -2, 2) + vec3(1, 1, -1);
    vec3 result = reconstructed_base * dot(reconstructed_base, reconstructed_tiling) / reconstructed_base.z - reconstructed_tiling;
	return result * 0.5 + 0.5;
}

void fragment() {
	vec3 albedo_sample = texture(albedo, UV).rgb;
	vec3 orm_sample = texture(orm, UV).rgb;
	vec3 normal_sample = texture(normal_map, UV).rgb;

	vec3 tiling_albedo_sample = texture(tiling_albedo, UV2 * tiling_amount).rgb;
	vec3 tiling_orm_sample = texture(tiling_orm, UV2 * tiling_amount).rgb;
	vec3 tiling_normal_sample = texture(tiling_normal_map, UV2 * tiling_amount).rgb;

	ALBEDO = albedo_sample * tiling_albedo_sample;
	AO = orm_sample.r * tiling_orm_sample.r;
	ROUGHNESS = tiling_orm_sample.g;
	METALLIC = tiling_orm_sample.b;
	vec3 blended_normals = blend_normals(normal_sample, tiling_normal_sample);
	NORMAL_MAP = blended_normals;
}
