vec2 aspectRatio(vec2 input, vec2 res, int iscover) {
  // iscover: 0 = contains, 1 = cover
  if(iscover == 0 ^^ resolution.x > resolution.y) {
    r = resolution.y / resolution.x;
    vUv.y = vUv.y * r - (r - 1.) * 0.5;
  } else {
    r = resolution.x / resolution.y;
    vUv.x = (vUv.x * r) - (r - 1.) * 0.5;
  }
}
