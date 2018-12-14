float blend_softlight(float a, float b) {
  return b < 0.5 ? 2. * a * b + a * a * (1. - 2. * b) : sqrt(a) * (2. * b - 1.) + 2. * a * (1. - b);
}

vec3 blend_softlight(vec3 a, vec3 b) {
  return vec3(
    blend_softlight(a.r, b.r),
    blend_softlight(a.g, b.g),
    blend_softlight(a.b, b.b)
  );
}

vec4 blend_softlight(vec4 a, vec4 b) {
  return vec4((blend_softlight(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_softlight)
