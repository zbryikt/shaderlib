float blend_substract(float a, float b) {
  return max(a + b - 1., 0.);
}

vec3 blend_substract(vec3 a, vec3 b) {
  return max(a + b - 1., 0.);
}

vec4 blend_substract(vec4 a, vec4 b) {
  return vec4((blend_substract(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_substract)
