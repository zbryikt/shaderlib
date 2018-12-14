require! <[glslify]>

<- window.addEventListener \load, _

shader = do
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
  #pragma glslify: cloud = require('../../src/raster/cloud.shader')
  uniform float uTime;
  uniform vec3 color;
  uniform vec2 uResolution;
  void main() {
    float t = uTime;
    vec2 uv = vec2(gl_FragCoord.x / uResolution.x, gl_FragCoord.y / uResolution.y);
    float c = cloud(uv, t, vec2(1.0, 0.1), 4.);
    gl_FragColor = vec4(c * color, 1.);
  }
  ''')

renderer = new shaderRenderer \#root, shader
renderer.animate (t) ->
  shader.uniforms.color.value = [1, 1, 1]
