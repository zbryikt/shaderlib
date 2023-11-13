(function(){
  var defaultVertexShader, defaultFragmentShader, renderer;
  defaultVertexShader = "precision highp float;\nattribute vec3 position;\nvoid main() {\n  gl_Position = vec4(position, 1.);\n}";
  defaultFragmentShader = "precision highp float;\nvoid main() {\n  gl_FragColor = vec4(0., 0., 0., 1.);\n}";
  renderer = function(shader, options){
    var root, gl;
    options == null && (options = {});
    import$((this.width = 320, this.height = 240, this.scale = 1, this), options);
    root = this.root;
    if (root) {
      this.root = typeof root === 'string' ? document.querySelector(root) : root;
    }
    this.shader = Array.isArray(shader)
      ? shader
      : [shader];
    this.gl = gl = null;
    this.inputs = {};
    return this;
  };
  renderer.prototype = import$(Object.create(Object.prototype), {
    config: function(o){
      var v, this$ = this;
      v = ['width', 'height', 'scale', 'flip'].filter(function(n){
        return o[n] != null && this$[n] !== o[n];
      }).map(function(n){
        if (o[n] != null) {
          return this$[n] = o[n];
        }
      }).length;
      if (v) {
        return this.resize();
      }
    },
    setSize: function(w, h){
      this.width = w;
      this.height = h;
      return this.resize();
    },
    init: function(){
      var canvas, box, i$, to$, i, program;
      if (this.root.nodeName.toLowerCase() === 'canvas') {
        this.canvas = this.root;
      } else {
        this.canvas = canvas = document.createElement('canvas');
        this.root.appendChild(canvas);
        box = this.root.getBoundingClientRect();
        (this.width = box.width, this.height = box.height, this).inited = true;
      }
      this.inited = true;
      this._canvas = document.createElement('canvas');
      this.gl = this._canvas.getContext('webgl');
      this.programs = [];
      for (i$ = 0, to$ = this.shader.length; i$ < to$; ++i$) {
        i = i$;
        program = this.makeProgram(this.shader[i], this.programs[i - 1]);
        this.programs.push(program);
      }
      this.buildPipeline();
      return this.resize();
    },
    sizeof: function(type){
      var d, gl, map, i$, to$, i;
      if (!this.sizeof.data) {
        this.sizeof.data = d = {};
        gl = this.gl;
        map = ['BYTE', '1', 'UNSIGNED_BYTE', '1', 'SHORT', '2', 'UNSIGNED_SHORT', '2', 'INT', '4', 'UNSIGNED_INT', '4', 'FIXED', '4', 'HALF_FLOAT', '2', 'FLOAT', '4', 'DOUBLE', '8'];
        for (i$ = 0, to$ = map.length; i$ < to$; i$ += 2) {
          i = i$;
          d[gl[map[i]]] = map[i + 1];
        }
      }
      return this.sizeof.data[type];
    },
    texture: function(program, uName, img){
      var gl, ref$, pdata, pobj, map, texture, idx, uTexture;
      gl = this.gl;
      ref$ = [program.data, program.obj], pdata = ref$[0], pobj = ref$[1];
      map = pdata.textureMap;
      ref$ = !map[uName]
        ? (this.texture.idx = (this.texture.idx || 0) + 1, map[uName] = {
          idx: this.texture.idx - 1,
          texture: gl.createTexture()
        })
        : map[uName], texture = ref$.texture, idx = ref$.idx;
      uTexture = this.gl.getUniformLocation(pobj, uName);
      this.gl.uniform1i(uTexture, idx);
      gl.activeTexture(gl.TEXTURE0 + idx);
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
      if (!img) {
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, this.width * this.scale, this.height * this.scale, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
      } else {
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
      }
      return texture;
    },
    input: function(){
      var args, res$, i$, to$, i, results$ = [];
      res$ = [];
      for (i$ = 0, to$ = arguments.length; i$ < to$; ++i$) {
        res$.push(arguments[i$]);
      }
      args = res$;
      for (i$ = 1, to$ = args.length; i$ <= to$; ++i$) {
        i = i$;
        results$.push(this.setInput(i, args[i - 1]));
      }
      return results$;
    },
    setInput: function(idx, src){
      return this.inputs["uIn" + idx] = src instanceof renderer ? src.domElement : src;
    },
    makeShader: function(code, type){
      var gl, shader;
      gl = this.gl;
      shader = gl.createShader(type);
      gl.shaderSource(shader, code);
      gl.compileShader(shader);
      if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.log(gl.getShaderInfoLog(shader));
        console.log(code);
      }
      return shader;
    },
    buildPipeline: function(){
      var ref$, gl, ps, pp, i$, to$, link, i, results$ = [], results1$ = [];
      ref$ = [this.gl, this.programs, this.pipeline], gl = ref$[0], ps = ref$[1], pp = ref$[2];
      if (pp) {
        for (i$ = 0, to$ = pp.link; i$ < to$; ++i$) {
          link = i$;
          link[0];
        }
        for (i$ = 0, to$ = ps.length; i$ < to$; ++i$) {
          i = i$;
          if (!in$(i, pp.src)) {
            results$.push(ps[i].data.uIn);
          }
        }
        return results$;
      } else {
        for (i$ = 0, to$ = ps.length - 1; i$ < to$; ++i$) {
          i = i$;
          ps[i].data.fbo = gl.createFramebuffer();
          ps[i].data.db = gl.createRenderbuffer();
        }
        for (i$ = 1, to$ = ps.length; i$ < to$; ++i$) {
          i = i$;
          gl.useProgram(ps[i].obj);
          ps[i].data["uIn" + i] = this.texture(ps[i], "uIn" + i, null);
          gl.bindFramebuffer(gl.FRAMEBUFFER, ps[i - 1].data.fbo);
          gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, ps[i].data["uIn" + i], 0);
          gl.bindRenderbuffer(gl.RENDERBUFFER, ps[i - 1].data.db);
          gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT16, this.width, this.height);
          results1$.push(gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, ps[i - 1].data.db));
        }
        return results1$;
      }
    },
    makeProgram: function(shader, pprogram){
      var gl, ref$, pdata, pobj, program, vs, fs, positionLocation;
      gl = this.gl;
      ref$ = [
        {
          textureMap: {}
        }, gl.createProgram()
      ], pdata = ref$[0], pobj = ref$[1];
      program = {
        data: pdata,
        obj: pobj
      };
      vs = this.makeShader(shader.vertexShader || defaultVertexShader, gl.VERTEX_SHADER);
      fs = this.makeShader(shader.fragmentShader || defaultFragmentShader, gl.FRAGMENT_SHADER);
      gl.attachShader(pobj, vs);
      gl.attachShader(pobj, fs);
      gl.linkProgram(pobj);
      if (!gl.getProgramParameter(pobj, gl.LINK_STATUS)) {
        console.log(gl.getProgramInfoLog(pobj));
      }
      gl.useProgram(pobj);
      if (shader.buffer) {
        shader.buffer(this, program);
      } else {
        pdata.buffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, pdata.buffer);
        pdata.array = new Float32Array([-1, -1, 0, 1, -1, 0, -1, 1, 0, -1, 1, 0, 1, -1, 0, 1, 1, 0]);
        gl.bufferData(gl.ARRAY_BUFFER, pdata.array, gl.STATIC_DRAW);
        positionLocation = gl.getAttribLocation(pobj, "position");
        gl.enableVertexAttribArray(positionLocation);
        gl.vertexAttribPointer(positionLocation, 3, gl.FLOAT, false, 0, 0);
      }
      return program;
    },
    mergeBuffers: function(buffers){
      var list, k, v, length, merged, offset, i$, len$, buf;
      buffers == null && (buffers = []);
      list = Array.isArray(buffers)
        ? buffers
        : (function(){
          var ref$, results$ = [];
          for (k in ref$ = buffers) {
            v = ref$[k];
            results$.push((v.name = k, v));
          }
          return results$;
        }());
      length = list.reduce(function(a, b){
        return a + b.data.length;
      }, 0);
      merged = new Float32Array(length);
      offset = 0;
      for (i$ = 0, len$ = list.length; i$ < len$; ++i$) {
        buf = list[i$];
        buf.offset = offset;
        buf.length = buf.data.length;
        merged.set(buf.data, offset);
        offset += buf.length;
      }
      return {
        buffer: merged,
        list: list
      };
    },
    bindAttrs: function(program, buffers){
      var gl, list, k, v, i$, len$, buf, opt, loc, results$ = [];
      gl = this.gl;
      list = Array.isArray(buffers)
        ? buffers
        : (function(){
          var ref$, results$ = [];
          for (k in ref$ = buffers) {
            v = ref$[k];
            results$.push((v.name = k, v));
          }
          return results$;
        }());
      for (i$ = 0, len$ = list.length; i$ < len$; ++i$) {
        buf = list[i$];
      }
      opt = {
        compSize: 3,
        type: gl.FLOAT,
        normalized: false,
        stride: 0,
        offset: 0
      };
      for (i$ = 0, len$ = list.length; i$ < len$; ++i$) {
        buf = list[i$];
        opt = import$(opt, buf);
        loc = gl.getAttribLocation(program.obj, buf.name);
        gl.vertexAttribPointer(loc, opt.compSize, opt.type, opt.normalized, opt.stride, opt.offset * this.sizeof(opt.type));
        results$.push(gl.enableVertexAttribArray(loc));
      }
      return results$;
    },
    destroy: function(){
      this.stop();
      if (this.root !== this.canvas) {
        return this.root.removeChild(this.canvas);
      }
    },
    stop: function(){
      return this.animate.running = false;
    },
    animate: function(cb, options){
      var _, this$ = this;
      this.animate.running = true;
      _ = function(t){
        if (!this$.animate.running) {
          return;
        }
        requestAnimationFrame(function(t){
          return _(t * 0.001);
        });
        if (cb) {
          cb(t);
        }
        return this$.render(t, options);
      };
      return _(0);
    },
    render: function(t, options){
      var gl, i$, to$, i, ref$, pdata, pobj, shader, uTime, k, v, u, that, ctx, sx, sy;
      t == null && (t = 0);
      options == null && (options = {});
      if (!this.inited) {
        this.init();
      }
      gl = this.gl;
      for (i$ = 0, to$ = this.programs.length; i$ < to$; ++i$) {
        i = i$;
        ref$ = [this.programs[i].data, this.programs[i].obj, this.shader[i]], pdata = ref$[0], pobj = ref$[1], shader = ref$[2];
        gl.useProgram(pobj);
        uTime = gl.getUniformLocation(pobj, "uTime");
        gl.uniform1f(uTime, t);
        for (k in ref$ = shader.uniforms || {}) {
          v = ref$[k];
          if (v.type === 't') {
            this.texture(this.programs[i], k, v.value);
          } else {
            u = gl.getUniformLocation(pobj, k);
            if (/^Matrix/.exec(v.type)) {
              gl["uniform" + v.type](u, false, v.value);
            } else {
              gl["uniform" + v.type](u, v.value);
            }
          }
        }
        if (i === 0) {
          for (k in ref$ = this.inputs) {
            v = ref$[k];
            this.texture(this.programs[i], k, v);
          }
        }
        gl.bindFramebuffer(gl.FRAMEBUFFER, pdata.fbo);
        gl.viewport(0, 0, this.width * this.scale, this.height * this.scale);
        if (that = shader.render) {
          that(this, this.programs[i], t);
        } else {
          gl.clearColor(1, 0, 0, 1);
          gl.clear(gl.COLOR_BUFFER_BIT);
          gl.drawArrays(gl.TRIANGLES, 0, 6);
        }
      }
      ctx = this.canvas.getContext('2d');
      ref$ = [this.flipx ? -1 : 1, this.flipy ? -1 : 1], sx = ref$[0], sy = ref$[1];
      ctx.scale(sx, sy);
      return ctx.drawImage(this._canvas, 0, 0, sx * this.width, sy * this.height);
    },
    resize: function(){
      var ref$, i$, to$, i, pobj, uResolution;
      ref$ = this.canvas;
      ref$.width = this.width * this.scale;
      ref$.height = this.height * this.scale;
      ref$ = this._canvas;
      ref$.width = this.width * this.scale;
      ref$.height = this.height * this.scale;
      ref$ = this.canvas.style;
      ref$.width = this.width + "px";
      ref$.height = this.height + "px";
      ref$ = this._canvas.style;
      ref$.width = this.width + "px";
      ref$.height = this.height + "px";
      this.gl.viewport(0, 0, this.gl.drawingBufferWidth * this.scale, this.gl.drawingBufferHeight * this.scale);
      for (i$ = 0, to$ = this.programs.length; i$ < to$; ++i$) {
        i = i$;
        pobj = this.programs[i].obj;
        this.gl.useProgram(pobj);
        uResolution = this.gl.getUniformLocation(pobj, "uResolution");
        this.gl.uniform2fv(uResolution, [this.width * this.scale, this.height * this.scale]);
      }
      this.flipx = (ref$ = this.flip) === 'horizontal' || ref$ === 'diagonal';
      return this.flipy = (ref$ = this.flip) === 'vertical' || ref$ === 'diagonal';
    }
  });
  if (typeof module != 'undefined' && module !== null) {
    module.exports = {
      renderer: renderer
    };
  } else if (typeof window != 'undefined' && window !== null) {
    window.shaderlib = {
      renderer: renderer
    };
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
  function in$(x, xs){
    var i = -1, l = xs.length >>> 0;
    while (++i < l) if (x === xs[i]) return true;
    return false;
  }
}).call(this);
