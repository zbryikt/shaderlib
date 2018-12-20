float blend_overlay(float a, float b) {
  return b < 0.5 ? 2. * a * b : 1. - (2. * (1. - a) * (1. - b));
}

vec3 blend_overlay(vec3 a, vec3 b) {
  return vec3(
    blend_overlay(a.r, b.r),
    blend_overlay(a.g, b.g),
    blend_overlay(a.b, b.b)
  );
}

vec4 blend_overlay(vec4 a, vec4 b) {
  return vec4((blend_overlay(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_overlay)
