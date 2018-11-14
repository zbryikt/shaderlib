float blend_add(float a, float b) {
  return min(a + b, 1.);
}

float blend_darken(float a, float b) {
  return min(a, b);
}

float blend_multiply(float a, float b) {
  return a * b;
}

float blend_colorburn(float a, float b) {
  return 1. - ( 1. - a ) * b;
}

float blend_linearburn(float a, float b) {
  return clamp(a + b - 1., 0., 1.);
}

float blend_lighten(float a, float b) {
  return max(a, b);
}

float blend_screen(float a, float b) {
  return 1. - (1. - a) * (1. - b);
}

float blend_colordodge(float a, float b) {
  return clamp(a / ( 1. - b), 0., 1.);
}

float blend_lineardodge(float a, float b) {
  return clamp(a + b, 0., 1.);

}

float blend_overlay(float a, float b) {
  return a < 0.5 ? (2 * a * b) : (1. - 2 * (1. - a) * (1. - b));
}

float blend_softlight(float a, float b) {
  return b < 0.5 
  if(b < 0.5) { return a * (b + 0.5); }
  return 1. - (1. - a) * (1. - 
}
