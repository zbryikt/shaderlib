float vignette(float max, float amount, vec2 uv) {
  return max - length(uv - .5) * amount;
}
#pragma glslify: export(vignette)
