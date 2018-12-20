// Generated by LiveScript 1.3.1
var glslify, cloud;
glslify = require('glslify');
cloud = require("./sample/cloud");
window.addEventListener('load', function(){
  var shader, renderer;
  shader = {
    fragmentShader: glslify('precision highp float;\n#pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")\n#pragma glslify: quantize = require("../../src/quantize.shader")\n#pragma glslify: fbm = require("../../src/fbm.shader")\n#pragma glslify: noise = require("glsl-noise/simplex/2d")\n\n// Processing specific input\nuniform float uTime;\nuniform vec2 uResolution;\n\nvoid main() {\n  float c, n1, n2, n3, t = uTime * 0.1;\n  vec2 v1, v2, v3;\n  vec3 fg = vec3(1., .7, .3), bk = vec3(.3, .1, .2);\n  vec3 uv = aspect_ratio(uResolution, 1);\n  uv.xy = uv.xy + vec2(sin(t), cos(t)) * .1;\n\n  n1 = noise(0.5 * fbm(uv.xy + vec2(uv.z *  .1, .0) + t) + (uv.xy + vec2(uv.z *  .1, .0)) * 2.);\n  n2 = noise(0.5 * fbm(uv.xy + t) + uv.xy * 2.);\n  n3 = noise(0.5 * fbm(uv.xy + vec2(uv.z * -.1, .0) + t) + (uv.xy + vec2(uv.z * -.1, .0)) * 2.);\n  v1 = quantize(pow(n1, .9), 4.);\n  v2 = quantize(pow(n2, .9), 4.);\n  v3 = quantize(pow(n3, .9), 4.);\n  c = (v1.x + v2.x + v3.x - (v1.y + v2.y + v3.y) * 0.02) / 3.; // antialias\n\n  gl_FragColor = vec4(mix(bk, fg, vec3(c)), 1.0);\n}')
  };
  renderer = new ShaderRenderer([shader], {
    root: '#root'
  });
  renderer.init();
  return renderer.animate();
});