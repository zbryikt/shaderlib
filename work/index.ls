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
  #pragma glslify: fbm = require('../shaderlib/src/fbm.shader')
  uniform float uTime;
  uniform vec3 color;
  uniform vec2 uResolution;
  void main() {
    float t = uTime;
    vec2 uv = vec2(gl_FragCoord.x / uResolution.x, gl_FragCoord.y / uResolution.y);
    vec3 c = vec3(0,0,0);
    for(float i=1.;i<5.;i++) {
      c += color * fbm(vec2(uv.x * i + t * pow(3.,i) * 0.001, uv.y * i));
    }
    gl_FragColor = vec4(c * 0.3, 1.);
  }
  ''')

renderer = new shaderRenderer \#root, shader
renderer.animate (t) ->
  shader.uniforms.color.value = [1, 1, 1]
