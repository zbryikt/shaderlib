float blend_reflect(float a, float b) {
  return b == 1. ? b : min(a * a / (1. - b), 1.);
}

vec3 blend_reflect(vec3 a, vec3 b) {
  return vec3(
    blend_reflect(a.r, b.r),
    blend_reflect(a.g, b.g),
    blend_reflect(a.b, b.b)
  );
}

vec4 blend_reflect(vec4 a, vec4 b) {
  return vec4((blend_reflect(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_reflect)
