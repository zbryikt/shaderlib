require! <[glslify]>
cloud = require "./sample/cloud"
<- window.addEventListener \load, _

shader = do
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")
    #pragma glslify: fbm = require("../../src/fbm.shader")
    #pragma glslify: quantize = require("../../src/quantize.shader")

    // Processing specific input
    uniform float uTime;
    uniform vec2 uResolution;

    void main() {
      vec3 uv = aspect_ratio(uResolution, 1);
      float z1, z2, z3;
      vec2 s1, s2, s3;
      uv.z = uv.z * 0.2;
      z1 = 1.2 * ( uv.x + 0.1 ) * pow(uv.y, .5 + cos(uTime) * 0.1) + pow(uv.y, 6. + 1. * sin(uTime));
      z2 = 1.2 * ( uv.x + 0.1 + uv.z) * pow(uv.y, .5 + cos(uTime) * 0.1) + pow(uv.y, 6. + 1. * sin(uTime));
      z3 = 1.2 * ( uv.x + 0.1 - uv.z) * pow(uv.y, .5 + cos(uTime) * 0.1) + pow(uv.y, 6. + 1. * sin(uTime));
      vec3 c = vec3(.2, .8, 1.);
      s1 = quantize(z1, 12.);
      s2 = quantize(z2, 12.);
      s3 = quantize(z3, 12.);
      c = c * (
        (s1.x - s1.y * 0.1) +
        (s2.x - s2.y * 0.1) +
        (s3.x - s3.y * 0.1)
      ) / 3.;

      gl_FragColor = vec4(c, 1.0);
    }
  '''


renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.init!
renderer.animate!
