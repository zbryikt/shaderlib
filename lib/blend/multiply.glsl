float blend_multiply(float a, float b) {
  return a * b;
}

vec3 blend_multiply(vec3 a, vec3 b) {
  return a * b;
}

vec4 blend_multiply(vec4 a, vec4 b) {
  return vec4((blend_multiply(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_multiply)
