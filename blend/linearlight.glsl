float blend_linearlight(float a, float b) {
  return b < 0.5 ? max(a + 2. * b - 1., 0.) : min(a + 2. * (b - 0.5), 1.);
}

vec3 blend_linearlight(vec3 a, vec3 b) {
  return vec3(
    blend_linearlight(a.r, b.r),
    blend_linearlight(a.g, b.g),
    blend_linearlight(a.b, b.b)
  );
}

vec4 blend_linearlight(vec4 a, vec4 b) {
  return vec4((blend_linearlight(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_linearlight)
