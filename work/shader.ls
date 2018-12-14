shaderRenderer = (root, shader) ->
  @root = root = if typeof(root) == \string => document.querySelector root else root
  @shader = shader
  @domElement = canvas = document.createElement \canvas
  @gl = gl = null
  @


shaderRenderer.prototype = Object.create(Object.prototype) <<< do
  init: ->
    canvas = @domElement
    @root.appendChild canvas
    box = @root.getBoundingClientRect!
    @ <<< width: box.width, height: box.height, inited: true
    @gl = canvas.getContext \webgl
    canvas <<< @{width, height}
    @gl.viewport 0, 0, @gl.drawingBufferWidth, @gl.drawingBufferHeight
    buffer = @gl.createBuffer!
    @gl.bindBuffer @gl.ARRAY_BUFFER, buffer

    @gl.bufferData(
      @gl.ARRAY_BUFFER, new Float32Array([
        -1, -1, 0,
         1, -1, 0,
        -1,  1, 0,
        -1,  1, 0,
         1, -1, 0,
         1,  1, 0
      ]), @gl.STATIC_DRAW
    )
    program = @make-program @shader

    @gl.useProgram program

    positionLocation = @gl.getAttribLocation program, "position"
    @gl.enableVertexAttribArray positionLocation
    @gl.vertexAttribPointer positionLocation, 3, @gl.FLOAT, false, 0, 0

  make-shader: (code, type) ->
    shader = @gl.createShader type
    @gl.shaderSource shader, code
    @gl.compileShader shader
    if !@gl.getShaderParameter shader, @gl.COMPILE_STATUS => 
      console.log @gl.getShaderInfoLog shader
    return shader

  make-program: (shader) ->
    @program = program = @gl.createProgram!
    shaders = []
    vs = @make-shader @shader.vertexShader, @gl.VERTEX_SHADER
    fs = @make-shader @shader.fragmentShader, @gl.FRAGMENT_SHADER
    @gl.attachShader program, vs
    @gl.attachShader program, fs
    @gl.linkProgram program
    if !@gl.getProgramParameter program, @gl.LINK_STATUS => #failed
    return program

  animate: (cb) ->
    _ = (t) ~> 
      requestAnimationFrame (t) ~> _ t * 0.001
      cb t
      @render t
    _ 0

  render: (t = 0) ->
    if !@inited => @init!

    uTime = @gl.getUniformLocation @program, "uTime"
    @gl.uniform1f(uTime, t)
    uResolution = @gl.getUniformLocation @program, "uResolution"
    @gl.uniform2fv(uResolution, [@width, @height])
    for k,v of (@shader.uniforms or {}) =>
      u = @gl.getUniformLocation @program, k
      @gl["uniform#{v.type}"](u, v.value)

    @gl.clearColor 1,0,0,1
    @gl.clear @gl.COLOR_BUFFER_BIT
    @gl.drawArrays @gl.TRIANGLES, 0, 6

