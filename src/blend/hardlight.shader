float blend_hardlight(float a, float b) {
  return a < 0.5 ? 2. * b * a : 1. - (2. * (1. - b) * (1. - a));
}

vec3 blend_hardlight(vec3 a, vec3 b) {
  return vec3(
    blend_hardlight(a.r, b.r),
    blend_hardlight(a.g, b.g),
    blend_hardlight(a.b, b.b)
  );
}

vec4 blend_hardlight(vec4 a, vec4 b) {
  return vec4((blend_hardlight(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_hardlight)
