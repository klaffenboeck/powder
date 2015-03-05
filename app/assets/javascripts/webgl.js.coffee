#= require brush
#= require sampling
#= require line_chart

class @Webgl
  constructor: (options={}) ->
    {@select} = options
    @canvas = document.querySelector(@select)
    @gl = @canvas.getContext("webgl") or @canvas.getContext("experimental-webgl")
    @setupGL(@gl)

  program = undefined
  size = undefined

  # @setupGL: (gl) ->
  @setupGL: (gl) ->
    vertexShader = gl.createShader(gl.VERTEX_SHADER)
    gl.shaderSource vertexShader, document.querySelector("#vertex-shader").textContent
    gl.compileShader vertexShader
    throw new Error(gl.getShaderInfoLog(vertexShader))  unless gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)
    
    # Compile the fragment shader.
    fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)
    gl.shaderSource fragmentShader, document.querySelector("#fragment-shader").textContent
    gl.compileShader fragmentShader
    throw new Error(gl.getShaderInfoLog(fragmentShader))  unless gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)
    
    # Link and use the program.
    program = gl.createProgram()
    gl.attachShader program, vertexShader
    gl.attachShader program, fragmentShader
    gl.linkProgram program
    throw new Error(gl.getProgramInfoLog(program))  unless gl.getProgramParameter(program, gl.LINK_STATUS)
    gl.useProgram program
    gl.positionBuffer = gl.createBuffer()
    gl.positionAttribute = gl.getAttribLocation(program, "a_position")
    gl.colorBuffer = gl.createBuffer()
    gl.colorAttribute = gl.getAttribLocation(program, "a_color")
    gl.sizeUniform = gl.getUniformLocation(program, "u_size")
    gl.u_step = gl.getUniformLocation(program, "u_step")
    gl.u_colorValues = gl.getUniformLocation(program, "u_colorValues")
    gl.u_length = gl.getUniformLocation(program, "u_length")
    gl.uniform1f(gl.sizeUniform, 1.0)
    gl.program = program
    return gl

  @setupGL: (gl) ->
    vertexShader = gl.createShader(gl.VERTEX_SHADER)
    gl.shaderSource vertexShader, document.querySelector("#vertex-shader").textContent
    gl.compileShader vertexShader
    throw new Error(gl.getShaderInfoLog(vertexShader))  unless gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)
    
    # Compile the fragment shader.
    fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)
    gl.shaderSource fragmentShader, document.querySelector("#fragment-shader").textContent
    gl.compileShader fragmentShader
    throw new Error(gl.getShaderInfoLog(fragmentShader))  unless gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)
    
    # Link and use the program.
    program = gl.createProgram()
    gl.attachShader program, vertexShader
    gl.attachShader program, fragmentShader
    gl.linkProgram program
    throw new Error(gl.getProgramInfoLog(program))  unless gl.getProgramParameter(program, gl.LINK_STATUS)
    gl.useProgram program
    gl.positionBuffer = gl.createBuffer()
    gl.positionAttribute = gl.getAttribLocation(program, "a_position")
    gl.colorBuffer = gl.createBuffer()
    gl.colorAttribute = gl.getAttribLocation(program, "a_color")
    gl.sizeUniform = gl.getUniformLocation(program, "u_size")
    gl.u_step = gl.getUniformLocation(program, "u_step")
    gl.u_colorValues = gl.getUniformLocation(program, "u_colorValues")
    gl.u_length = gl.getUniformLocation(program, "u_length")
    gl.uniform1f(gl.sizeUniform, 1.0)
    return gl

  redraw: =>
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    @gl.uniform1f(@gl.sizeUniform, 3.0)

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.positionBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      -3.0, -3.0,
      +3.0, -3.0,
      +3.0, +3.0,
      -3.0, +3.0
    ]), @gl.STATIC_DRAW

    # Bind the position buffer to the position attribute.
    @gl.getAttribLocation(program, "a_position")
    @gl.enableVertexAttribArray @gl.positionAttribute
    @gl.vertexAttribPointer @gl.positionAttribute, 2, @gl.FLOAT, false, 0, 0

    @gl.uniform1fv(@gl.u_step, new Float32Array([0.25, 0.50, 0.75, 1.0]))
    @gl.uniform4fv(@gl.u_colorValues, new Float32Array([
      1.0, 0.0, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    ]))


    # Define the colors (as RGBA vec4) for each vertex in the square.
    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      0.1
      0.4
      0.7
      1.0

    ]), @gl.STATIC_DRAW

    # Bind the color buffer to the color attribute.
    @gl.cattribute = @gl.getAttribLocation(program, "a_color")
    @gl.enableVertexAttribArray @gl.cattribute
    @gl.vertexAttribPointer @gl.colorAttribute, 1, @gl.FLOAT, false, 0, 0

    # Draw the square!
    @gl.drawArrays @gl.TRIANGLE_FAN, 0, 4

