vec3 level(vec3 c, float vmin, float vmax){
  return min(max(c - vec3(vmin), vec3(.0)) / vec3(vmax - vmin), vec3(1.));
}

#pragma glslify: export(level)
