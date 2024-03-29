require! <[glslify]>
<- window.addEventListener \load, _

shader = do
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: aspect_ratio = require("lib/func/aspect_ratio.glsl")
    #pragma glslify: quantize = require("lib/func/quantize.glsl")
    #pragma glslify: fbm = require("lib/func/fbm.glsl")
    #pragma glslify: noise = require("glsl-noise/simplex/2d")
    #pragma glslify: gradient = require("lib/raster/gradient/3d1.glsl")

    uniform float uTime;
    uniform vec2 uResolution;

    void main() {
      vec3 uv = aspect_ratio(uResolution, 1);
      float f = pow(pow(uv.x, 2.) - pow(uv.y, 2.), 1.7);
      vec3 c2 = vec3(.06, .45, .83);
      vec3 c1 = vec3(.76, .91, .81);

      gl_FragColor = vec4(mix(c1, c2, f), 1.);
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
renderer = new shaderlib.renderer [shader], {root: '#root'}
renderer.init!
renderer.animate!
