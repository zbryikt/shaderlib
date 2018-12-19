require! <[glslify]>
cloud = require "./sample/cloud"
<- window.addEventListener \load, _

shader1 = do
  render: (program, t) ->
    gl = renderer.gl
    gl.bindBuffer gl.ARRAY_BUFFER, program.data.buffer
    positionLocation = gl.getAttribLocation program.obj, "position"
    gl.enableVertexAttribArray positionLocation
    gl.vertexAttribPointer positionLocation, 3, gl.FLOAT, false, 0, 0

    gl.bindFramebuffer gl.FRAMEBUFFER, null
    gl.clearColor 0,0,0,1
    gl.clear gl.COLOR_BUFFER_BIT
    gl.drawArrays gl.TRIANGLES, 0, 6
  vertexShader: '''
  attribute vec3 position;
  uniform float uTime;
  void main() {
    gl_PointSize = 10.;
    vec3 pos = position;
    gl_Position = vec4(pos, 1.);
  }
  '''
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
      c = pow(smoothstep(1., 0., length(vec2(uv))), 1.5) * fbm(uv * 7.) * 2.5;
      //c = smoothstep(0.5, 0., clamp(length( gl_PointCoord - 0.5 ), 0., 1.));
      gl_FragColor = vec4(c * vec3(1., .1, .2), 1.0);
    }
  '''


shader2 = do
  buffer: (program) ->
    gl = renderer.gl
    program.data.buffer = buffer = gl.createBuffer!
    gl.bindBuffer gl.ARRAY_BUFFER, buffer
    arr = []
    for i from 0 til 800
      a = Math.random! * Math.PI * 0.5
      r = Math.pow(Math.random!, 0.7) * 2
      #if r > 1.0 => r = 1.0 + Math.pow(Math.random!, 2) * 2
      arr ++= [ Math.cos(a) * r - 1, Math.sin(a) * r - 1, 0 ]
      #arr ++= [Math.random! * 2 - 1, Math.random! * 2 - 1, 0]
    gl.bufferData( gl.ARRAY_BUFFER, new Float32Array(arr), gl.STATIC_DRAW)
    pobj = program.obj
    positionLocation = gl.getAttribLocation pobj, "position"
    gl.enableVertexAttribArray positionLocation
    gl.vertexAttribPointer positionLocation, 3, gl.FLOAT, false, 0, 0
    gl.blendFunc gl.SRC_ALPHA, gl.ONE
    gl.enable gl.BLEND
    gl.disable gl.DEPTH_TEST
  render: (program, t) ->
    gl = renderer.gl
    gl.bindBuffer gl.ARRAY_BUFFER, program.data.buffer
    positionLocation = gl.getAttribLocation program.obj, "position"
    gl.enableVertexAttribArray positionLocation
    gl.vertexAttribPointer positionLocation, 3, gl.FLOAT, false, 0, 0
    gl.drawArrays gl.POINTS, 0, 800

  vertexShader: glslify '''
    #pragma glslify: fbm = require("../../src/fbm.shader")
    attribute vec3 position;
    uniform float uTime;
    varying float ps;
    varying vec3 pos;
    void main() {
      float time = uTime * 0.33;
      gl_PointSize = fbm(position) * 50.;
      ps = gl_PointSize;
      pos = vec3(
        position.x + sin(time + fbm(position.y) * 32771.3) * 0.1,
        position.y + cos(time + fbm(position.x) * 84721.92) * 0.1,
        position.z
      );
      gl_Position = vec4(pos, 1.);
    }
  '''
  fragmentShader: glslify '''
    precision highp float;
    #pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")
    #pragma glslify: fbm = require("../../src/fbm.shader")
    #pragma glslify: blend = require("../../src/blend/screen.shader")

    uniform float uTime;
    uniform vec2 uResolution;
    uniform sampler2D uIn1;
    varying float ps;
    varying vec3 pos;

    void main() {
      vec3 color, uv = aspect_ratio(uResolution, 1);
      float c = 0., opacity = 1.;
      float t = uTime;
      vec4 s = texture2D(uIn1, vec2(uv));
      float len = smoothstep(.6, 0., length( gl_PointCoord - 0.5 ));
      float d = smoothstep(1., 0., length(uv.xy - vec2(0., 0.)));
      //c = smoothstep(0.5, 0., length( gl_PointCoord - 0.5 )) * (fbm(uv) * 0.5 + 0.5);
      //c = smoothstep(.5, .0, clamp(length( gl_PointCoord - 0.5 ), 0., .5)) * (fbm(uv) * 0.1 + 0.9);
      float r = fbm(ps);

      if(r > 0.8) {
        float threshold = (fbm(pos * 131. + t) * 0.7 + 0.3);
        if(len > threshold) { len = threshold; }
        else if(len < 0.) { len = 0.; }
        c = len; // flat point
      } else if(r > 0.5) {
        c = len; // glowing point
        c = smoothstep(.0, 1.0 + sin(t * 0.3 + uv.x * 9.37 + (uv.y - 0.3) * 1.7192 ) * 0.4, c);
      } else {
        c = len * 0.5; // fade point
      }

      color = blend(c * vec3(1., .7, .4), vec3(s));
      gl_FragColor = vec4(color, d);
    }
  '''

renderer = new ShaderRenderer [shader1, shader2], {root: '#root'}
renderer.init!
renderer.animate!
