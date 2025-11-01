# Renderer Feedback 機制實作需求

## 目標
為 `renderer.ls` 加入讀取前 N 幀畫面的功能，讓 GLSL shader 可以存取歷史 frame 數據，用於實作 Reaction-Diffusion、Motion Blur、Trail Effects 等效果。

---

## 技術方案：Ring Buffer

使用 **環形緩衝區 (Ring Buffer)** 保存多個歷史 framebuffer，每幀循環讀寫：

```
Frame 1: 寫入 Buffer[0], 讀取 Buffer[3,2,1]
Frame 2: 寫入 Buffer[1], 讀取 Buffer[0,3,2]
Frame 3: 寫入 Buffer[2], 讀取 Buffer[1,0,3]
Frame 4: 寫入 Buffer[3], 讀取 Buffer[2,1,0]
...循環
```

---

## 實作細節

### 1. Shader 定義新增參數

在創建 renderer 時，允許指定 `feedback` 和 `historySize`：

```javascript
const r = new renderer({
  feedback: true,        // 啟用 feedback
  historySize: 3,        // 保留前 3 幀（預設 1）
  fragmentShader: `
    uniform sampler2D uPrevFrame1;  // 前 1 幀
    uniform sampler2D uPrevFrame2;  // 前 2 幀
    uniform sampler2D uPrevFrame3;  // 前 3 幀
    // ...
  `
});
```

### 2. 修改 `make-program` 方法

在程式初始化時創建 Ring Buffer：

```livescript
make-program: (shader, pprogram) ->
  gl = @gl
  [pdata, pobj] = [{texture-map: {}}, gl.createProgram!]
  program = {data: pdata, obj: pobj, lastimg: null}
  
  # ... 原有的 shader 編譯代碼 ...
  
  # 新增：如果啟用 feedback，創建 Ring Buffer
  if shader.feedback =>
    historySize = shader.historySize or 1
    gl.useProgram pobj
    
    pdata.feedback = {
      current: 0                    # 當前寫入的 buffer index
      size: historySize             # 歷史幀數量
      fbos: []                      # framebuffer 陣列
      textures: []                  # texture 陣列
    }
    
    # 創建 historySize + 1 個 buffers（+1 給當前寫入用）
    for i from 0 to historySize =>
      fbo = gl.createFramebuffer!
      tex = gl.createTexture!
      
      # 設置 texture
      gl.activeTexture(gl.TEXTURE0 + i)
      gl.bindTexture gl.TEXTURE_2D, tex
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
      gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, @width * @scale, @height * @scale, 0, gl.RGBA, gl.UNSIGNED_BYTE, null
      
      # 綁定 framebuffer
      gl.bindFramebuffer gl.FRAMEBUFFER, fbo
      gl.framebufferTexture2D gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, tex, 0
      
      pdata.feedback.fbos.push fbo
      pdata.feedback.textures.push tex
  
  return program
```

### 3. 修改 `render` 方法

每幀渲染時：
1. 綁定前 N 幀的 textures 到 `uPrevFrame1`, `uPrevFrame2`, ...
2. 渲染到當前 buffer
3. 更新 current index

```livescript
render: (t = 0, options={}) ->
  if !@inited => @init!
  gl = @gl
  
  for i from 0 til @programs.length =>
    [pdata, pobj, shader] = [@programs[i].data, @programs[i].obj, @shader[i]]
    gl.useProgram pobj
    
    # 處理 feedback
    if pdata.feedback =>
      fb = pdata.feedback
      writeIdx = fb.current
      
      # 綁定前 N 幀的 textures
      for j from 0 til fb.size =>
        # 計算讀取的 buffer index（往回數）
        readIdx = (fb.current - j - 1 + fb.size + 1) % (fb.size + 1)
        
        # 綁定到 uPrevFrame{j+1}
        uName = "uPrevFrame#{j + 1}"
        uLoc = gl.getUniformLocation pobj, uName
        if uLoc =>  # 如果 shader 有定義這個 uniform
          gl.uniform1i(uLoc, j)
          gl.activeTexture(gl.TEXTURE0 + j)
          gl.bindTexture gl.TEXTURE_2D, fb.textures[readIdx]
      
      # 渲染到當前 buffer
      gl.bindFramebuffer gl.FRAMEBUFFER, fb.fbos[writeIdx]
    else
      # 原有邏輯：渲染到 pipeline fbo 或 null
      gl.bindFramebuffer gl.FRAMEBUFFER, pdata.fbo
    
    # ... 原有的 uniform 設置代碼 ...
    uTime = gl.getUniformLocation pobj, "uTime"
    gl.uniform1f(uTime, t)
    
    for k,v of (shader.uniforms or {}) =>
      # ... 原有的 uniform 處理 ...
    
    if i == 0 => for k,v of @inputs => @texture @programs[i], k, v
    
    gl.viewport 0, 0, @width * @scale, @height * @scale
    
    if shader.render => that @, @programs[i], t
    else
      gl.clearColor 0,0,0,1
      gl.clear gl.COLOR_BUFFER_BIT
      gl.drawArrays gl.TRIANGLES, 0, 6
    
    # 交換 buffer（更新 current index）
    if pdata.feedback =>
      fb.current = (fb.current + 1) % (fb.size + 1)
  
  # 最後一個 shader 的輸出複製到 canvas
  # 需要從 feedback buffer 讀取
  lastProgram = @programs[@programs.length - 1]
  if lastProgram.data.feedback =>
    # 讀取最新寫入的 buffer
    fb = lastProgram.data.feedback
    prevIdx = (fb.current - 1 + fb.size + 1) % (fb.size + 1)
    gl.bindFramebuffer gl.FRAMEBUFFER, null
    # 這裡需要一個簡單的 blit shader 將 texture 畫到 _canvas
    # 或者直接用 gl.readPixels 讀取後用 canvas 2D context 繪製
  
  ctx = @canvas.getContext \2d
  [sx,sy] = [(if @flipx => -1 else 1), (if @flipy => -1 else 1)]
  ctx.scale sx, sy
  ctx.drawImage @_canvas, 0, 0, sx * @width, sy * @height
```

