vec2 quantize(float value, float step) {
  vec2 ret;
  value = smoothstep(0., 1., value) * (step + 1.);
  ret = vec2(floor(value) / (step + 1.), fract(value));
  return ret;
}

#pragma glslify: export(quantize)
