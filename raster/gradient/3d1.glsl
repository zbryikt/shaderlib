vec3 raster_gradient_3d1(vec2 uv, vec3 c1, vec3 c2, vec3 c3, float rate) {
  return (
    c1 * ( sin(rate * uv.x) * 0.5 + 0.5 ) + 
    c2 * ( sin(rate * uv.y) * 0.5 + 0.5 ) +
    c3 * ( sin(rate * uv.x * uv.y) * 0.5 + 0.5 )
  );
}

#pragma glslify: export(raster_gradient_3d1)
