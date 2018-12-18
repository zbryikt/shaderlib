// Generated by LiveScript 1.3.1
var glslify;
glslify = require('glslify');
module.exports = {
  fragmentShader: glslify('precision highp float;\n#pragma glslify: sobel = require(\'../../../src/sobel.shader\')\n\nuniform sampler2D uIn1;\nuniform vec2 uResolution;\nvoid main() {\n  vec2 uv = gl_FragCoord.xy / uResolution.xy;\n  //uv.y = uv.y * uResolution.y / uResolution.x;\n  gl_FragColor = vec4(sobel(uIn1, uv, uResolution), 1.);\n}')
};