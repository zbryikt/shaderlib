# Change Logs

## v0.0.9

 - support WebGL 2 ( OpenGL ES 3.0 )


## v0.0.8

 - to prevent flickering, call `resize` in `config` only if any config is changed.


## v0.0.7

 - support `flip` option (either `none`, `horizontal`, `vertical` or `diagonal`)


## v0.0.6

 - update dependencies
 - update documentation
 - fix bug: cloud.glsl syntax error issue
 - use a hidden canvas for manipuate result of rendering
 - correctly support texture across multiple shaders


## v0.0.5

 - support `config()` api
 - support `root` as `canvas`
 - unify resize code
 - rename `domElement` to `canvas` for better semantics


## v0.0.4

 - fix bug: `main` field in `package.json` use incorrect file name


## v0.0.3

 - move ShaderRenderer (in web/src/ls/shader.ls) to shaderlib.render ( src/renderer.ls ) as a module object.


## v0.0.2

 - upgrade modules
 - limit release scope
 - reorg repo
