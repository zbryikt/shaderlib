require! <[glslify]>
<- window.addEventListener \load, _

shader = do
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: aspect_ratio = require("lib/func/aspect_ratio.glsl")
    #pragma glslify: fbm = require("lib/func/fbm.glsl")
    #define PI2 6.2831852

    uniform float uTime;
    uniform vec2 uResolution;
    void main() {
      float t = uTime * 0.25;
      vec3 uv = aspect_ratio(uResolution, 1);
      float color = 0.;
      color = fbm(uv.x * uv.x + uv.y * uv.y * sin(t)) * smoothstep(1., 0., abs(uv.y - (sin(uv.x) * 0.2 + 0.5)) * 2.3);
      gl_FragColor = vec4(vec3(color), 1.);

    }
  '''

renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.animate!