class @SetupWebGL
  @setupGL: (gl) ->
    vertexShader = gl.createShader(gl.VERTEX_SHADER)
    gl.shaderSource vertexShader, document.querySelector("#vertex-shader").textContent
    gl.compileShader vertexShader
    throw new Error(gl.getShaderInfoLog(vertexShader))  unless gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)
    
    # Compile the fragment shader.
    fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)
    gl.shaderSource fragmentShader, document.querySelector("#fragment-shader").textContent
    gl.compileShader fragmentShader
    throw new Error(gl.getShaderInfoLog(fragmentShader))  unless gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)
    
    # Link and use the program.
    program = gl.createProgram()
    gl.attachShader program, vertexShader
    gl.attachShader program, fragmentShader
    gl.linkProgram program
    throw new Error(gl.getProgramInfoLog(program))  unless gl.getProgramParameter(program, gl.LINK_STATUS)
    gl.useProgram program
    gl.positionBuffer = gl.createBuffer()
    gl.positionAttribute = gl.getAttribLocation(program, "a_position")
    gl.colorBuffer = gl.createBuffer()
    gl.colorAttribute = gl.getAttribLocation(program, "a_color")
    gl.sizeUniform = gl.getUniformLocation(program, "u_size")
    gl.u_step = gl.getUniformLocation(program, "u_step")
    gl.u_colorValues = gl.getUniformLocation(program, "u_colorValues")
    gl.u_length = gl.getUniformLocation(program, "u_length")
    gl.uniform1f(gl.sizeUniform, 1.0)
    gl.program = program
    return gl

class @WebglLegend2
  constructor: (options={}) ->
    {@select} = options
    @slider_value = parseInt($(@select).data("slider-max"))
    @slider = new Slider({select: "#brush", legend: @})
    @canvas = document.querySelector(@select)
    @gl = @canvas.getContext("webgl") or @canvas.getContext("experimental-webgl")
    @gl = SetupWebGL.setupGL(@gl)
    @redraw()
    @clickPosition()


  redraw: =>
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    # @gl.uniform1f(@gl.sizeUniform, 3.0)

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.positionBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      -1.0, -1.0,
      +1.0, -1.0,
      +1.0, +1.0,
      -1.0, +1.0
    ]), @gl.STATIC_DRAW

    # Bind the position buffer to the position attribute.
    @gl.getAttribLocation(@gl.program, "a_position")
    @gl.enableVertexAttribArray @gl.positionAttribute
    @gl.vertexAttribPointer @gl.positionAttribute, 2, @gl.FLOAT, false, 0, 0

    # @gl.uniform1fv(@u_step, new Float32Array([0.25, 0.50, 0.75, 1.0]))
    # @gl.uniform4fv(@u_colorValues, new Float32Array([
    #   1.0, 0.0, 0.0, 1.0,
    #   0.0, 1.0, 0.0, 1.0,
    #   0.0, 0.0, 1.0, 1.0,
    #   1.0, 1.0, 1.0, 1.0
    # ]))

    @gl.uniform1fv(@gl.u_step, @slider.getCompleteValueArray())
    @gl.uniform4fv(@gl.u_colorValues, @slider.getCompleteColorArray())


    # Define the colors (as RGBA vec4) for each vertex in the square.
    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      0.0
      1.0
      1.0
      0.0

    ]), @gl.STATIC_DRAW

    # Bind the color buffer to the color attribute.
    @gl.cattribute = @gl.getAttribLocation(@gl.program, "a_color")
    @gl.enableVertexAttribArray @gl.cattribute
    @gl.vertexAttribPointer @gl.colorAttribute, 1, @gl.FLOAT, false, 0, 0

    # Draw the square!
    @gl.drawArrays @gl.TRIANGLE_FAN, 0, 4

  addHandle: (options={}) =>
    @slider.addHandle(options)


  # Only for presentation, has to be rewritten
  clickPosition: =>
    _slider = @slider
    $("#gl_legend").click( (e) ->
      posX = $(@).offset().left
      # alert(e.pageX - posX)
      pos = (e.pageX - posX)
      # colorvalue = _slider.getColorAt(pos / $("#webgl").width())
      _slider.addHandle({position: pos, autocolor: true})
    )


