// Generated by LiveScript 1.3.1
var glslify, cloud;
glslify = require('glslify');
cloud = require("./sample/cloud");
window.addEventListener('load', function(){
  var shader1, shader2, renderer;
  shader1 = {
    render: function(program, t){
      var gl, positionLocation;
      gl = renderer.gl;
      gl.bindBuffer(gl.ARRAY_BUFFER, program.data.buffer);
      positionLocation = gl.getAttribLocation(program.obj, "position");
      gl.enableVertexAttribArray(positionLocation);
      gl.vertexAttribPointer(positionLocation, 3, gl.FLOAT, false, 0, 0);
      gl.bindFramebuffer(gl.FRAMEBUFFER, null);
      gl.clearColor(0, 0, 0, 1);
      gl.clear(gl.COLOR_BUFFER_BIT);
      return gl.drawArrays(gl.TRIANGLES, 0, 6);
    },
    vertexShader: 'attribute vec3 position;\nuniform float uTime;\nvoid main() {\n  gl_PointSize = 10.;\n  vec3 pos = position;\n  gl_Position = vec4(pos, 1.);\n}',
    fragmentShader: glslify('precision highp float;\n#pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")\n#pragma glslify: fbm = require("../../src/fbm.shader")\n\n// Processing specific input\nuniform float uTime;\nuniform vec2 uResolution;\n\nvoid main() {\n  vec3 uv = aspect_ratio(uResolution, 1);\n  float c = 0.;\n  float t, time = uTime;\n  c = pow(smoothstep(1., 0., length(vec2(uv))), 1.5) * fbm(uv * 7.) * 2.5;\n  //c = smoothstep(0.5, 0., clamp(length( gl_PointCoord - 0.5 ), 0., 1.));\n  gl_FragColor = vec4(c * vec3(1., .1, .2), 1.0);\n}')
  };
  shader2 = {
    buffer: function(program){
      var gl, buffer, arr, i$, i, a, r, pobj, positionLocation;
      gl = renderer.gl;
      program.data.buffer = buffer = gl.createBuffer();
      gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
      arr = [];
      for (i$ = 0; i$ < 800; ++i$) {
        i = i$;
        a = Math.random() * Math.PI * 0.5;
        r = Math.pow(Math.random(), 0.7) * 2;
        arr = arr.concat([Math.cos(a) * r - 1, Math.sin(a) * r - 1, 0]);
      }
      gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(arr), gl.STATIC_DRAW);
      pobj = program.obj;
      positionLocation = gl.getAttribLocation(pobj, "position");
      gl.enableVertexAttribArray(positionLocation);
      gl.vertexAttribPointer(positionLocation, 3, gl.FLOAT, false, 0, 0);
      gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
      gl.enable(gl.BLEND);
      return gl.disable(gl.DEPTH_TEST);
    },
    render: function(program, t){
      var gl, positionLocation;
      gl = renderer.gl;
      gl.bindBuffer(gl.ARRAY_BUFFER, program.data.buffer);
      positionLocation = gl.getAttribLocation(program.obj, "position");
      gl.enableVertexAttribArray(positionLocation);
      gl.vertexAttribPointer(positionLocation, 3, gl.FLOAT, false, 0, 0);
      return gl.drawArrays(gl.POINTS, 0, 800);
    },
    vertexShader: glslify('#pragma glslify: fbm = require("../../src/fbm.shader")\nattribute vec3 position;\nuniform float uTime;\nvarying float ps;\nvarying vec3 pos;\nvoid main() {\n  float time = uTime * 0.33;\n  gl_PointSize = fbm(position) * 50.;\n  ps = gl_PointSize;\n  pos = vec3(\n    position.x + sin(time + fbm(position.y) * 32771.3) * 0.1,\n    position.y + cos(time + fbm(position.x) * 84721.92) * 0.1,\n    position.z\n  );\n  gl_Position = vec4(pos, 1.);\n}'),
    fragmentShader: glslify('precision highp float;\n#pragma glslify: aspect_ratio = require("../../src/aspect_ratio.shader")\n#pragma glslify: fbm = require("../../src/fbm.shader")\n#pragma glslify: blend = require("../../src/blend/screen.shader")\n\nuniform float uTime;\nuniform vec2 uResolution;\nuniform sampler2D uIn1;\nvarying float ps;\nvarying vec3 pos;\n\nvoid main() {\n  vec3 color, uv = aspect_ratio(uResolution, 1);\n  float c = 0., opacity = 1.;\n  float t = uTime;\n  vec4 s = texture2D(uIn1, vec2(uv));\n  float len = smoothstep(.6, 0., length( gl_PointCoord - 0.5 ));\n  float d = smoothstep(1., 0., length(uv.xy - vec2(0., 0.)));\n  //c = smoothstep(0.5, 0., length( gl_PointCoord - 0.5 )) * (fbm(uv) * 0.5 + 0.5);\n  //c = smoothstep(.5, .0, clamp(length( gl_PointCoord - 0.5 ), 0., .5)) * (fbm(uv) * 0.1 + 0.9);\n  float r = fbm(ps);\n\n  if(r > 0.8) {\n    float threshold = (fbm(pos * 131. + t) * 0.7 + 0.3);\n    if(len > threshold) { len = threshold; }\n    else if(len < 0.) { len = 0.; }\n    c = len; // flat point\n  } else if(r > 0.5) {\n    c = len; // glowing point\n    c = smoothstep(.0, 1.0 + sin(t * 0.3 + uv.x * 9.37 + (uv.y - 0.3) * 1.7192 ) * 0.4, c);\n  } else {\n    c = len * 0.5; // fade point\n  }\n\n  color = blend(c * vec3(1., .7, .4), vec3(s));\n  gl_FragColor = vec4(color, d);\n}')
  };
  renderer = new ShaderRenderer([shader1, shader2], {
    root: '#root'
  });
  renderer.init();
  return renderer.animate();
});