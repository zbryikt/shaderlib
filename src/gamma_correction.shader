vec3 gamma_correct(vec3 c, float g){
  return pow(c, vec3(1./g));
}

#pragma glslify: export(gamma_correct)
