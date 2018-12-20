(->

  default-vertex-shader = """
    precision highp float;
    attribute vec3 position;
    void main() {
      gl_Position = vec4(position, 1.);
    }
  """

  default-fragment-shader = """
    precision highp float;
    void main() {
      gl_FragColor = vec4(0., 0., 0., 1.);
    }
  """

  # pass root as null to create renderer without attaching canvas element to dom
  # width / height: only used when there's not root
  # shader: array of shader. output of each shader will be the uIn1 texture for next shader.
  ShaderRenderer = (shader, options = {}) ->
    @ <<< {width: 320, height: 240} <<< options{root, width, height, pipeline, debug}
    root = @root
    if root => @root = if typeof(root) == \string => document.querySelector root else root
    @shader = if Array.isArray shader => shader else [shader]
    @domElement = canvas = document.createElement \canvas
    @gl = gl = null
    @inputs = {}
    @

  ShaderRenderer.prototype = Object.create(Object.prototype) <<< do
    init: ->
      canvas = @domElement
      if @root =>
        @root.appendChild canvas
        box = @root.getBoundingClientRect!
        @ <<< box{width, height} <<< {inited: true}
      @inited = true
      @gl = gl = canvas.getContext \webgl
      canvas <<< @{width, height}
      gl.viewport 0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight

      @programs = []
      for i from 0 til @shader.length =>
        program = @make-program @shader[i], @programs[i - 1]
        @programs.push program
      @build-pipeline!
      @resize!

    texture: (program, uName, img) ->
      gl = @gl
      [pdata, pobj] = [program.data, program.obj]
      map = pdata.texture-map
      {texture, idx} = if !map[uName] =>
        @texture.idx = (@texture.idx or 0) + 1
        map[uName] = idx: (@texture.idx - 1), texture: gl.createTexture!
      else map[uName]
      uTexture = @gl.getUniformLocation pobj, uName
      @gl.uniform1i(uTexture, idx)
      gl.activeTexture(gl.TEXTURE0 + idx)
      gl.bindTexture gl.TEXTURE_2D, texture
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST
      if !img =>
        gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, @width, @height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null
      else gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img
      return texture

    # feed img/canvas element as texture into uIn1, uIn2, ... for the first shader
    input: (...args) -> for i from 1 to args.length => @set-input i, args[i - 1]
    set-input: (idx, src) ->
      @inputs["uIn#idx"] = if src instanceof ShaderRenderer => src.domElement else src

    make-shader: (code, type) ->
      gl = @gl
      shader = gl.createShader type
      gl.shaderSource shader, code
      gl.compileShader shader
      if !gl.getShaderParameter shader, gl.COMPILE_STATUS =>
        console.log gl.getShaderInfoLog shader
        console.log code
      return shader

    build-pipeline: ->
      [gl, ps, pp] = [@gl, @programs, @pipeline]
      if pp =>
        for link from 0 til pp.link =>
          link.0
        for i from 0 til ps.length =>
          if !(i in pp.src) => ps[i].data.uIn

      else
        for i from 0 til ps.length - 1 =>
          ps[i].data.fbo = gl.createFramebuffer!
        for i from 1 til ps.length =>
          ps[i].data.uIn1 = @texture ps[i], \uIn1, null
          gl.bindFramebuffer gl.FRAMEBUFFER, ps[i - 1].data.fbo
          gl.framebufferTexture2D gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, ps[i].data.uIn1, 0

    make-program: (shader, pprogram) ->
      gl = @gl
      [pdata, pobj] = [{texture-map: {}}, gl.createProgram!]
      program = {data: pdata, obj: pobj}
      vs = @make-shader (shader.vertexShader or default-vertex-shader), gl.VERTEX_SHADER
      fs = @make-shader (shader.fragmentShader or default-fragment-shader), gl.FRAGMENT_SHADER
      gl.attachShader pobj, vs
      gl.attachShader pobj, fs
      gl.linkProgram pobj
      if !gl.getProgramParameter pobj, gl.LINK_STATUS =>
        console.log gl.getProgramInfoLog(pobj)

      gl.useProgram pobj
      if shader.buffer => shader.buffer program
      else
        pdata.buffer = gl.createBuffer!
        gl.bindBuffer gl.ARRAY_BUFFER, pdata.buffer
        pdata.array = new Float32Array([
          -1, -1, 0,
           1, -1, 0,
          -1,  1, 0,
          -1,  1, 0,
           1, -1, 0,
           1,  1, 0
        ]);
        gl.bufferData( gl.ARRAY_BUFFER, pdata.array , gl.STATIC_DRAW)
        positionLocation = gl.getAttribLocation pobj, "position"
        gl.enableVertexAttribArray positionLocation
        gl.vertexAttribPointer positionLocation, 3, gl.FLOAT, false, 0, 0

      return program

    animate: (cb, options) ->
      _ = (t) ~>
        requestAnimationFrame (t) ~> _ t * 0.001
        if cb => cb t
        @render t, options
      _ 0

    render: (t = 0, options={}) ->
      if !@inited => @init!
      gl = @gl
      for i from 0 til @programs.length =>
        [pdata, pobj,shader] = [@programs[i].data, @programs[i].obj, @shader[i]]
        gl.useProgram pobj
        uTime = gl.getUniformLocation pobj, "uTime"
        gl.uniform1f(uTime, t)
        for k,v of (shader.uniforms or {}) =>
          if v.type == \t => @texture pobj, k, v.value
          else
            u = gl.getUniformLocation pobj, k
            gl["uniform#{v.type}"](u, v.value)
        if i == 0 => for k,v of @inputs => @texture @programs[i], k, v
        gl.bindFramebuffer gl.FRAMEBUFFER, pdata.fbo
        gl.viewport 0, 0, @width, @height

        if shader.render => that @programs[i], t
        else
          gl.clearColor 1,0,0,1
          gl.clear gl.COLOR_BUFFER_BIT
          gl.drawArrays gl.TRIANGLES, 0, 6

    setSize: (w, h) ->
      @ <<< width: w, height: h
      @domElement <<< width: w, height: h
      @resize!

    resize: ->
      for i from 0 til @programs.length =>
        pobj = @programs[i].obj
        @gl.useProgram pobj
        uResolution = @gl.getUniformLocation pobj, "uResolution"
        @gl.uniform2fv(uResolution, [@width, @height])

  if module? => module.exports = ShaderRenderer
  else if window? => window.ShaderRenderer = ShaderRenderer
)!
