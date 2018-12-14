float blend_normal(float a, float b) {
  return b;
}

vec3 blend_normal(vec3 a, vec3 b) {
  return b;
}

vec4 blend_normal(vec4 a, vec4 b) {
  return vec4(vec3(b) * b.a + vec3(a) * (1. - b.a), a.a);
}

#pragma glslify: export(blend_normal)
