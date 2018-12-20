vec3 sobel(sampler2D txt, vec2 uv, vec2 res) {
  float x = 1.0 / res.x;
  float y = 1.0 / res.y;
  vec4 h = vec4(.0), v = vec4(.0);
  h = v = texture2D(txt, vec2(uv.x + x, uv.y + y)) - texture2D(txt, vec2(uv.x - x, uv.y - y));
  h -= texture2D(txt, vec2(uv.x - x, uv.y)) * 2.;
  h += texture2D(txt, vec2(uv.x + x, uv.y)) * 2.;
  h -= texture2D(txt, vec2(uv.x - x, uv.y + y));
  h += texture2D(txt, vec2(uv.x + x, uv.y - y));
  v -= texture2D(txt, vec2(uv.x, uv.y - y)) * 2.;
  v += texture2D(txt, vec2(uv.x, uv.y + y)) * 2.;
  v -= texture2D(txt, vec2(uv.x + x, uv.y - y));
  v += texture2D(txt, vec2(uv.x - x, uv.y + y));
  return vec3(1. - sqrt(h * h + v * v));
}
#pragma glslify: export(sobel)
