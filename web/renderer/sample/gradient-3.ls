require! <[glslify]>
cloud = require "./sample/cloud"
<- window.addEventListener \load, _

shader = do
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")
    #pragma glslify: quantize = require("../../src/quantize.shader")
    #pragma glslify: fbm = require("../../src/fbm.shader")
    #pragma glslify: noise = require("glsl-noise/simplex/2d")
    #pragma glslify: gradient = require("../../src/raster/gradient/3d1.shader")

    uniform float uTime;
    uniform vec2 uResolution;

    void main() {
      vec3 uv = aspect_ratio(uResolution, 1);
      vec3 c = vec3(
        pow(0. + uv.x, 0.7) * pow(0. + uv.y, 1.0),
        pow(1. - uv.x, 1.0) * (1. - length(0.5 - uv.y) * .2),
        pow(0. + uv.x, 0.8) * pow(1. - uv.y, 0.5)
      );
      vec3 c1 = vec3(1., 1., .2);
      vec3 c2 = vec3(1., .3, .3);
      vec3 c3 = vec3(.9, .3, .7);
      gl_FragColor = vec4(c.x * c1 + c.y * c2 + c.z * c3, 1.);
    }
  '''

/*
vec3 raster_gradient_3d1(vec2 uv, vec3 c1, vec3 c2, vec3 c3, float rate) {
  return (
    c1 * ( sin(rate * uv.x) * 0.5 + 0.5 ) + 
    c2 * ( sin(rate * uv.y) * 0.5 + 0.5 ) +
    c3 * ( sin(rate * uv.x * uv.y) * 0.5 + 0.5 )
  );
}
*/
renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.init!
renderer.animate!
