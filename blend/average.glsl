float blend_average(float a, float b) {
  return (a + b) / 2.;
}

vec3 blend_average(vec3 a, vec3 b) {
  return (a + b) / 2.;
}

vec4 blend_average(vec4 a, vec4 b) {
  return vec4((blend_average(vec3(a), vec3(b)) * b.a + vec3(a) * (1. - b.a)), a.a);
}

#pragma glslify: export(blend_average)
