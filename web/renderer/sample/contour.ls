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

    // Processing specific input
    uniform float uTime;
    uniform vec2 uResolution;

    void main() {
      float c, n1, n2, n3, t = uTime * 0.1;
      vec2 v1, v2, v3;
      vec3 fg = vec3(1., .7, .3), bk = vec3(.3, .1, .2);
      vec3 uv = aspect_ratio(uResolution, 1);
      uv.xy = uv.xy + vec2(sin(t), cos(t)) * .1;

      n1 = noise(0.5 * fbm(uv.xy + vec2(uv.z *  .1, .0) + t) + (uv.xy + vec2(uv.z *  .1, .0)) * 2.);
      n2 = noise(0.5 * fbm(uv.xy + t) + uv.xy * 2.);
      n3 = noise(0.5 * fbm(uv.xy + vec2(uv.z * -.1, .0) + t) + (uv.xy + vec2(uv.z * -.1, .0)) * 2.);
      v1 = quantize(pow(n1, .9), 4.);
      v2 = quantize(pow(n2, .9), 4.);
      v3 = quantize(pow(n3, .9), 4.);
      c = (v1.x + v2.x + v3.x - (v1.y + v2.y + v3.y) * 0.02) / 3.; // antialias

      gl_FragColor = vec4(mix(bk, fg, vec3(c)), 1.0);
    }
  '''


renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.init!
renderer.animate!
