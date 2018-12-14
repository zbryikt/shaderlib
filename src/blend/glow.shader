float blend_glow(float a, float b) {
  return a == 1. ? a : min(b * b / (1. - a), 1.);
}

vec3 blend_glow(vec3 a, vec3 b) {
  return vec3(
    blend_glow(a.r, b.r),
    blend_glow(a.g, b.g),
    blend_glow(a.b, b.b)
  );
}

vec4 blend_glow(vec4 a, vec4 b) {
  return vec4((blend_glow(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_glow)
