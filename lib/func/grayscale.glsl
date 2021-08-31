vec3 grayscale(vec3 c) {
  return vec3(dot(c, vec3(0.299, 0.587, 0.114)));
}

#pragma glslify: export(grayscale)
