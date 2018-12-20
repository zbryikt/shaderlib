#pragma glslify: fbm = require('../func/fbm.glsl')
#define NUM_ITERATION 5.

float raster_cloud(vec2 uv, float t, vec2 dir, float delta) {
  float c = 0.;
  for(float i=1.;i<NUM_ITERATION;i++) {
    c += fbm(vec2(uv.x * i + t * pow(delta,i) * 0.001 * dir.x, uv.y * i + t * pow(delta, i) * 0.001 * dir.y));
  }
  c = c / (NUM_ITERATION - 2.);
  return c;
}

#pragma glslify: export(raster_cloud)
