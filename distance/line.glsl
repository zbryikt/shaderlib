float distance_to_line(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a;
  vec2 n = b - a;
  return length(pa - clamp(dot(pa, n) / dot(n, n), 0., 1.) * n);
}

#pragma glslify: export(distance_to_line)
