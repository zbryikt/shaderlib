float blend_screen(float a, float b) {
  return 1. - (1. - a) * (1. - b);
}

vec3 blend_screen(vec3 a, vec3 b) {
  return 1. - (1. - a) * (1. - b);
}

vec4 blend_screen(vec4 a, vec4 b) {
  return vec4((blend_screen(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_screen)
