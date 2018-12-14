float blend_pinlight(float a, float b) {
  return b < 0.5 ? min(a, 2. * b) : max(a, 2. * (b - .5));
}

vec3 blend_pinlight(vec3 a, vec3 b) {
  return vec3(
    blend_pinlight(a.r, b.r),
    blend_pinlight(a.g, b.g),
    blend_pinlight(a.b, b.b)
  );
}

vec4 blend_pinlight(vec4 a, vec4 b) {
  return vec4((blend_pinlight(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_pinlight)
