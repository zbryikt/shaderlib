require! <[glslify]>

module.exports = do
  fragmentShader: glslify '''
  precision highp float;
  #pragma glslify: gradient = require('../../../src/raster/gradient/3d1.shader')

  uniform vec2 uResolution;
  uniform float uTime;
  void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    vec3 pos;
    float t = uTime * 0.1;
    float c = 0.5;
    float len;
    /*
    for(int i=0;i<100;i++) {
      pos.x = fract(sin(float(i) * 52.643) * 735.5373) + sin(t + float(i)); 
      pos.y = fract(fract(sin(float(i) * 63.235) * 644.5346) - t);
      pos.z = fract(sin(float(i) * 12.345) * 678.9012) * 0.01;
      len = clamp(length(uv - pos.xy) - pos.z, 0., 1.);
      c += 0.5 * pow(1. - len, 15.);
    }
    */
    c = 1.;
    gl_FragColor = vec4(
      c * vec3(gradient(uv, vec3(1.,0.,0.), vec3(0.,1.,0.), vec3(0.,0.,1.), 3.)),
      1.
    );
  }
  '''
