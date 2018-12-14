require! <[fs]>

traverse = (root,hash = {}) ->
  path = root.join('/')
  files = fs.readdir-sync path
  for file in files => 
    p = "#path/#file"
    if fs.stat-sync(p).is-directory! =>
      traverse (root ++ [file]), hash
      continue
    id = (root ++ [file.replace(/\.shader$/,'')]).join('/')
    hash[id] = (fs.read-file-sync p .toString!)
  return hash

ret = traverse [\src]
console.log ret
fs.write-file-sync 'shaderlib.js', "shaderlib.module.register(#{JSON.stringify(ret)});"
