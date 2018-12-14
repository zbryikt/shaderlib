shaderlib = {}

shaderlib.module = do
  hash: {}
  get: (name) -> {code: @hash[name]}
  register: (name, code) ->
    if typeof(name) == \object =>
      for k,v of name => @hash[k] = v
    else @hash[name] = code

shaderlib.link = (shader) ->
  [u, varying, vs, fs, use] = <[uniforms varying vertexShader fragmentShader use]>.map -> shader[it]
  typemap = (type) ->
    ret = {t: "Sampler2D", f: "float"}[type]
    return if !ret => type else ret
  for item in (use or []) =>
    ret = @module.get(item.name)
    vs = ret.code + \\n + vs
    fs = ret.code + \\n + fs
  ulist = []
  for v in (varying or []) =>
    vs = "varying #{typemap v.type} #{v.name};\n" + vs
    fs = "varying #{typemap v.type} #{v.name};\n" + fs
  for k,v of (u or {}) =>
    name = k
    type = {t: "Sampler2D", f: "float"}[v.type]
    if !type and v.value =>
      if v.value.isVector2 => type = \vec2
      else if v.value.isVector3 => type = \vec3
      else if v.value.isVector4 => type = \vec4
    if !type => continue
    ulist.push "uniform #type #name"
  ulist = ulist.join('\n') + \\n
  vs = ulist + vs
  fs = ulist + fs
  delete shader.use
  delete shader.varying
  if u => shader.uniforms = u
  if vs => shader.vertexShader = vs
  if fs => shader.fragmentShader = fs
  return shader

sample-obj = do
  uniforms: {}
  vertexShader: {}
  fragmentShader: {}
  use:
    * name: 'blend@x.y.z'
    * name: 'sobel'

