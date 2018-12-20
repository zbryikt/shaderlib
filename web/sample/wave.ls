require! <[glslify]>
cloud = require "./sample/cloud"
<- window.addEventListener \load, _

shader = do
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")
    #pragma glslify: noise = require("../../src/noise.shader")
    #define PI2 6.2831852

    uniform float uTime;
    uniform vec2 uResolution;
    void main() {
      float f = 0., v, d, t = uTime * 0.25;
      vec3 uv = aspect_ratio(uResolution, 1);
      vec3 c1 = vec3(1., 1., .2);
      vec3 c2 = vec3(1., .5, .3);
      vec3 c3 = vec3(.8, .1, .8);
      vec3 bk = vec3(.35, 0., .2);
      float c[3];

      for(float i=1.;i<8.;i++) {
        v = sin((uv.x + i * 0.3 + t * i * 0.1) * PI2 * (0.87 - i * 0.05)) * (sin(t + i) * 0.05 + i * 0.01) + 0.4;
        if(uv.y > v) {
          c[int(mod(i,3.))] += smoothstep(0.1, 0.0, uv.y - v) * 0.2;
        } else {
          c[int(mod(i,3.))] += smoothstep(0.001, 0.0, v - uv.y) * 0.2;
        }
      }
      gl_FragColor = vec4(
        c1 * c[0] +
        c2 * c[1] +
        c3 * c[2] + clamp((1. - (c[0] + c[1] + c[2])) * 1., 0., 1.) * bk,
        1.
      );
    }
  '''

renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.animate!
