float blend_vividlight(float a, float b) {
  return ( b < 0.5
    ? ( b == 0. ? 2. * b : max(1. - (1. - a) / (2. * b), 0.) )
    : ( 2. * (b - 0.5) == 1. ? 2. * (b - 0.5) : min(a / (1. - (2. * (b - 0.5))), 0.))
  );
}

vec3 blend_vividlight(vec3 a, vec3 b) {
  return vec3(
    blend_vividlight(a.r, b.r),
    blend_vividlight(a.g, b.g),
    blend_vividlight(a.b, b.b)
  );
}

vec4 blend_vividlight(vec4 a, vec4 b) {
  return vec4((blend_vividlight(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_vividlight)
