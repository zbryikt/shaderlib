float blend_phoenix(float a, float b) {
  return min(a, b) - max(a, b) + 1.;
}

vec3 blend_phoenix(vec3 a, vec3 b) {
  return min(a, b) - max(a, b) + 1.;
}

vec4 blend_phoenix(vec4 a, vec4 b) {
  return vec4((blend_phoenix(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_phoenix)
