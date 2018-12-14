float rand(float v) {
  return fract(sin(v * 43758.5453));
}

float randalt(float v) {
  float y = fract(sin(v * 43758.5453) * 7533967.);
  return y * 2. - (y > 0.5?1.:0.);
}

float rand(vec2 co) {
  return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 rand2(vec2 co) {
  co = vec2(
    dot(co, vec2(127.1, 311.7)),
    dot(co, vec2(269.5, 183.3))
  );
  return -1. + 2. * fract(sin(co) * 43758.5453123);
}

float noise(vec2 co) {
  vec2 i = floor(co);
  vec2 f = fract(co);
  vec2 u = f * f * (3. - 2. * f);
  return mix(
    mix( dot(rand2(i + vec2(0.,0.)), f - vec2(0.,0.)),
         dot(rand2(i + vec2(1.,0.)), f - vec2(1.,0.)), u.x),
    mix( dot(rand2(i + vec2(0.,1.)), f - vec2(0.,1.)),
         dot(rand2(i + vec2(1.,1.)), f - vec2(1.,1.)), u.x), u.y
  );
}

