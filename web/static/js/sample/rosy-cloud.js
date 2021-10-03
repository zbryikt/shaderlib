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
  var shader3, shader2, shader1, shaders, renderer, renderer2;
  shader3 = {
    uniforms: {},
    vertexShader: "precision highp float;\nattribute vec3 position;\nvoid main() {\n  gl_Position = vec4(position, 1.);\n}",
    fragmentShader: glslify(["precision highp float;\n#define GLSLIFY 1\n#define FXAA_REDUCE_MIN   (1.0/128.0)\n#define FXAA_REDUCE_MUL   (1.0/8.0)\n#define FXAA_SPAN_MAX     8.0\n\nvec4 fxaa(sampler2D tex, vec2 uv, vec2 res) {\n\n    res = 1. / res;\n\n    vec3 rgbNW = texture2D( tex, ( uv.xy + vec2( -1.0, -1.0 ) * res ) ).xyz;\n    vec3 rgbNE = texture2D( tex, ( uv.xy + vec2( 1.0, -1.0 ) * res ) ).xyz;\n    vec3 rgbSW = texture2D( tex, ( uv.xy + vec2( -1.0, 1.0 ) * res ) ).xyz;\n    vec3 rgbSE = texture2D( tex, ( uv.xy + vec2( 1.0, 1.0 ) * res ) ).xyz;\n    vec4 rgbaM  = texture2D( tex,  uv.xy  * res );\n    vec3 rgbM  = rgbaM.xyz;\n    vec3 luma = vec3( 0.299, 0.587, 0.114 );\n\n    float lumaNW = dot( rgbNW, luma );\n    float lumaNE = dot( rgbNE, luma );\n    float lumaSW = dot( rgbSW, luma );\n    float lumaSE = dot( rgbSE, luma );\n    float lumaM  = dot( rgbM,  luma );\n    float lumaMin = min( lumaM, min( min( lumaNW, lumaNE ), min( lumaSW, lumaSE ) ) );\n    float lumaMax = max( lumaM, max( max( lumaNW, lumaNE) , max( lumaSW, lumaSE ) ) );\n\n    vec2 dir;\n    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));\n    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));\n\n    float dirReduce = max( ( lumaNW + lumaNE + lumaSW + lumaSE ) * ( 0.25 * FXAA_REDUCE_MUL ), FXAA_REDUCE_MIN );\n\n    float rcpDirMin = 1.0 / ( min( abs( dir.x ), abs( dir.y ) ) + dirReduce );\n    dir = min( vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),\n          max( vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),\n                dir * rcpDirMin)) * res;\n    vec4 rgbA = (1.0/2.0) * (\n    texture2D(tex,  uv.xy + dir * (1.0/3.0 - 0.5)) +\n    texture2D(tex,  uv.xy + dir * (2.0/3.0 - 0.5)));\n    vec4 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (\n    texture2D(tex,  uv.xy + dir * (0.0/3.0 - 0.5)) +\n    texture2D(tex,  uv.xy + dir * (3.0/3.0 - 0.5)));\n    float lumaB = dot(rgbB, vec4(luma, 0.0));\n\n    if ( ( lumaB < lumaMin ) || ( lumaB > lumaMax ) ) {\n        return rgbA;\n    } else {\n        return rgbB;\n    }\n\n}\n\nvec3 grayscale(vec3 c) {\n  return vec3(dot(c, vec3(0.299, 0.587, 0.114)));\n}\n\nvec4 blur(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {\n  vec4 color = vec4(0.0);\n  vec2 off1 = vec2(1.411764705882353) * direction;\n  vec2 off2 = vec2(3.2941176470588234) * direction;\n  vec2 off3 = vec2(5.176470588235294) * direction;\n  color += texture2D(image, uv) * 0.1964825501511404;\n  color += texture2D(image, uv + (off1 / resolution)) * 0.2969069646728344;\n  color += texture2D(image, uv - (off1 / resolution)) * 0.2969069646728344;\n  color += texture2D(image, uv + (off2 / resolution)) * 0.09447039785044732;\n  color += texture2D(image, uv - (off2 / resolution)) * 0.09447039785044732;\n  color += texture2D(image, uv + (off3 / resolution)) * 0.010381362401148057;\n  color += texture2D(image, uv - (off3 / resolution)) * 0.010381362401148057;\n  return color;\n}\n\nvec3 sobel(sampler2D txt, vec2 uv, vec2 res) {\n  float x = 1.0 / res.x;\n  float y = 1.0 / res.y;\n  vec4 h = vec4(.0), v = vec4(.0);\n  h = v = texture2D(txt, vec2(uv.x + x, uv.y + y)) - texture2D(txt, vec2(uv.x - x, uv.y - y));\n  h -= texture2D(txt, vec2(uv.x - x, uv.y)) * 2.;\n  h += texture2D(txt, vec2(uv.x + x, uv.y)) * 2.;\n  h -= texture2D(txt, vec2(uv.x - x, uv.y + y));\n  h += texture2D(txt, vec2(uv.x + x, uv.y - y));\n  v -= texture2D(txt, vec2(uv.x, uv.y - y)) * 2.;\n  v += texture2D(txt, vec2(uv.x, uv.y + y)) * 2.;\n  v -= texture2D(txt, vec2(uv.x + x, uv.y - y));\n  v += texture2D(txt, vec2(uv.x - x, uv.y + y));\n  return vec3(1. - sqrt(h * h + v * v));\n}\n\n//\n// Description : Array and textureless GLSL 2D simplex noise function.\n//      Author : Ian McEwan, Ashima Arts.\n//  Maintainer : ijm\n//     Lastmod : 20110822 (ijm)\n//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.\n//               Distributed under the MIT License. See LICENSE file.\n//               https://github.com/ashima/webgl-noise\n//\n\nvec3 mod289(vec3 x) {\n  return x - floor(x * (1.0 / 289.0)) * 289.0;\n}\n\nvec2 mod289(vec2 x) {\n  return x - floor(x * (1.0 / 289.0)) * 289.0;\n}\n\nvec3 permute(vec3 x) {\n  return mod289(((x*34.0)+1.0)*x);\n}\n\nfloat snoise(vec2 v)\n  {\n  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0\n                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)\n                     -0.577350269189626,  // -1.0 + 2.0 * C.x\n                      0.024390243902439); // 1.0 / 41.0\n// First corner\n  vec2 i  = floor(v + dot(v, C.yy) );\n  vec2 x0 = v -   i + dot(i, C.xx);\n\n// Other corners\n  vec2 i1;\n  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0\n  //i1.y = 1.0 - i1.x;\n  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);\n  // x0 = x0 - 0.0 + 0.0 * C.xx ;\n  // x1 = x0 - i1 + 1.0 * C.xx ;\n  // x2 = x0 - 1.0 + 2.0 * C.xx ;\n  vec4 x12 = x0.xyxy + C.xxzz;\n  x12.xy -= i1;\n\n// Permutations\n  i = mod289(i); // Avoid truncation effects in permutation\n  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))\n    + i.x + vec3(0.0, i1.x, 1.0 ));\n\n  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);\n  m = m*m ;\n  m = m*m ;\n\n// Gradients: 41 points uniformly over a line, mapped onto a diamond.\n// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)\n\n  vec3 x = 2.0 * fract(p * C.www) - 1.0;\n  vec3 h = abs(x) - 0.5;\n  vec3 ox = floor(x + 0.5);\n  vec3 a0 = x - ox;\n\n// Normalise gradients implicitly by scaling m\n// Approximation of: m *= inversesqrt( a0*a0 + h*h );\n  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );\n\n// Compute final noise value at P\n  vec3 g;\n  g.x  = a0.x  * x0.x  + h.x  * x0.y;\n  g.yz = a0.yz * x12.xz + h.yz * x12.yw;\n  return 130.0 * dot(m, g);\n}\n\nfloat aastep(float threshold, float value) {\n  #ifdef GL_OES_standard_derivatives\n    float afwidth = length(vec2(dFdx(value), dFdy(value))) * 0.70710678118654757;\n    return smoothstep(threshold-afwidth, threshold+afwidth, value);\n  #else\n    return step(threshold, value);\n  #endif  \n}\n\nvec3 halftone(vec3 texcolor, vec2 st, float frequency) {\n  float n = 0.1*snoise(st*200.0); // Fractal noise\n  n += 0.05*snoise(st*400.0);\n  n += 0.025*snoise(st*800.0);\n  vec3 white = vec3(n*0.2 + 0.97);\n  vec3 black = vec3(n + 0.1);\n\n  // Perform a rough RGB-to-CMYK conversion\n  vec4 cmyk;\n  cmyk.xyz = 1.0 - texcolor;\n  cmyk.w = min(cmyk.x, min(cmyk.y, cmyk.z)); // Create K\n  cmyk.xyz -= cmyk.w; // Subtract K equivalent from CMY\n\n  // Distance to nearest point in a grid of\n  // (frequency x frequency) points over the unit square\n  vec2 Kst = frequency*mat2(0.707, -0.707, 0.707, 0.707)*st;\n  vec2 Kuv = 2.0*fract(Kst)-1.0;\n  float k = aastep(0.0, sqrt(cmyk.w)-length(Kuv)+n);\n  vec2 Cst = frequency*mat2(0.966, -0.259, 0.259, 0.966)*st;\n  vec2 Cuv = 2.0*fract(Cst)-1.0;\n  float c = aastep(0.0, sqrt(cmyk.x)-length(Cuv)+n);\n  vec2 Mst = frequency*mat2(0.966, 0.259, -0.259, 0.966)*st;\n  vec2 Muv = 2.0*fract(Mst)-1.0;\n  float m = aastep(0.0, sqrt(cmyk.y)-length(Muv)+n);\n  vec2 Yst = frequency*st; // 0 deg\n  vec2 Yuv = 2.0*fract(Yst)-1.0;\n  float y = aastep(0.0, sqrt(cmyk.z)-length(Yuv)+n);\n\n  vec3 rgbscreen = 1.0 - 0.9*vec3(c,m,y) + n;\n  return mix(rgbscreen, black, 0.85*k + 0.3*n);\n}\n\nvec3 halftone(vec3 texcolor, vec2 st) {\n  return halftone(texcolor, st, 30.0);\n}\n\n// Adapted from http://coding-experiments.blogspot.com/2010/06/edge-detection.html\nfloat threshold_0(in float thr1, in float thr2 , in float val) {\n  if (val < thr1) {return 0.0;}\n  if (val > thr2) {return 1.0;}\n  return val;\n}\n\n// averaged pixel difference from 3 color channels\nfloat diff(in vec4 pix1, in vec4 pix2) {\n  return (\n    abs(pix1.r - pix2.r) +\n    abs(pix1.g - pix2.g) +\n    abs(pix1.b - pix2.b)\n  ) / 3.0;\n}\n\nfloat edge(in sampler2D tex, in vec2 coords, in vec2 renderSize){\n  float dx = 1.0 / renderSize.x;\n  float dy = 1.0 / renderSize.y;\n  vec4 pix[9];\n  \n  pix[0] = texture2D(tex, coords + vec2( -1.0 * dx, -1.0 * dy));\n  pix[1] = texture2D(tex, coords + vec2( -1.0 * dx , 0.0 * dy));\n  pix[2] = texture2D(tex, coords + vec2( -1.0 * dx , 1.0 * dy));\n  pix[3] = texture2D(tex, coords + vec2( 0.0 * dx , -1.0 * dy));\n  pix[4] = texture2D(tex, coords + vec2( 0.0 * dx , 0.0 * dy));\n  pix[5] = texture2D(tex, coords + vec2( 0.0 * dx , 1.0 * dy));\n  pix[6] = texture2D(tex, coords + vec2( 1.0 * dx , -1.0 * dy));\n  pix[7] = texture2D(tex, coords + vec2( 1.0 * dx , 0.0 * dy));\n  pix[8] = texture2D(tex, coords + vec2( 1.0 * dx , 1.0 * dy));\n\n  // average color differences around neighboring pixels\n  float delta = (diff(pix[1],pix[7])+\n          diff(pix[5],pix[3]) +\n          diff(pix[0],pix[8])+\n          diff(pix[2],pix[6])\n           )/4.;\n\n  return threshold_0(0.25,0.4,clamp(3.0*delta,0.0,1.0));\n}\n\nuniform sampler2D uIn1;\nuniform vec2 uResolution;\nvoid main() {\n  vec2 uv = vec2(gl_FragCoord.x / uResolution.x, 1. - gl_FragCoord.y / uResolution.y);\n  float e = edge(uIn1, uv, uResolution);\n  gl_FragColor = vec4(vec3(e),1.);\n}"])
  };
  shader2 = {
    uniforms: {},
    vertexShader: "precision highp float;\nattribute vec3 position;\nvoid main() {\n  gl_Position = vec4(position, 1.);\n}",
    fragmentShader: glslify(["precision highp float;\n#define GLSLIFY 1\nfloat hash(float n) { return fract(sin(n) * 1e4); }\nfloat hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }\n\nfloat noise(float x) {\n        float i = floor(x);\n        float f = fract(x);\n        float u = f * f * (3.0 - 2.0 * f);\n        return mix(hash(i), hash(i + 1.0), u);\n}\n\nfloat noise(vec2 x) {\n        vec2 i = floor(x);\n        vec2 f = fract(x);\n\n        // Four corners in 2D of a tile\n        float a = hash(i);\n        float b = hash(i + vec2(1.0, 0.0));\n        float c = hash(i + vec2(0.0, 1.0));\n        float d = hash(i + vec2(1.0, 1.0));\n\n        // Simple 2D lerp using smoothstep envelope between the values.\n        // return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),\n        //                      mix(c, d, smoothstep(0.0, 1.0, f.x)),\n        //                      smoothstep(0.0, 1.0, f.y)));\n\n        // Same code, with the clamps in smoothstep and common subexpressions\n        // optimized away.\n        vec2 u = f * f * (3.0 - 2.0 * f);\n        return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;\n}\n\n// This one has non-ideal tiling properties that I'm still tuning\nfloat noise(vec3 x) {\n        const vec3 step = vec3(110, 241, 171);\n\n        vec3 i = floor(x);\n        vec3 f = fract(x);\n \n        // For performance, compute the base input to a 1D hash from the integer part of the argument and the \n        // incremental change to the 1D based on the 3D -> 1D wrapping\n    float n = dot(i, step);\n\n        vec3 u = f * f * (3.0 - 2.0 * f);\n        return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),\n                   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),\n               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),\n                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);\n}\n\n#define NUM_OCTAVES 5\n\nfloat fbm(float x) {\n  float v = 0.0;\n  float a = 0.5;\n  float shift = float(100);\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\nfloat fbm(vec2 x) {\n  float v = 0.0;\n  float a = 0.5;\n  vec2 shift = vec2(100);\n  // Rotate to reduce axial bias\n  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = rot * x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\nfloat fbm(vec3 x) {\n  float v = 0.0;\n  float a = 0.5;\n  vec3 shift = vec3(100);\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\nuniform sampler2D uIn1;\nuniform vec2 uResolution;\nvoid main() {\n  vec2 uv = vec2(gl_FragCoord.x / uResolution.x, gl_FragCoord.y / uResolution.y);\n  vec4 c;\n  gl_FragColor = vec4(1., 0., 0., 1.);\n  c = vec4(texture2D(uIn1, uv));\n  gl_FragColor = vec4(vec3(c) * fbm(uv * 10.), 1.);\n}"])
  };
  shader1 = {
    uniforms: {
      color: {
        type: '3fv',
        value: [0, 0, 0]
      }
    },
    vertexShader: "precision highp float;\nuniform float uTime;\nattribute vec3 position;\nvoid main() {\n  gl_Position = vec4(position, 1.);\n}",
    fragmentShader: glslify(["precision highp float;\n#define GLSLIFY 1\nvec3 raster_gradient_3d1_1540259130(vec2 uv, vec3 c1, vec3 c2, vec3 c3, float rate) {\n  return (\n    c1 * ( sin(rate * uv.x) * 0.5 + 0.5 ) + \n    c2 * ( sin(rate * uv.y) * 0.5 + 0.5 ) +\n    c3 * ( sin(rate * uv.x * uv.y) * 0.5 + 0.5 )\n  );\n}\n\nfloat hash(float n) { return fract(sin(n) * 1e4); }\nfloat hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }\n\nfloat noise(float x) {\n        float i = floor(x);\n        float f = fract(x);\n        float u = f * f * (3.0 - 2.0 * f);\n        return mix(hash(i), hash(i + 1.0), u);\n}\n\nfloat noise(vec2 x) {\n        vec2 i = floor(x);\n        vec2 f = fract(x);\n\n        // Four corners in 2D of a tile\n        float a = hash(i);\n        float b = hash(i + vec2(1.0, 0.0));\n        float c = hash(i + vec2(0.0, 1.0));\n        float d = hash(i + vec2(1.0, 1.0));\n\n        // Simple 2D lerp using smoothstep envelope between the values.\n        // return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),\n        //                      mix(c, d, smoothstep(0.0, 1.0, f.x)),\n        //                      smoothstep(0.0, 1.0, f.y)));\n\n        // Same code, with the clamps in smoothstep and common subexpressions\n        // optimized away.\n        vec2 u = f * f * (3.0 - 2.0 * f);\n        return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;\n}\n\n// This one has non-ideal tiling properties that I'm still tuning\nfloat noise(vec3 x) {\n        const vec3 step = vec3(110, 241, 171);\n\n        vec3 i = floor(x);\n        vec3 f = fract(x);\n \n        // For performance, compute the base input to a 1D hash from the integer part of the argument and the \n        // incremental change to the 1D based on the 3D -> 1D wrapping\n    float n = dot(i, step);\n\n        vec3 u = f * f * (3.0 - 2.0 * f);\n        return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),\n                   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),\n               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),\n                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);\n}\n\n#define NUM_OCTAVES 5\n\nfloat fbm(float x) {\n  float v = 0.0;\n  float a = 0.5;\n  float shift = float(100);\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\nfloat fbm(vec2 x) {\n  float v = 0.0;\n  float a = 0.5;\n  vec2 shift = vec2(100);\n  // Rotate to reduce axial bias\n  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = rot * x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\nfloat fbm(vec3 x) {\n  float v = 0.0;\n  float a = 0.5;\n  vec3 shift = vec3(100);\n  for (int i = 0; i < NUM_OCTAVES; ++i) {\n    v += a * noise(x);\n    x = x * 2.0 + shift;\n    a *= 0.5;\n  }\n  return v;\n}\n\n#define NUM_ITERATION 5.\n\nfloat raster_cloud_529295689(vec2 uv, float t, vec2 dir, float delta) {\n  float c = 0.;\n  for(float i=1.;i<NUM_ITERATION;i++) {\n    c += fbm(vec2(uv.x * i + t * pow(delta,i) * 0.001 * dir.x, uv.y * i + t * pow(delta, i) * 0.001 * dir.y));\n  }\n  c = c / (NUM_ITERATION - 2.);\n  return c;\n}\n\nfloat vignette(float max, float amount, vec2 uv_0) {\n  return max - length(uv_0 - .5) * amount;\n}\n\n//#pragma glslify: color_shift = require('lib/func/color_shift.glsl')\nuniform float uTime;\nuniform vec3 color;\nuniform vec2 uResolution;\nuniform sampler2D uImage;\nvec3 cc(vec2 uv, float t) {\n  vec3 c = raster_gradient_3d1_1540259130(uv, vec3(1.,0.,0.), vec3(0.,1.,0.), vec3(0.,0.,1.), 3.);\n  float d = raster_cloud_529295689(uv, t, vec2(1., 0.), 3.);\n  float e = vignette(1., 0.5, uv);\n  return c * d * e;\n}\n#define color_shift(a,b,c,d,e,f) (a(b, d) + a(vec2(b.x - c, b.y), d) * e * 0.5 + a(vec2(b.x + c, b.y), d) * f * 0.5)\nvoid main() {\n  float t = uTime * 10.;\n  vec2 uv = vec2(gl_FragCoord.x / uResolution.x, gl_FragCoord.y / uResolution.y);\n  vec3 o = color_shift(cc, uv, 0.1, t, vec3(1., 0., 0.), vec3(0., 0., 1.));\n  gl_FragColor = vec4(o, 1.);\n  //gl_FragColor = vec4(texture2D(uImage, uv));\n}"])
  };
  shaders = [shader1];
  renderer = new ShaderRenderer(shaders, {
    root: '#root .box:nth-child(1)'
  });
  renderer.animate();
  renderer2 = new ShaderRenderer(shader3, {
    root: '#root .box:nth-child(2)'
  });
  renderer2.input(renderer);
  return renderer2.animate();
});
},{"glslify":1}]},{},[2]);