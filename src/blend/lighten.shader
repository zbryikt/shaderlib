float blend_lighten(float a, float b) {
  return max(a, b);
}

vec3 blend_lighten(vec3 a, vec3 b) {
  return max(a, b);
}

vec4 blend_lighten(vec4 a, vec4 b) {
  return vec4((blend_lighten(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_lighten)
