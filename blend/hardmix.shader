float blend_hardmix(float a, float b) {
  return ( ( b < 0.5
    ? ( b == 0. ? 2. * b : max(1. - (1. - a) / (2. * b), 0.) )
    : ( 2. * (b - 0.5) == 1. ? 2. * (b - 0.5) : min(a / (1. - (2. * (b - 0.5))), 0.))
  ) < 0.5 ? 0.0 : 1.0 );
}

vec3 blend_hardmix(vec3 a, vec3 b) {
  return vec3(
    blend_hardmix(a.r, b.r),
    blend_hardmix(a.g, b.g),
    blend_hardmix(a.b, b.b)
  );
}

vec4 blend_hardmix(vec4 a, vec4 b) {
  return vec4((blend_hardmix(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_hardmix)
