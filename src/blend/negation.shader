float blend_negation(float a, float b) {
  return 1. - abs(1. - a - b);
}

vec3 blend_negation(vec3 a, vec3 b) {
  return vec3(1.) - abs(vec3(1.) - a - b);
}

vec4 blend_negation(vec4 a, vec4 b) {
  return vec4((blend_negation(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_negation)
