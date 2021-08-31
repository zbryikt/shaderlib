(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
module.exports = function(strings) {
  if (typeof strings === 'string') strings = [strings]
  var exprs = [].slice.call(arguments,1)
  var parts = []
  for (var i = 0; i < strings.length-1; i++) {
    parts.push(strings[i], exprs[i] || '')
  }
  parts.push(strings[i])
  return parts.join('')
}

},{}],2:[function(require,module,exports){
var glslify;
glslify = require('glslify');
module.exports = {
  fragmentShader: glslify(["precision highp float;\n#define GLSLIFY 1\nvec3 raster_gradient_3d1_1540259130(vec2 uv, vec3 c1, vec3 c2, vec3 c3, float rate) {\n  return (\n    c1 * ( sin(rate * uv.x) * 0.5 + 0.5 ) + \n    c2 * ( sin(rate * uv.y) * 0.5 + 0.5 ) +\n    c3 * ( sin(rate * uv.x * uv.y) * 0.5 + 0.5 )\n  );\n}\n\nuniform vec2 uResolution;\nuniform float uTime;\nvoid main() {\n  vec2 uv = gl_FragCoord.xy / uResolution.xy;\n  vec3 pos;\n  float t = uTime * 0.1;\n  float c = 0.5;\n  float len;\n  /*\n  for(int i=0;i<100;i++) {\n    pos.x = fract(sin(float(i) * 52.643) * 735.5373) + sin(t + float(i)); \n    pos.y = fract(fract(sin(float(i) * 63.235) * 644.5346) - t);\n    pos.z = fract(sin(float(i) * 12.345) * 678.9012) * 0.01;\n    len = clamp(length(uv - pos.xy) - pos.z, 0., 1.);\n    c += 0.5 * pow(1. - len, 15.);\n  }\n  */\n  c = 1.;\n  gl_FragColor = vec4(\n    c * vec3(raster_gradient_3d1_1540259130(uv, vec3(1.,0.,0.), vec3(0.,1.,0.), vec3(0.,0.,1.), 3.)),\n    1.\n  );\n}"])
};
},{"glslify":1}]},{},[2]);
