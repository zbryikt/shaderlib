require! <[glslify]>
cloud = require "./sample/cloud"
<- window.addEventListener \load, _

shader = do
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")
    #pragma glslify: noise = require("../../src/noise.shader")
    #pragma glslify: cloud = require("../../src/raster/cloud.shader")
    #pragma glslify: vignette = require("../../src/vignette.shader")

    uniform float uTime;
    uniform vec2 uResolution;
    
    float distance_to_line(vec2 p, vec2 a, vec2 b) {
      vec2 pa = p - a;
      vec2 n = b - a;
      return length(pa - clamp(dot(pa, n) / dot(n, n), 0., 1.) * n);
    }

    float line(vec2 p, vec2 a, vec2 b) {
      float d = distance_to_line(p, a, b);
      return clamp(smoothstep(0.02, 0.0, d), 0.0, 0.9);
    }

    vec2 getpt(vec2 id, float t, float layer) {
      vec2 pt = vec2(noise(id.x + noise(id.y) * 625.788 + layer) * t, noise(id.y + noise(id.x) * 9527.145) * t);
      pt = vec2(cos(pt.x), sin(pt.y)) * 0.2;
      return pt;
    }

    void main() {
      float t = uTime * 1. + 1324.78, f, d;
      float size = 20., s;
      vec3 uv3 = aspect_ratio(uResolution, 0);
      vec2 uv, id, pt, duv;
      f = 0.;
      for(float i=0.;i<3.;i++) {
        size = 11. - 3. * i;
        duv = vec2(uv3) + t * 0.6 / size + i * 0.2;
        uv = fract(vec2(duv) * size) - 0.5;
        id = floor(vec2(duv) * size);
        s = noise(id) * 0.2;
        pt = getpt(id, t, i);
        d = length(uv - pt);
        f += smoothstep(0.04 + 0.06 * i + s, 0.03 + 0.02 * i + s, d) * (3.- i)/10.;

      }
      vec3 fg = vec3(1., 1., 1.);
      vec3 bg = vec3(.2, .5, .8);
      float c = cloud(vec2(uv3), t * 100., vec2(1., 0.), 0.1) * 0.9;
      gl_FragColor = vec4(mix(bg, fg, f) + c * vec3(.5, .8, .4), 1.);
    }
  '''

renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.animate!
