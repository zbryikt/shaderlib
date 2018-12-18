require! <[glslify]>

module.exports = do
  fragmentShader: glslify '''
  precision highp float;
  #pragma glslify: sobel = require('../../../src/sobel.shader')

  uniform sampler2D uIn1;
  uniform vec2 uResolution;
  void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    //uv.y = uv.y * uResolution.y / uResolution.x;
    gl_FragColor = vec4(sobel(uIn1, uv, uResolution), 1.);
  }
  '''
