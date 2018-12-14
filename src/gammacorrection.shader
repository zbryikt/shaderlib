vec3 gammacorrect(vec3 c, float g){
  return pow(c, vec3(1./g));
}
