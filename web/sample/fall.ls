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
      uv.y = 1. - uv.y;
      float t = uTime * .2;
      float m = 0., c=0.;
      for(float i=0.;i<5.;i+=2.) {

        float size = 3. + i;
        vec2 id = floor(uv.xy * size);
        vec2 ft = fract(uv.xy * size);
        m = smoothstep(.6, .4, ft.y * 0.6 + fbm((uv.x + i * 18. + t) * 27.1234) * 0.8 - 0.4);
        m = mod(100. - t  + ft.y * 0.6 + fbm(uv.x * 52.7134) * 0.4 - 0.2, .3);
        if(m > 0.5) m = 0.;
        if(m < 0.0) m = 0.;
        m = m * 2.;
        float f = fbm(uv.xy * 28981.515 + t);
        float g = fbm((uv.x + i * 32.) * 9890.181572 + t);
        if(g < .5) m = m * g;
        if(f < 0.6) m = m * f;
        c += m;
      }
      c = c * pow((1. -  uv.y), 2.);
      vec3 color = vec3(1., 1., 1.) * c;
      vec3 bk = mix(vec3(1., 1., 1.), vec3(1., .7, .2),  pow(length(uv.xy - vec2(.5, -.2)), 3.));
      gl_FragColor = vec4(color + bk, 1.);
    }
  '''

renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.init!
renderer.animate!
