require! <[glslify]>

<- window.addEventListener \load, _

shader3 = do
  uniforms: {}
  vertexShader: """
  precision highp float;
  attribute vec3 position;
  void main() {
    gl_Position = vec4(position, 1.);
  }
  """
  fragmentShader: glslify '''
  precision highp float;
  #pragma glslify: high_pass = require('../../src/high_pass.shader')
  #pragma glslify: fxaa = require('../../src/fxaa.shader')
  #pragma glslify: grayscale = require('../../src/grayscale.shader')
  #pragma glslify: blur = require('../../src/blur/13.shader')
  #pragma glslify: sobel = require('../../src/sobel.shader')
  #pragma glslify: halftone = require('glsl-halftone')
  #pragma glslify: edge = require('glsl-edge-detection')
  uniform sampler2D uIn1;
  uniform vec2 uResolution;
  void main() {
    vec2 uv = vec2(gl_FragCoord.x / uResolution.x, 1. - gl_FragCoord.y / uResolution.y);
    float e = edge(uIn1, uv, uResolution);
    gl_FragColor = vec4(vec3(e),1.);
  }
  '''

shader2 = do
  uniforms: {}
  vertexShader: """
  precision highp float;
  attribute vec3 position;
  void main() {
    gl_Position = vec4(position, 1.);
  }
  """
  fragmentShader: glslify '''
  precision highp float;
  #pragma glslify: fbm = require('../../src/fbm.shader')
  uniform sampler2D uIn1;
  uniform vec2 uResolution;
  void main() {
    vec2 uv = vec2(gl_FragCoord.x / uResolution.x, gl_FragCoord.y / uResolution.y);
    vec4 c;
    gl_FragColor = vec4(1., 0., 0., 1.);
    c = vec4(texture2D(uIn1, uv));
    gl_FragColor = vec4(vec3(c) * fbm(uv * 10.), 1.);
  }
  '''

shader1 = do
  uniforms: do
    color: type: \3fv, value: [0,0,0]
  vertexShader: """
  precision highp float;
  uniform float uTime;
  attribute vec3 position;
  void main() {
    gl_Position = vec4(position, 1.);
  }
  """
  fragmentShader: glslify('''
  precision highp float;
  #pragma glslify: gradient = require('../../src/raster/gradient/3d1.shader')
  #pragma glslify: cloud = require('../../src/raster/cloud.shader')
  #pragma glslify: vignette = require('../../src/vignette.shader')
  //#pragma glslify: color_shift = require('../../src/color_shift.shader')
  uniform float uTime;
  uniform vec3 color;
  uniform vec2 uResolution;
  uniform sampler2D uImage;
  vec3 cc(vec2 uv, float t) {
    vec3 c = gradient(uv, vec3(1.,0.,0.), vec3(0.,1.,0.), vec3(0.,0.,1.), 3.);
    float d = cloud(uv, t, vec2(1., 0.), 3.);
    float e = vignette(1., 0.5, uv);
    return c * d * e;
  }
  #define color_shift(a,b,c,d,e,f) (a(b, d) + a(vec2(b.x - c, b.y), d) * e * 0.5 + a(vec2(b.x + c, b.y), d) * f * 0.5)
  void main() {
    float t = uTime * 10.;
    vec2 uv = vec2(gl_FragCoord.x / uResolution.x, gl_FragCoord.y / uResolution.y);
    vec3 o = color_shift(cc, uv, 0.1, t, vec3(1., 0., 0.), vec3(0., 0., 1.));
    gl_FragColor = vec4(o, 1.);
    //gl_FragColor = vec4(texture2D(uImage, uv));
  }
  ''')

shaders = [shader1]

renderer = new ShaderRenderer shaders, {root: '#root .box:nth-child(1)'}
renderer.animate!

renderer2 = new ShaderRenderer shader3, {root: '#root .box:nth-child(2)'}
renderer2.input renderer
renderer2.animate!
