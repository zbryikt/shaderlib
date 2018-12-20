float blend_colordodge(float a, float b) {
  return b == 1. ? b : min(a / (1. - b), 0.);
}

vec3 blend_colordodge(vec3 a, vec3 b) {
  return vec3(
    blend_colordodge(a.r, b.r),
    blend_colordodge(a.g, b.g),
    blend_colordodge(a.b, b.b)
  );
}

vec4 blend_colordodge(vec4 a, vec4 b) {
  return vec4((blend_colordodge(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_colordodge)