class @ProjectionView
  _current_type = undefined
  constructor: (options = {}) ->
    {@sampling, @x, @y, @slider, @select, @holder, @width} = options
    @number_of_bins = @sampling.number_of_bins
    @intersection_points = {results: [], samples: [], normal_samples: []}
    @value_width = 1 # to be changed
    @tile_width = @value_width / @number_of_bins
    @max_weight_factor = Math.sqrt(Math.pow(@tile_width, 2) * 2)
    # @currentValues = @getMaxima()
    @canvas = document.querySelector(@select + " .complex-slide")
    @gl = @canvas.getContext("webgl") or @canvas.getContext("experimental-webgl")
    @gl = SetupWebGL.setupGL(@gl)
    @slider.subscribe(@)
    @hoverPosition()

  redraw: =>
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    # @gl.uniform1f(@gl.sizeUniform, 3.0)

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.positionBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(
      @getAllDrawingPositions()
    ), @gl.STATIC_DRAW

    # Bind the position buffer to the position attribute.
    @gl.getAttribLocation(@gl.program, "a_position")
    @gl.enableVertexAttribArray @gl.positionAttribute
    @gl.vertexAttribPointer @gl.positionAttribute, 2, @gl.FLOAT, false, 0, 0

    @gl.uniform1fv(@gl.u_step, @slider.getCompleteValueArray())
    @gl.uniform4fv(@gl.u_colorValues, @slider.getCompleteColorArray())

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(
      @getAllDrawingColorValues()
    ), @gl.STATIC_DRAW

    # Bind the color buffer to the color attribute.
    @gl.cattribute = @gl.getAttribLocation(@gl.program, "a_color")
    @gl.enableVertexAttribArray @gl.cattribute
    @gl.vertexAttribPointer @gl.colorAttribute, 1, @gl.FLOAT, false, 0, 0

    # Draw the square!
    @gl.drawArrays @gl.TRIANGLES, 0, 2400

  setX: (x) =>
    @x = x unless x == null

  setY: (y) =>
    @y = y unless y == null

  setToMin: =>
    _current_type = "min"

  setToMax: =>
    _current_type = "max"

  getMaxima: (x = null, y = null) =>
    @setX(x) if x != null
    @setY(y) if y != null
    @drawAxis(x, y)
    @setToMax()
    @currentValues = @sampling.getBins(@x, @y).getMaxima()
    @generateTiles()
    @redraw()

  getMinima: (x = null, y = null) =>
    @setX(x) if x != null
    @setY(y) if y != null
    @drawAxis(x, y)
    @setToMin()
    @currentValues = @sampling.getBins(@x, @y).getMinima()
    @generateTiles()
    @redraw()

  generateTiles: =>
    @tile_list = []
    @generateIntersectionPoints()
    for y_counter in [0..@number_of_bins - 1]
      for x_counter in [0..@number_of_bins - 1]
        tile = @createTile(x_counter, y_counter)
        @tile_list.push(tile)

  generateIntersectionPoints: =>
    intersection_points = []
    for y_counter in [0..@number_of_bins]
      for x_counter in [0..@number_of_bins]
        bottom_left = @getNormalSamplesAtPosition(x_counter - 1, y_counter - 1)
        bottom_right = @getNormalSamplesAtPosition(x_counter, y_counter - 1)
        top_left = @getNormalSamplesAtPosition(x_counter - 1, y_counter)
        top_right = @getNormalSamplesAtPosition(x_counter, y_counter)
        value = @calculateIntersectionPoint(x_counter, y_counter, bottom_left, bottom_right, top_left, top_right)
        intersection_points.push(value)
    @intersection_points.normal_samples = intersection_points
    @intersection_points.samples = @sampling.map(null, intersection_points)
    @intersection_points.results = @sampling.computeResults({samples: @intersection_points.samples})
    return @intersection_points

  getAllDrawingPositions: =>
    array = []
    for tile in @tile_list
      array.push(tile.getDrawingPositions())
    merged = [].concat.apply([], array)
    return merged

  getAllDrawingColorValues: =>
    array = []
    for tile in @tile_list
      array.push(tile.getDrawingColorValues())
    merged = [].concat.apply([], array)
    return merged

  getValueAtPosition: (x, y) =>
    console.log("DEPRECATED :  use @calculateArrayPosition(x,y) instead")
    if @_checkPosition()
      return x + y * @number_of_bins
    null

  calculateArrayPosition: (x,y) =>
    if @_checkPosition(x, y)
      return x + y * @number_of_bins
    null

  _calculateIArrayPosition: (x,y) =>
    return x + y * (@number_of_bins + 1)

  getSamplesAtPosition: (x, y) =>
    pos = @calculateArrayPosition(x,y)
    return @currentValues.samples[pos] if pos != null
    null

  getResultsAtPosition: (x, y) =>
    pos = @calculateArrayPosition(x,y)
    return @currentValues.results[pos] if pos != null
    null

  getObjectAtPosition: (x, y) =>
    obj = {
      result: @getResultsAtPosition(x,y),
      sample: @getSamplesAtPosition(x,y),
      normal_sample: @getNormalSamplesAtPosition(x,y)
    }
    return obj

  getIObjectAtPosition: (x, y) =>
    pos = @_calculateIArrayPosition(x, y)
    obj = {
      result: @intersection_points.results[pos],
      sample: @intersection_points.samples[pos],
      normal_sample: @intersection_points.normal_samples[pos]
    }

  getNormalSamplesAtPosition: (x, y) =>
    pos = @calculateArrayPosition(x,y)
    return @currentValues.normal_samples[pos] if pos != null
    null

  _checkPosition: (x, y, number = null) =>
    number = number ? @number_of_bins
    if(x < 0 or x >= number or y < 0 or y >= number)
      return false
    true

  createTile: (x, y) =>
    tile = new Tile
      # center: @getObjectAtPosition(x, y)
      bottom_left: @getIObjectAtPosition(x, y)
      bottom_right: @getIObjectAtPosition(x + 1, y)
      top_left: @getIObjectAtPosition(x, y + 1)
      top_right: @getIObjectAtPosition(x + 1, y + 1)
      x: @x
      y: @y
    return tile

  calculateIntersectionPoint: (centerPosX, centerPosY, bottom_left, bottom_right, top_left, top_right) =>
    centerX = centerPosX * @tile_width
    centerY = centerPosY * @tile_width
    bl = [centerX - bottom_left[@x], centerY - bottom_left[@y]] if bottom_left
    br = [bottom_right[@x] - centerX, centerY - bottom_right[@y]] if bottom_right
    tl = [centerX - top_left[@x], top_left[@y] - centerY] if top_left
    tr = [top_right[@x] - centerX, top_right[@y] - centerY] if top_right
    bl_weight = @calculateWeight(bl)
    br_weight = @calculateWeight(br)
    tl_weight = @calculateWeight(tl)
    tr_weight = @calculateWeight(tr)
    ret_array = []
    for pos in [0..@sampling.dims - 1]
      if pos == @x or pos == @y
        ret_array.push(centerX) if pos == @x
        ret_array.push(centerY) if pos == @y
      else
        bl_value = if bl_weight then bottom_left[pos] * bl_weight else 0
        br_value = if br_weight then bottom_right[pos] * br_weight else 0
        tl_value = if tl_weight then top_left[pos] * tr_weight else 0
        tr_value = if tr_weight then top_right[pos] * tr_weight else 0
        weight = bl_weight + br_weight + tl_weight + tr_weight
        total = bl_value + br_value + tl_value + tr_value
        value = if weight then total / weight else total 
        ret_array.push(value)
    return ret_array

  calculateWeight: (array = null) =>
    return @max_weight_factor - Math.sqrt(Math.pow(array[0], 2) + Math.pow(array[1], 2)) if array
    return 0

  drawAxis: (x, y) =>
    @drawAxisX(x)
    @drawAxisY(y)

  drawAxisX: (num) =>
    axis = @holder.getAxis(num, "bottom")
    svg = d3.select(@select + " .axis.x")
    svg.call(axis)

  drawAxisY: (num) =>
    axis = @holder.getAxis(num,"left")
    svg = d3.select(@select + " .axis.y")
    svg.call(axis)

  hoverPosition: =>
    that = @
    x = undefined
    y = undefined
    $(@select + " .complex-slide").mousemove( (e) ->
      window.m.navigation.show_preview_lines()
      posX = $(@).offset().left
      posY = $(@).offset().top
      x = e.pageX - posX + 0.5
      y = e.pageY - posY + 0.5
      y = @width - y
      t = that.getSampleValue(x, y)
      window.m.navigation.estimate_preview(t)
    ).mouseleave( (e) ->
      window.m.navigation.hide_preview_lines()
    ).mousedown( (e) ->
      vals = that.getSampleValue(x, y)
      window.m.navigation.set_current_x_values(vals)
      window.m.navigation.estimate_all_lines()
    )

  convertHoverToPos: (val) =>
    retval = Math.floor(val / @width * @number_of_bins)

  getSampleValue: (posX, posY) =>
    normalX = posX / @width
    normalY = posY / @width
    tileX = @convertHoverToPos(posX)
    tileY = @convertHoverToPos(posY)
    tile = @tile_list[tileX + tileY * @number_of_bins]
    inputX = (normalX - @tile_width * tileX) * @number_of_bins
    inputY = (normalY - @tile_width * tileY) * @number_of_bins
    t = tile.getSampleAtNormalPosition(inputX, inputY)

   


