float blend_colorburn(float a, float b) {
  return b == 0. ? b : max(1. - (1. - a) / b, 0.);
}

vec3 blend_colorburn(vec3 a, vec3 b) {
  return vec3(
    blend_colorburn(a.r, b.r),
    blend_colorburn(a.g, b.g),
    blend_colorburn(a.b, b.b)
  );
}

vec4 blend_colorburn(vec4 a, vec4 b) {
  return vec4((blend_colorburn(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_colorburn)
