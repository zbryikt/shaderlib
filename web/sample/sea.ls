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
      vec3 uv = aspect_ratio(uResolution, 1);
      float t = uTime * .2;
      float len = length(uv.xy - vec2(.5, 1.));
      float c = smoothstep(1., .2, len);
      float a = (acos((uv.y - 1.) / len) + 1.23456) * 4.326;
      float p = .6 + fbm((fbm(a) + t) * 1.258) * .5 + .1 * pow(fbm(t + uv.x), .5);
      float m = 0.;
      for(float i=0.;i<4.;i++) {
        float size = 2. + i * i * 4.;
        vec2 id = floor(uv.xy * size);
        vec2 ft = fract(uv.xy * size);
        float n = fbm(id + id.x * id.y + i);
        float n2 = n * (6.28 + t);

        vec2 pt = vec2(
          0.5 + 0.35 * sin(n2 + id.y),
          0.5 + 0.35 * cos(n2 + id.x)
        );

        float b = n * 0.12;
        float f = n * 1.;
        float r = fract(n * 2898.35);
        if(r < 0.4) {
          m += smoothstep(
            b * (1. + f), b * (1. - f), length(ft - pt)
          ) * (i + 1.) / 13.; //(1. - pow(f, .5));
        }

      }
      vec3 color1 = vec3(1., .7, .1) * c * p;
      vec3 color2 = vec3(1., 1., 1.) * m * p;
      vec3 bk = vec3(.4, .3, .7);
      gl_FragColor = vec4(color1 + color2 + bk, 1.);
    }
  '''


renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.init!
renderer.animate!
