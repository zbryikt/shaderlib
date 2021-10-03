# shaderlib

shaderlib is a toolkit for frontend WebGL rendering. It includes:

 - curated functions ( under `lib/` for GLSL Shaders, used in WebGL and Three.js.
 - simple renderer for shader code ( available via `shaderlib.renderer` )


## Usage

For rendering, include `dist/index.js` and:

    var renderer = new shaderlib.renderer(
      [shader-code-obj], {root: 'node or selector for container'}
    );
    renderer.init();
    renderer.animate();


where `shader-code-obj` is an object with following fields:

 - `uniforms`: object containing definitions of global variables (per primitive, from WebGL to shader).
 - `fragmentShader`: string for fragment shader code
 - `vertexShader`: string for vertex shader code

Following is a sample shader code object:

    {
      uniforms: {
          c1: {type: "3fv", value: [0.76, 0.91, 0.81]}
      },
      vertexShader: "void main() {}"
      fragmentShader: "void main() {}"
    }


## Glslify

shaders are loaded as string - by default there is no module concept for adopting external libraries. Use `glslify` for adopting node.js-style module system.

Following is an example using `glslify`:

    require! <[glslify]>
    fragmentShader = glslify """
    #pragma glslify: aspect_ratio = require("shaderlib/lib/func/aspect_ratio")
    uniform vec2 uResolution;
    void main() {
      vec3 uv = aspect_ratio(uResolution, 1);
    }
    """

You will need `browserify` since it uses `require` to include node modules:

    browserify -t glslify myfile.js > bundle.js

`@plotdb/srcbuild` support glslify by `useGlslify` option set to true. check `web/server.ls` for sample setup.


## Backlog

older version `glslify` had bug with livescript generated code ( before v7.1.0 ). use either newer glslify ( >=v7.1.0 ), or use `@zbryikt/glslify`:

    npm install github:zbryikt/glslify


## LICENSE

MIT License.