### 4. 修改 `resize` 方法

視窗大小改變時，需要重建所有 feedback buffers：

```livescript
resize: ->
  @canvas <<< width: @width * @scale, height: @height * @scale
  @_canvas <<< width: @width * @scale, height: @height * @scale
  # ...
  
  # 重建 feedback textures
  for program in @programs =>
    if program.data.feedback =>
      fb = program.data.feedback
      gl = @gl
      for i from 0 til fb.textures.length =>
        gl.bindTexture gl.TEXTURE_2D, fb.textures[i]
        gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, @width * @scale, @height * @scale, 0, gl.RGBA, gl.UNSIGNED_BYTE, null
  
  # ...
```

---

## 使用範例

### 簡單的 Reaction-Diffusion（1 幀歷史）

```javascript
const shader = {
  feedback: true,
  historySize: 1,  // 只需前 1 幀
  fragmentShader: `
    precision highp float;
    uniform vec2 uResolution;
    uniform float uTime;
    uniform sampler2D uPrevFrame1;
    
    void main() {
      vec2 uv = gl_FragCoord.xy / uResolution;
      vec4 prev = texture2D(uPrevFrame1, uv);
      
      // Reaction-Diffusion 計算
      // ...
      
      gl_FragColor = newValue;
    }
  `
};
```

### Motion Blur（4 幀歷史）

```javascript
const shader = {
  feedback: true,
  historySize: 4,
  fragmentShader: `
    precision highp float;
    uniform vec2 uResolution;
    uniform sampler2D uPrevFrame1;
    uniform sampler2D uPrevFrame2;
    uniform sampler2D uPrevFrame3;
    uniform sampler2D uPrevFrame4;
    
    void main() {
      vec2 uv = gl_FragCoord.xy / uResolution;
      
      // 混合前 4 幀
      vec4 color = texture2D(uPrevFrame1, uv) * 0.4;
      color += texture2D(uPrevFrame2, uv) * 0.3;
      color += texture2D(uPrevFrame3, uv) * 0.2;
      color += texture2D(uPrevFrame4, uv) * 0.1;
      
      gl_FragColor = color;
    }
  `
};
```

---

## 注意事項

### 1. 最終輸出處理
有 feedback 的 shader，其輸出在 framebuffer 中，需要特別處理才能顯示到 canvas。建議：
- 在 render 最後，將最新的 feedback texture blit 到 `_canvas`
- 或使用 `gl.readPixels` 讀取後繪製

### 2. Pipeline 整合
如果有多個 shader 串接（pipeline），需要確保：
- 只有最後一個 shader 可能需要 feedback
- 或每個 shader 有獨立的 feedback buffers

### 3. 初始化
第一幀時，`uPrevFrame1` 等會是空的（黑色或透明），shader 需要處理這個狀況。

### 4. Texture Unit 衝突
- Feedback textures 佔用 TEXTURE0, TEXTURE1, ...
- 需確保不與其他 uniforms（如 `uIn1`, `uIn2`）衝突
- 建議從高 index 開始分配（TEXTURE15 往下）

---

## 效能考量

| 歷史幀數 | 記憶體增加 (1080p) | 效能影響 | 建議用途 |
|---------|------------------|---------|---------|
| 1-2 幀 | 16 MB | <5% | Reaction-Diffusion, 迭代系統 |
| 3-4 幀 | 33 MB | 5-10% | Motion Blur, TAA |
| 5-8 幀 | 66 MB | 10-20% | 複雜 feedback 效果 |
| >8 幀 | >66 MB | >20% | 不建議 |

**建議預設值：**
- `historySize: 1`（最常用，效能最好）
- 最大限制：8 幀
- 文件中說明效能權衡

---

## 測試建議

實作後建議測試：
1. **基本功能**：單 shader + feedback，確認能讀取前一幀
2. **多幀歷史**：historySize=4，確認能正確循環
3. **Resize**：改變視窗大小，確認 buffers 正確重建
4. **Pipeline**：多 shader 串接時的行為
5. **效能**：不同 historySize 的 FPS 測試
