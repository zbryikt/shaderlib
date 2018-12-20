// Generated by LiveScript 1.3.1
var glslify, cloud;
glslify = require('glslify');
cloud = require("./sample/cloud");
window.addEventListener('load', function(){
  var shader, renderer;
  shader = {
    fragmentShader: glslify('precision highp float;\n#pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")\n#pragma glslify: fbm = require("../../src/fbm.shader")\n#pragma glslify: quantize = require("../../src/quantize.shader")\n\n// Processing specific input\nuniform float uTime;\nuniform vec2 uResolution;\n\nvoid main() {\n  vec3 uv = aspect_ratio(uResolution, 1);\n  float z1, z2, z3;\n  vec2 s1, s2, s3;\n  uv.z = uv.z * 0.2;\n  z1 = 1.2 * ( uv.x + 0.1 ) * pow(uv.y, .5 + cos(uTime) * 0.1) + pow(uv.y, 6. + 1. * sin(uTime));\n  z2 = 1.2 * ( uv.x + 0.1 + uv.z) * pow(uv.y, .5 + cos(uTime) * 0.1) + pow(uv.y, 6. + 1. * sin(uTime));\n  z3 = 1.2 * ( uv.x + 0.1 - uv.z) * pow(uv.y, .5 + cos(uTime) * 0.1) + pow(uv.y, 6. + 1. * sin(uTime));\n  vec3 c = vec3(.2, .8, 1.);\n  s1 = quantize(z1, 12.);\n  s2 = quantize(z2, 12.);\n  s3 = quantize(z3, 12.);\n  c = c * (\n    (s1.x - s1.y * 0.1) +\n    (s2.x - s2.y * 0.1) +\n    (s3.x - s3.y * 0.1)\n  ) / 3.;\n\n  gl_FragColor = vec4(c, 1.0);\n}')
  };
  renderer = new ShaderRenderer([shader], {
    root: '#root'
  });
  renderer.init();
  return renderer.animate();
});