class @Tile
  constructor: (options = {}) ->
    {@bottom_left, @bottom_right, @top_left, @top_right, @center, @x, @y} = options
    @center = options.center ? @calculateCenter()
    @all = {
      bottom_left: @bottom_left, 
      bottom_right: @bottom_right, 
      top_left: @top_left, 
      top_right: @top_right, 
      center: @center 
    }
    @factor = options.factor ? 1
    for key, value of @all
      value["map_position"] = @mapPoint(value.normal_sample)

  getDrawingPositions: =>
    array = [
      # @bottom_left.map_position, @bottom_right.map_position, @center.map_position,
      # @bottom_right.map_position, @top_right.map_position, @center.map_position,
      # @top_right.map_position, @top_left.map_position, @center.map_position,
      # @top_left.map_position, @bottom_left.map_position, @center.map_position
      @top_left.map_position, @top_right.map_position, @bottom_right.map_position, 
      @top_left.map_position, @bottom_left.map_position, @bottom_right.map_position
    ]
    ret_array = [].concat.apply([], array)
    return ret_array

  getDrawingColorValues: =>
    array = [
      # @bottom_left.result, @bottom_right.result, @center.result,
      # @bottom_right.result, @top_right.result, @center.result,
      # @top_right.result, @top_left.result, @center.result,
      # @top_left.result, @bottom_left.result, @center.result
      @top_left.result, @top_right.result, @bottom_right.result,
      @top_left.result, @bottom_left.result, @bottom_right.result
    ]
    return array

  mapPoint: (position, x = null, y = null, f = null) =>
    x = x ? @x
    y = y ? @y
    f = f ? @factor
    x_mapped = position[x] * 2 - f
    y_mapped = position[y] * 2 - f
    return [x_mapped, y_mapped]

  calculateCenter: =>
    result = (@bottom_left.result + @bottom_right.result + @top_left.result + @top_right.result) / 4
    normal_sample = []
    for pos in [0..@bottom_left.normal_sample.length - 1]
      nsX1 = (@bottom_right.normal_sample[pos] - @bottom_left.normal_sample[pos]) / 2 + @bottom_left.normal_sample[pos]
      nsX2 = (@top_right.normal_sample[pos] - @top_left.normal_sample[pos]) / 2 + @top_left.normal_sample[pos]
      normal_sample.push((nsX2 - nsX1) / 2 + nsX1)
    obj = {result: result, normal_sample: normal_sample}
    # console.log(obj)
    return obj

  getSampleAtNormalPosition: (x, y) =>
    length = @bottom_left.sample.length

    array = []
    for pos in [0..length - 1]
      bottom = (@bottom_right.sample[pos] - @bottom_left.sample[pos]) * x + @bottom_left.sample[pos]
      top = (@top_right.sample[pos] - @top_left.sample[pos]) * x + @top_left.sample[pos]
      value = (top - bottom) * y + bottom
      
      array.push(value)
    return array









