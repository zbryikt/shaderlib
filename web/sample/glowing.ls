require! <[glslify]>
cloud = require "./sample/cloud"
<- window.addEventListener \load, _

shader = do
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: noise = require('../../src/noise.shader')
    #pragma glslify: vignette = require('../../src/vignette.shader')
    uniform vec2 uResolution;
    uniform float uTime;
    uniform sampler2D uIn1;
    void main() {
      vec2 pos;
      float s, d;
      float c = 0.;
      float t = uTime * 1.;
      vec2 uv = gl_FragCoord.xy / uResolution.xy;
      uv.y = uv.y * uResolution.y / uResolution.x;
      uv = uv * 0.8 + vec2(.1, .1);
      for(int i=0;i<50;i++) {
        s = noise(float(i) * 9527.7259);
        s = pow(s, 2.5) * 194. + 6.;
        //s = s * s * s * 80. + 20.;
        pos = vec2(
          uv.x + 1. * noise(float(i) * 18132.456) + sin(float(i) + t * 1.2 + uv.y) * 0.03 + t * s * 0.001,
          uv.y + 136.4261 * noise(float(i) * 97523.332 + s) + t * s * 0.001
        );
        pos = vec2(
          mod(pos.x / s, .5 / s) - 0.25 / s,
          mod(pos.y / s, .5 / s) - 0.25 / s
        );
        d = clamp( (1. / s) - length( pos ) / (0.5 / s), 0., 0.01 * pow(s,.5));
        d = d * 300. * (pow(s/100., 2.) + 0.002);
        c += d;
      }
      float vg = vignette(1.1, 0.5, uv);
      //float vg = 1. - vignette(1.0, 0.5, uv);
      gl_FragColor = vec4(vg * (vec3(texture2D(uIn1, uv)) * 0.9 + vec3(clamp(c, 0., 1.)) * 0.8), 1.);
      //gl_FragColor = vg * (  vec4(vec3(clamp(c, 0., 1.)), 1.));
    }

  '''

#renderer = new ShaderRenderer [cloud, shader], {root: '#root .box:nth-child(1)'}
renderer = new ShaderRenderer [cloud, shader], {root: '#root'}
renderer.animate!
