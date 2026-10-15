shader_type spatial;

uniform vec4 albedo : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 0.0;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float noise_scale : hint_range(0.0, 20.0) = 1.0;

uniform sampler3D noise;

uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float offset : hint_range(0.0, 5.0) = 0.1;
uniform float period : hint_range(0.0, 10.0) = 1.0;
uniform float normal_bend : hint_range(0.0, 1.0) = 0.0;

uniform float band_1 : hint_range(0.0, 1.0) = 0.0;
uniform float band_2 : hint_range(0.0, 1.0) = 0.0;
uniform float band_3 : hint_range(0.0, 1.0) = 0.0;
uniform float band_4 : hint_range(0.0, 1.0) = 0.0;

vec3 computeCurl(vec3 p){
  const float eps = 1e-1;

  float dx = texture(noise, p + vec3(eps, 0, 0)).r - texture(noise, p - vec3(eps, 0, 0)).r;
  float dy = texture(noise, p + vec3(0, eps, 0)).r - texture(noise, p - vec3(0, eps, 0)).r;
  float dz = texture(noise, p + vec3(0, 0, eps)).r - texture(noise, p - vec3(0, 0, eps)).r;

  vec3 noiseGrad0 = vec3(dx, dy, dz) / (2.0 * eps);

  // Offset position by a random value for second uncorrelated noise read
  p += 1008.5;

  dx = texture(noise, p + vec3(eps, 0, 0)).r - texture(noise, p - vec3(eps, 0, 0)).r;
  dy = texture(noise, p + vec3(0, eps, 0)).r - texture(noise, p - vec3(0, eps, 0)).r;
  dz = texture(noise, p + vec3(0, 0, eps)).r - texture(noise, p - vec3(0, 0, eps)).r;

  vec3 noiseGrad1 = vec3(dx, dy, dz) / (2.0 * eps);

  vec3 curl = cross(noiseGrad0, noiseGrad1);

  return normalize(curl);
}

float band_amt(float theta, float band)
{
	float bandwidth = PI/4.0;
	float band_edge = PI/16.0;
	float result = smoothstep(bandwidth * band - band_edge, bandwidth * band + band_edge, theta);
	result -= smoothstep(bandwidth * (band + 1.0) - band_edge, bandwidth * (band + 1.0) + band_edge, theta);
	return sqrt(clamp(result, 0.0, 1.0));
}

vec4 compute_vertex(vec3 vertex, float perturb_theta, float perturb_phi)
{
	vec3 v_normalized = normalize(vertex);
	
	float r = sqrt(vertex.x * vertex.x + vertex.y * vertex.y + vertex.z * vertex.z);
	float theta = acos(v_normalized.y) + perturb_theta;
	float phi = atan(v_normalized.z, v_normalized.x) + perturb_phi;

	float band_scale = band_amt(theta, 0.0) * band_1;
	band_scale += band_amt(theta, 1.0) * band_2;
	band_scale += band_amt(theta, 2.0) * band_3;
	band_scale += band_amt(theta, 3.0) * band_4;

	vec3 pre_transform_vertex;
	
	pre_transform_vertex.x = sin(theta) * cos(phi);
	pre_transform_vertex.y = cos(theta);
	pre_transform_vertex.z = sin(theta) * sin(phi);	
	
	vec3 curl = computeCurl(pre_transform_vertex + vec3(0.0, 0.0, TIME * speed) * period) * offset;

	r += curl.x * band_scale;

	vertex.x = r * sin(theta) * cos(phi);
	vertex.y = r * cos(theta);
	vertex.z = r * sin(theta) * sin(phi);	
	
	return vec4(vertex, theta);
}

void vertex() {	
	float perturb_amt = PI / 32.0;
	
	vec4 vert_result = compute_vertex(VERTEX, 0.0, 0.0);

	VERTEX = vert_result.xyz;
	
	vec3 vertex_a = compute_vertex(VERTEX, -perturb_amt, 0.0).xyz;
	vec3 vertex_b = compute_vertex(VERTEX, 0.0, perturb_amt).xyz;
	
	mat3 tangent_mat = mat3(NORMAL, TANGENT, BINORMAL);
	
	vec3 tangent = normalize(vertex_a - VERTEX);
	vec3 bitangent = normalize(vertex_b - VERTEX);
	
	NORMAL = normalize(mix(NORMAL, cross(tangent, bitangent), normal_bend));
}

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = roughness;
	METALLIC = metallic;	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
