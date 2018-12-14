float blend_difference(float a, float b) {
  return abs(a - b);
}

vec3 blend_difference(vec3 a, vec3 b) {
  return abs(a - b);
}

vec4 blend_difference(vec4 a, vec4 b) {
  return vec4((blend_difference(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_difference)
