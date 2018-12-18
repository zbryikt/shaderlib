// Generated by LiveScript 1.3.1
var glslify, cloud;
glslify = require('glslify');
cloud = require("./sample/cloud");
window.addEventListener('load', function(){
  var shader, renderer;
  shader = {
    fragmentShader: glslify('precision highp float;\n#pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")\n#pragma glslify: fbm = require("../../src/fbm.shader")\n\n// Processing specific input\nuniform float uTime;\nuniform vec2 uResolution;\n\nvoid main() {\n  vec3 uv = aspect_ratio(uResolution, 1);\n  float c = 0.;\n  float t, time = uTime;\n  vec3 bk, fg;\n  for(float i=1.;i<4.;i++) {\n    t = time / pow(i, 1.5);\n    // dual side\n    //c += fbm(pow(uv.y, 4.) + fbm(vec2(uv.x * (10. * i) + t, uv.y * (10. * i)))) * pow(sin(uv.y * 6.28),3.);\n    // single side\n    c += fbm(pow(uv.y, 4.) + fbm(vec2(uv.x * (10. * i) + t, uv.y * (10. * i))) * uv.y) * pow(uv.y + .3,2.5);\n  }\n  bk = vec3(0., .1, .3);\n  fg = vec3(1., .7, .5);\n  gl_FragColor = vec4(mix(bk, fg, c), 1.);\n\n}')
  };
  renderer = new ShaderRenderer([shader], {
    root: '#root'
  });
  return renderer.animate();
});