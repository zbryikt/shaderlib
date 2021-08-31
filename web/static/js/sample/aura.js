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
window.addEventListener('load', function(){
  var shader, renderer;
  shader = {
    fragmentShader: glslify(["precision highp float;\n#define GLSLIFY 1\n/* z: pixel size */\nvec3 aspect_ratio_1540259130(vec2 res, int iscover) {\n  // iscover: 0 = contains, 1 = cover, 2 = stretch\n  float r;\n  vec3 ret = vec3((gl_FragCoord.xy / res.xy), 0.);\n  if(iscover == 2) {\n    ret.z = 1. / max(res.x, res.y);\n  } else if(iscover == 0 ^^ res.x > res.y) {\n    r = res.y / res.x;\n    ret.y = ret.y * r - (r - 1.) * 0.5;\n    ret.z = 1. / (iscover == 0 ? res.x : res.y);\n  } else {\n    r = res.x / res.y;\n    ret.x = (ret.x * r) - (r - 1.) * 0.5;\n    ret.z = 1. / (iscover == 0 ? res.y : res.x);\n  } \n  return ret;\n}\n\n/*\nret.y = ret.y * res.y / res.x\nret.x = ret.x * res.x / res.x\nret.xy = ret.xy * res.yx / max(res.x, res.y)\n\nfloat base;\nbase = res.xy / (iscover == 0 ? min(res.x, res.y) : max(res.x, res.y));\nret.z = 1. / base;\nret.xy = ( ret.xy * res.yx / base ) - ret.xy / base;\n*/\n\nfloat hash(float n) { return fract(sin(n) * 1e4); }\nfloat hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }\n\nfloat noise(float x) {\n        float i = floor(x);\n        float f = fract(x);\n        float u = f * f * (3.0 - 2.0 * f);\n        return mix(hash(i), hash(i + 1.0), u);\n}\n\nfloat noise(vec2 x) {\n        vec2 i = floor(x);\n        vec2 f = fract(x);\n\n        // Four corners in 2D of a tile\n        float a = hash(i);\n        float b = hash(i + vec2(1.0, 0.0));\n        float c = hash(i + vec2(0.0, 1.0));\n        float d = hash(i + vec2(1.0, 1.0));\n\n        // Simple 2D lerp using smoothstep envelope between the values.\n        // return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),\n        //                      mix(c, d, smoothstep(0.0, 1.0, f.x)),\n        //                      smoothstep(0.0, 1.0, f.y)));\n\n        // Same code, with the clamps in smoothstep and common subexpressions\n        // optimized away.\n        vec2 u = f * f * (3.0 - 2.0 * f);\n        return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;\n}\n\n// This one has non-ideal tiling properties that I'm still tuning\nfloat noise(vec3 x) {\n        const vec3 step = vec3(110, 241, 171);\n\n        vec3 i = floor(x);\n        vec3 f = fract(x);\n \n        // For performance, compute the base input to a 1D hash from the integer part of the argument and the \n        // incremental change to the 1D based on the 3D -> 1D wrapping\n    float n = dot(i, step);\n\n        vec3 u = f * f * (3.0 - 2.0 * f);\n        return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),\n                   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),\n               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),\n                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);\n}\n\n#define NUM_OCTAVES 5\n\nfloat fbm(float x) {\n  float v = 0.0;\n  float a = 0.5;\n  float shift = float(100);\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\nfloat fbm(vec2 x) {\n  float v = 0.0;\n  float a = 0.5;\n  vec2 shift = vec2(100);\n  // Rotate to reduce axial bias\n  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = rot * x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\nfloat fbm(vec3 x) {\n  float v = 0.0;\n  float a = 0.5;\n  vec3 shift = vec3(100);\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\n#define PI2 6.2831852\n\nuniform float uTime;\nuniform vec2 uResolution;\nvoid main() {\n  float t = uTime * 0.25;\n  vec3 uv = aspect_ratio_1540259130(uResolution, 1);\n  float color = 0.;\n  color = fbm(uv.x * uv.x + uv.y * uv.y * sin(t)) * smoothstep(1., 0., abs(uv.y - (sin(uv.x) * 0.2 + 0.5)) * 2.3);\n  gl_FragColor = vec4(vec3(color), 1.);\n\n}"])
  };
  renderer = new ShaderRenderer([shader], {
    root: '#root'
  });
  return renderer.animate();
});
},{"glslify":1}]},{},[2]);
