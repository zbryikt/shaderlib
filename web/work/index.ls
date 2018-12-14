init = (w = window.innerWidth, h = window.innerHeight) ->
  camera = new THREE.PerspectiveCamera 45, w/h, 1, 10000
  scene = new THREE.Scene!
  renderer = new THREE.WebGLRenderer antialias: true
  renderer.setSize w, h
  document.body.appendChild renderer.domElement
  animate = (render-func) ->
    _animate = (value) ->
      requestAnimationFrame _animate
      render-func value
    _animate!
  return {camera, scene, renderer, w, h, animate}

{camera, scene, renderer, w, h, animate} = init!

camera.position.set 0, 0, 2
camera.lookAt 0, 0, 0
plane = new THREE.PlaneGeometry 1, 1, 32, 32
mat = new THREE.ShaderMaterial shaderlib.link do
  use:
    * name: "src/noise"
    * name: "src/fbm"
  varying: [
    * type: \vec2, name: \vUv
  ]
  vertexShader: """
  void main() {
    vUv = vec2(fbm(uv), fbm(uv));
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.);
  }
  """
  fragmentShader: """
  void main() {
    gl_FragColor = vec4(vUv.x, vUv.y, 0., 1.);
  }
  """

mesh = new THREE.Mesh plane, mat
scene.add mesh
light = new THREE.AmbientLight 0xffffff
scene.add light

renderer.render scene, camera
