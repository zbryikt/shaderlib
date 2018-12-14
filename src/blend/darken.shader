float blend_darken(float a, float b) {
  return min(a, b);
}

vec3 blend_darken(vec3 a, vec3 b) {
  return min(a, b);
}

vec4 blend_darken(vec4 a, vec4 b) {
  return vec4((blend_darken(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_darken)
