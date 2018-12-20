/* z: pixel size */
vec3 aspect_ratio(vec2 res, int iscover) {
  // iscover: 0 = contains, 1 = cover
  float r;
  vec3 ret = vec3((gl_FragCoord.xy / res.xy),0);
  if(iscover == 0 ^^ res.x > res.y) {
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
