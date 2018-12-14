vec3 wb(vec3 c, float threshold) {
  return vec3(dot(c, vec3(0.299, 0.587, 0.114)) > threshold ? 1. : 0.);
}

#pragma glslify: export(wb)
