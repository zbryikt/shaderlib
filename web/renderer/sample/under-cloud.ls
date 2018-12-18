require! <[glslify]>
cloud = require "./sample/cloud"
<- window.addEventListener \load, _

shader = do
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")
    #pragma glslify: fbm = require("../../src/fbm.shader")

    // Processing specific input
    uniform float uTime;
    uniform vec2 uResolution;

    void main() {
      vec3 uv = aspect_ratio(uResolution, 1);
      float c = 0.;
      float t, time = uTime;
      vec3 bk, fg;
      for(float i=1.;i<4.;i++) {
        t = time / pow(i, 1.5);
        // dual side
        //c += fbm(pow(uv.y, 4.) + fbm(vec2(uv.x * (10. * i) + t, uv.y * (10. * i)))) * pow(sin(uv.y * 6.28),3.);
        // single side
        c += fbm(pow(uv.y, 4.) + fbm(vec2(uv.x * (10. * i) + t, uv.y * (10. * i))) * uv.y) * pow(uv.y + .3,2.5);
      }
      bk = vec3(0., .1, .3);
      fg = vec3(1., .7, .5);
      gl_FragColor = vec4(mix(bk, fg, c), 1.);

    }
  '''

renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.animate!
