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

    vec2 getpt(vec2 id, float t) {
      vec2 pt = vec2(noise(id.x + noise(id.y) * 625.788) * t, noise(id.y + noise(id.x) * 9527.145) * t);
      pt = vec2(cos(pt.x), sin(pt.y)) * 0.4;
      return pt;
    }
    void main() {
      float t = uTime * 2., f, d;
      float size = 20.;
      vec3 uv3 = aspect_ratio(uResolution, 0);
      vec2 uv = fract(vec2(uv3) * size) - 0.5;
      vec2 id = floor(vec2(uv3) * size);
      vec2 pt1, pt2, pt3;
      vec2 p[9];
      for(float i=-1.;i<=1.;i+=1.) {
        for(float j=-1.;j<=1.;j+=1.) {
          p[int(i * 3. + j + 4.)] = getpt(id + vec2(i, j), t) + vec2(i, j);
        }
      }
      d = length(uv - p[4]);
      f = smoothstep(0.09, 0.03, d);
      for(float i=0.;i<9.;i++) {
        f += line(uv, p[4], p[int(i)]) * smoothstep(0.7, 0.2, 0.4 * length(p[int(i)] - p[4]));
      }
      f += line(uv, p[1], p[3]) * smoothstep(0.6, 0.2, 0.4 * length(p[3] - p[1]));
      f += line(uv, p[1], p[5]) * smoothstep(0.6, 0.2, 0.4 * length(p[5] - p[1]));
      f += line(uv, p[7], p[3]) * smoothstep(0.6, 0.2, 0.4 * length(p[3] - p[7]));
      f += line(uv, p[7], p[5]) * smoothstep(0.6, 0.2, 0.4 * length(p[5] - p[7]));
      f = clamp(f, 0., 1.);
      vec3 fg = vec3(1., 1., 1.);
      //vec3 bg = vec3(.6, 0., .4);
      vec3 bg = vec3(.0, 0., .0);
      float c = cloud(vec2(uv3), t * 100., vec2(1., 0.), 0.1) * 0.9;
      gl_FragColor = vec4(mix(bg, fg, f) + c * vec3(1., 1., 1.), 1.);
    }
  '''

renderer = new ShaderRenderer [shader], {root: '#root'}
renderer.animate!
