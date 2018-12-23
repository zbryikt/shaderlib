/* z: pixel size */
vec3 aspect_ratio(vec2 res, int iscover) {
  // iscover: 0 = contains, 1 = cover, 2 = stretch
  float r;
  vec3 ret = vec3((gl_FragCoord.xy / res.xy), 0.);
  if(iscover == 2) {
    ret.z = 1. / max(res.x, res.y);
  } else if(iscover == 0 ^^ res.x > res.y) {
    r = res.y / res.x;
    ret.y = ret.y * r - (r - 1.) * 0.5;
    ret.z = 1. / (iscover == 0 ? res.x : res.y);
  } else {
    r = res.x / res.y;
    ret.x = (ret.x * r) - (r - 1.) * 0.5;
    ret.z = 1. / (iscover == 0 ? res.y : res.x);
  } 
  return ret;
}

#pragma glslify: export(aspect_ratio)

/*
ret.y = ret.y * res.y / res.x
ret.x = ret.x * res.x / res.x
ret.xy = ret.xy * res.yx / max(res.x, res.y)

float base;
base = res.xy / (iscover == 0 ? min(res.x, res.y) : max(res.x, res.y));
ret.z = 1. / base;
ret.xy = ( ret.xy * res.yx / base ) - ret.xy / base;
*/
