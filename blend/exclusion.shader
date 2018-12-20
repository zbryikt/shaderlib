float blend_exclusion(float a, float b) {
  return a + b - 2. * a * b;
}

vec3 blend_exclusion(vec3 a, vec3 b) {
  return a + b - 2. * a * b;
}

vec4 blend_exclusion(vec4 a, vec4 b) {
  return vec4((blend_exclusion(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_exclusion)
