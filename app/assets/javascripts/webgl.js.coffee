#= require brush
#= require sampling
#= require line_chart

Array.merge = (array_of_arrays) ->
  merged = []
  merged = merged.concat.apply(merged, array_of_arrays)
  array_of_arrays = merged
  return array_of_arrays


class @GlobalWebGL
  _discrete = 0

  @getDiscrete: =>
    if _discrete
      return 1
    else
      return 0

  @setDiscrete: (bool = false) =>
    _discrete = bool



class @Webgl
  constructor: (options={}) ->
    {@select} = options
    @canvas = document.querySelector(@select)
    @gl = @canvas.getContext("webgl") or @canvas.getContext("experimental-webgl")
    @setupGL(@gl)

  program = undefined
  size = undefined

  # @setupGL: (gl) ->
  # @setupGL: (gl) ->
  #   vertexShader = gl.createShader(gl.VERTEX_SHADER)
  #   gl.shaderSource vertexShader, document.querySelector("#vertex-shader").textContent
  #   gl.compileShader vertexShader
  #   throw new Error(gl.getShaderInfoLog(vertexShader))  unless gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)
    
  #   # Compile the fragment shader.
  #   fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)
  #   gl.shaderSource fragmentShader, document.querySelector("#fragment-shader").textContent
  #   gl.compileShader fragmentShader
  #   throw new Error(gl.getShaderInfoLog(fragmentShader))  unless gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)
    
  #   # Link and use the program.
  #   program = gl.createProgram()
  #   gl.attachShader program, vertexShader
  #   gl.attachShader program, fragmentShader
  #   gl.linkProgram program
  #   throw new Error(gl.getProgramInfoLog(program))  unless gl.getProgramParameter(program, gl.LINK_STATUS)
  #   gl.useProgram program
  #   gl.positionBuffer = gl.createBuffer()
  #   gl.positionAttribute = gl.getAttribLocation(program, "a_position")
  #   gl.colorBuffer = gl.createBuffer()
  #   gl.colorAttribute = gl.getAttribLocation(program, "a_color")
  #   gl.sizeUniform = gl.getUniformLocation(program, "u_size")
  #   gl.u_step = gl.getUniformLocation(program, "u_step")
  #   gl.u_colorValues = gl.getUniformLocation(program, "u_colorValues")
  #   gl.u_length = gl.getUniformLocation(program, "u_length")
  #   gl_u_discrete = gl.getUniformLocation(program, "u_discrete")
  #   gl.uniform1f(gl.sizeUniform, 1.0)
  #   gl.program = program
  #   return gl

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

    console.log("SETUP DISCRETE CALLED")
    gl.uniform1f(gl.sizeUniform, 1.0)
    return gl

  redraw: (bounds = undefined) =>
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
    gl.u_discrete = gl.getUniformLocation(program, "u_discrete")
    gl.uniform1f(gl.sizeUniform, 1.0)
    console.log("SETUP WEBGL CALLED")
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
    @_bottom = 0
    @_top = 1


  redraw: (bounds = undefined) =>
    unless _.isUndefined(bounds)
      @_bottom = bounds[0]
      @_top = bounds[1]
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    # @gl.uniform1f(@gl.sizeUniform, 3.0)

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.positionBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      # -1.0, -1.0,
      # +1.0, -1.0,
      # +1.0, +1.0,
      # -1.0, +1.0
      -1.0, -1.0,
      -1.0, +1.0,
      +1.0, +1.0,
      +1.0, -1.0
    ]), @gl.STATIC_DRAW

    # Bind the position buffer to the position attribute.
    @gl.getAttribLocation(@gl.program, "a_position")
    @gl.enableVertexAttribArray @gl.positionAttribute
    @gl.vertexAttribPointer @gl.positionAttribute, 2, @gl.FLOAT, false, 0, 0


    @gl.uniform1fv(@gl.u_step, @slider.getCompleteValueArray())
    @gl.uniform4fv(@gl.u_colorValues, @slider.getCompleteColorArray())

    @gl.uniform1i(@gl.u_discrete, GlobalWebGL.getDiscrete())


    # Define the colors (as RGBA vec4) for each vertex in the square.
    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      @_bottom
      @_top
      @_top
      @_bottom

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
      posY = $(@).offset().top
      # alert(e.pageX - posX)
      hpos = (e.pageX - posX)
      vpos = (e.pageY - posY)
      # console.log(hpos)
      # console.log(vpos)
      # colorvalue = _slider.getColorAt(pos / $("#webgl").width())
      _slider.addHandle({position: vpos, autocolor: true})
    )


class @ProjectionView
  _current_type = undefined
  _box_positions = []
  _box_color_values = []
  _added_vertices = 0
  constructor: (options = {}) ->

    {@sampling, @x, @y, @slider, @select, @holder, @width} = options

    @number_of_bins = @sampling.number_of_bins
    @intersection_points = {results: [], samples: [], normal_samples: [], points: []}
    @value_width = 1 # to be changed
    @tile_width = @value_width / @number_of_bins
    @max_weight_factor = Math.sqrt(Math.pow(@tile_width, 2) * 2)
    # @currentValues = @getMaxima()
    @canvas = document.querySelector(@select + " .complex-slide")
    @gl = @canvas.getContext("webgl") or @canvas.getContext("experimental-webgl")
    @gl = SetupWebGL.setupGL(@gl)
    @slider.subscribe(@)
    @hoverPosition()
    @addedVertices = 0
    @boxPositions = []
    @boxColorValues = []


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

    @gl.uniform1i(@gl.u_discrete, GlobalWebGL.getDiscrete())

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(
      @getAllDrawingColorValues()
    ), @gl.STATIC_DRAW

    # Bind the color buffer to the color attribute.
    @gl.cattribute = @gl.getAttribLocation(@gl.program, "a_color")
    @gl.enableVertexAttribArray @gl.cattribute
    @gl.vertexAttribPointer @gl.colorAttribute, 1, @gl.FLOAT, false, 0, 0

    # Draw the square!
    @gl.drawArrays @gl.TRIANGLES, 0, 4800



    # STARTING FOR HIGHLIGHTING QUADS
    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.positionBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(
      #[
      # -0.5, -0.5,
      # 0.5, -0.5,
      # 0.5, -0.5,
      # 0.5, 0.5,
      # 0.5, 0.5,
      # -0.5, 0.5,
      # -0.5, 0.5,
      # -0.5, -0.5
      #]
      @getBoxPositions()      
    ), @gl.STATIC_DRAW

    # Bind the position buffer to the position attribute.
    @gl.getAttribLocation(@gl.program, "a_position")
    @gl.enableVertexAttribArray @gl.positionAttribute
    @gl.vertexAttribPointer @gl.positionAttribute, 2, @gl.FLOAT, false, 0, 0

    @gl.uniform1fv(@gl.u_step, @slider.getCompleteValueArray())
    @gl.uniform4fv(@gl.u_colorValues, @slider.getCompleteColorArray())

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(
      @getBoxColorValues()
    ), @gl.STATIC_DRAW

    # Bind the color buffer to the color attribute.
    @gl.cattribute = @gl.getAttribLocation(@gl.program, "a_color")
    @gl.enableVertexAttribArray @gl.cattribute
    @gl.vertexAttribPointer @gl.colorAttribute, 1, @gl.FLOAT, false, 0, 0

    # Draw the square!
    @gl.drawArrays @gl.LINES, 0, @getAddedVertices() #@addedVertices
    

  setBoxHighlighting: (positions, divider = 2) =>
    flat = Array.merge(positions)
    amount = flat.length / divider
    @setBoxPositions(flat)
    @setBoxColorValues(amount)
    @setAddedVertices(amount)

  resetBoxHighlighting: =>
    @setBoxPositions([])
    @setBoxColorValues(0)
    @setAddedVertices(0)


  setBoxPositions: (positions) =>
    _box_positions = positions

  getBoxPositions: =>
    return _box_positions

  setBoxColorValues: (amount, val = 0) =>
    arr = []
    for i in [1..amount]
      arr.push(val)
    _box_color_values = arr

  getBoxColorValues: =>
    return _box_color_values

  setAddedVertices: (amount) =>
    _added_vertices = amount

  getAddedVertices: =>
    return _added_vertices

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

  getQOIs: =>
    projection = undefined
    bins = @sampling.getBins(@x, @y)
    if _current_type == "min"
      projection = bins.getMinima()
    else
      projection = bins.getMaxima()
    points = @convertToProjectionPoints(projection)
    @slider.getAllValues()
    @qoi_list = QOI_List.factory(@slider.getAllValues(), @number_of_bins)
    for point in points
      @qoi_list.insert(point)
    @qoi_list


  convertToProjectionPoints: (obj) =>
    list = []
    for index, i in obj.indices
      point = new ProjectionPoint
        bin_index: index
        projection_index: i
        sample: obj.samples[i]
        normal_sample: obj.normal_samples[i]
        result: obj.results[i]
      list.push(point)
    return list


  generateTiles: =>
    @tile_list = []
    @generateIntersectionPoints()
    for y_counter in [0..@number_of_bins - 1]
      for x_counter in [0..@number_of_bins - 1]
        tile = @createTile(x_counter, y_counter)
        @tile_list.push(tile)

  generateIntersectionPoints: =>
    intersection_points = []
    normal_samples = []
    for y_counter in [0..@number_of_bins]
      for x_counter in [0..@number_of_bins]
        bottom_left = @getObjectAtPosition(x_counter - 1, y_counter - 1)
        bottom_right = @getObjectAtPosition(x_counter, y_counter - 1)
        top_left = @getObjectAtPosition(x_counter - 1, y_counter)
        top_right = @getObjectAtPosition(x_counter, y_counter)
        point = @calculateIntersectionPoint(x_counter, y_counter, bottom_left, bottom_right, top_left, top_right)
        normal_sample = point.normal_sample
        intersection_points.push(point)
        normal_samples.push(normal_sample)
    @intersection_points.normal_samples = normal_samples
    @intersection_points.samples = @sampling.map(null, normal_samples)
    @intersection_points.results = @sampling.computeResults({samples: @intersection_points.samples})
    
    for point, i in intersection_points
      point.sample = @intersection_points.samples[i]
      point.result = @intersection_points.results[i]
    #   point = new IntersectionPoint
    #     sample: @intersection_points.samples[i]
    #     normal_sample: @intersection_points.normal_samples[i]
    #     result: @intersection_points.results[i]
    #   @intersection_points.list.push(point)
    @intersection_points.points = intersection_points
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

  getIntersectionPointAtPosition: (x, y) =>
    pos = @_calculateIArrayPosition(x, y)
    @intersection_points.points[pos]

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
      # bottom_left: @getIObjectAtPosition(x, y)
      # bottom_right: @getIObjectAtPosition(x + 1, y)
      # top_left: @getIObjectAtPosition(x, y + 1)
      # top_right: @getIObjectAtPosition(x + 1, y + 1)
      bottom_left: @getIntersectionPointAtPosition(x, y)
      bottom_right: @getIntersectionPointAtPosition(x + 1, y)
      top_left: @getIntersectionPointAtPosition(x, y + 1)
      top_right: @getIntersectionPointAtPosition(x + 1, y + 1)
      x: @x
      y: @y
      base: @getObjectAtPosition(x, y)
    return tile

  calculateIntersectionPoint: (centerPosX, centerPosY, obj_bottom_left, obj_bottom_right, obj_top_left, obj_top_right) =>
    centerX = centerPosX * @tile_width
    centerY = centerPosY * @tile_width
    bottom_left = obj_bottom_left.normal_sample
    bottom_right = obj_bottom_right.normal_sample
    top_left = obj_top_left.normal_sample
    top_right = obj_top_right.normal_sample
    bl = [centerX - bottom_left[@x], centerY - bottom_left[@y]] if bottom_left
    br = [bottom_right[@x] - centerX, centerY - bottom_right[@y]] if bottom_right
    tl = [centerX - top_left[@x], top_left[@y] - centerY] if top_left
    tr = [top_right[@x] - centerX, top_right[@y] - centerY] if top_right
    bl_weight = @calculateWeight(bl)
    br_weight = @calculateWeight(br)
    tl_weight = @calculateWeight(tl)
    tr_weight = @calculateWeight(tr)
    weight = bl_weight + br_weight + tl_weight + tr_weight
    normal_sample = []
    for pos in [0..@sampling.dims - 1]
      if pos == @x or pos == @y
        normal_sample.push(centerX) if pos == @x
        normal_sample.push(centerY) if pos == @y
      else
        bl_value = if bl_weight then bottom_left[pos] * bl_weight else 0
        br_value = if br_weight then bottom_right[pos] * br_weight else 0
        tl_value = if tl_weight then top_left[pos] * tr_weight else 0
        tr_value = if tr_weight then top_right[pos] * tr_weight else 0
        total = bl_value + br_value + tl_value + tr_value
        value = if weight then total / weight else total 
        normal_sample.push(value)
    # bl_value = if bl_weight then obj_bottom_left.result * bl_weight else 0
    # br_value = if br_weight then obj_bottom_right.result * br_weight else 0
    # tl_value = if tl_weight then obj_top_left.result * tr_weight else 0
    # tr_value = if tr_weight then obj_top_right.result * tr_weight else 0
    # total = bl_value + br_value + tl_value + tr_value
    bl_value = if bl_weight then obj_bottom_left.result else 0
    br_value = if br_weight then obj_bottom_right.result else 0
    tl_value = if tl_weight then obj_top_left.result else 0
    tr_value = if tr_weight then obj_top_right.result else 0
    divider = 0
    divider += 1 if bl_value
    divider += 1 if br_value
    divider += 1 if tl_value
    divider += 1 if tr_value
    total = (bl_value + br_value + tl_value + tr_value) / divider
    # interpolated_value = if weight then total / weight else total 
    interpolated_value = total 
    point = new IntersectionPoint
      normal_sample: normal_sample
      interpolated_value: interpolated_value
      bl: obj_bottom_left
      br: obj_bottom_right
      tl: obj_top_left
      tr: obj_top_right

    return point


  calculateWeight: (array = null) =>
    return @max_weight_factor - Math.sqrt(Math.pow(array[0], 2) + Math.pow(array[1], 2)) if array
    return 0

  getTiles: (array = []) =>
    tiles = []
    for tile_id in array
      tiles.push(@getTile(tile_id))
    return tiles

  getTile: (pos) =>
    return @tile_list[pos]

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
      #that.addedVertices = 8
      posX = $(@).offset().left
      posY = $(@).offset().top
      x = e.pageX - posX + 0.5
      y = e.pageY - posY + 0.5
      y = @width - y
      t = that.getSampleValue(x, y)
      window.m.navigation.estimate_preview(t[0])

      that.setBoxHighlighting(t[1])
      that.redraw()
    ).mouseleave( (e) ->
      window.m.navigation.hide_preview_lines()
      #that.setAddedVertices(0)
      that.resetBoxHighlighting()
      that.redraw()
    ).mousedown( (e) ->
      vals = that.getSampleValue(x, y)
      window.m.navigation.set_current_x_values(vals[0])
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
    sample = tile.getSampleAtNormalPosition(inputX, inputY)
    bounds = tile.getBoundingPositions()
    return [sample, bounds]

  hoverBounds: (val) =>




class @Tile
  constructor: (options = {}) ->
    {@bottom_left, @bottom_right, @top_left, @top_right, @center, @x, @y, @base} = options
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
      @bottom_left.map_position, @bottom_right.map_position, @center.map_position,
      @bottom_right.map_position, @top_right.map_position, @center.map_position,
      @top_right.map_position, @top_left.map_position, @center.map_position,
      @top_left.map_position, @bottom_left.map_position, @center.map_position
      # @top_left.map_position, @top_right.map_position, @bottom_right.map_position, 
      # @top_left.map_position, @bottom_left.map_position, @bottom_right.map_position
    ]
    ret_array = [].concat.apply([], array)
    return ret_array

  getBoundingPositions: =>
    array = [
      @bottom_left.map_position, @bottom_right.map_position,
      @bottom_right.map_position, @top_right.map_position,
      @top_right.map_position, @top_left.map_position, 
      @top_left.map_position, @bottom_left.map_position
    ]
    ret_array = [].concat.apply([], array)
    return ret_array

  getDrawingColorValues: =>
    array = [
      @bottom_left.getResult(), @bottom_right.getResult(), @center.getResult(),
      @bottom_right.getResult(), @top_right.getResult(), @center.getResult(),
      @top_right.getResult(), @top_left.getResult(), @center.getResult(),
      @top_left.getResult(), @bottom_left.getResult(), @center.getResult()
      # @top_left.result, @top_right.result, @bottom_right.result,
      # @top_left.result, @bottom_left.result, @bottom_right.result
    ]
    # array = []
    # for i in [1..12]
    #   array.push(@base.result)
    return array

  mapPoint: (position, x = null, y = null, f = null) =>
    x = x ? @x
    y = y ? @y
    f = f ? @factor
    x_mapped = position[x] * 2 - f
    y_mapped = position[y] * 2 - f
    return [x_mapped, y_mapped]

  calculateCenter: =>
    result = (@bottom_left.getResult() + @bottom_right.getResult() + @top_left.getResult() + @top_right.getResult()) / 4
    normal_sample = []
    for pos in [0..@bottom_left.normal_sample.length - 1]
      nsX1 = (@bottom_right.normal_sample[pos] - @bottom_left.normal_sample[pos]) / 2 + @bottom_left.normal_sample[pos]
      nsX2 = (@top_right.normal_sample[pos] - @top_left.normal_sample[pos]) / 2 + @top_left.normal_sample[pos]
      normal_sample.push((nsX2 - nsX1) / 2 + nsX1)
    obj = new IntersectionPoint({result: result, interpolated_value: result, normal_sample: normal_sample})
    return obj

  getSampleAtNormalPosition: (x, y) =>
    length = @bottom_left.sample.length

    array = []
    for pos in [0..length - 1]
      bottom = (@bottom_right.sample[pos] - @bottom_left.sample[pos]) * x + @bottom_left.sample[pos]
      top = (@top_right.sample[pos] - @top_left.sample[pos]) * x + @top_left.sample[pos]
      value = (top - bottom) * y + bottom
      
      array.push(value)
    array = @base.sample
    return array



class @SamplePoint 
  constructor: (options={}) ->
    {@normal_sample, @sample, @result} = options

class @IntersectionPoint extends SamplePoint
  constructor: (options={}) ->
    super(options)
    {@interpolated_value, @bl, @br, @tl, @tr} = options

  getResult: =>
    @interpolated_value

class @ProjectionPoint extends SamplePoint
  constructor: (options={}) ->
    super(options)
    @bin_index = options.bin_index
    @projection_index = options.projection_index

  nextX: =>
    @projection_index + 1

  nextY: (offset) =>
    @projection_index + offset




class @QOI_List
  constructor: (options={}) ->
    @qois = options.qois ? []
    @bounds = options.bounds ? []
    @number_of_bins = options.number_of_bins


  @factory: (bins, number_of_bins) ->
    qois = []
    for bin, i in bins
      low = 0
      unless i == 0
        low = bins[i-1]
      high = bin
      qois.push(new QOI({low: low, high: high, offsetY: @number_of_bins}))
    return new QOI_List({qois: qois, bounds: bins, number_of_bins: number_of_bins})

  insert: (point) =>
    for qoi in @qois
      if qoi.rangeCheck(point)
        qoi.add(point)
        break


class @QOI
  _temp_array = []
  _starting_points = []
  _counter = 0
  constructor: (options) ->
    {@low, @high, @offsetY} = options
    @values = []
    @clusters = []

  add: (value) =>
    @values.push(value)

  rangeCheck: (point) =>
    value = if point.constructor == Number then point else point.result
    if value >= @low and value <= @high
      return true
    else
      return false

  cluster: (number_of_lines = 20) =>
    scan = ClusterScan.factory(@values, number_of_lines)
    @clusters = scan.getClusters()
    #return clusters

  getRange: (type = "Array") =>
    return [@low, @high] if type == "Array" or type == "array"
    string = @low + " - " + @high
    return string if type == "String" or type == "string"
    return "<p>" + string + "</p>" if type == "html" or type == "Html" or type == "HTML"


  toHtml: (options = {}) =>
    range = "Range:" + HH.br()
    high = Math.roundFloat(@high, 4)
    low = Math.roundFloat(@low, 4)
    range += " - H: " + high + HH.br() + " - L: " + low
    string1 = "Top projections: " + @values.length
    string2 = "Coherent regions: " + @clusters.length
    html = new HtmlHelper()
    string = string1 + HH.br() + string2
    html.addP(range)
    html.addP(string)
    #html.addP(string2)
    rows = []
    for cluster, i in @clusters 
      rows.push(cluster.toRow({number: i + 1}))
    table = HH.table({rows: rows})
    html.add(table)
    html.print()





class @HtmlHelper
  constructor: (options = {}) ->
    @html = options.html ? ""

  @p: (input) ->
    return "<p>" + input + "</p>"

  @td: (input) ->
    return "<td>" + input + "</td>"


  @tr: (tds = [], id = "") ->
    tr = "<tr>"
    tr = "<tr id='" + id + "'>" if id.length
    for td in tds
      tr += td
    tr += "</tr>" 

  @data: (data, content = undefined) =>
    content = "'" + content + "'" if _.isString(content)
    string = "data-" + data
    string += "=" + content unless _.isUndefined(content)
    return string


  @br: ->
    return "<br />"

  @div: (options = {}) =>
    id = if options.id then " id='" + options.id + "'" else ""
    _klass = if options.class then " class='" + options.class + "'" else ""
    _data = if options.data then " " + options.data else ""
    content = options.content ? ""
    div = "<div" + id + _klass + _data + ">" + content + "</div>"

  @table: (options = {}) ->
    table = "<table class='table table-hover'>"
    header = options.header ? undefined
    table += header if header
    for row in options.rows
      table += row
    table += "</table>"
    return table

  @option: (content, value) =>
    return "<option class='option option-" + value + "' value='" + value + "'>" + content + "</option>"

  @cogSpin: =>
    "<i class='fa fa-cog fa-spin'></i>"

  @pulseSpin: =>
    "<i class='fa fa-spinner fa-pulse'></i>"

  add: (input) =>
    @html += input

  addBr: =>
    @add(HH.br())

  addP: (input) =>
    @add(HH.p(input))

  addDiv: (options = {}) =>
    @add(HH.div(options))

  addOption: (content, value) =>
    @add(HH.option(content, value))


  print: =>
    return @html

  #addSegment: ()

@HH = HtmlHelper



class @ClusterScan
  _start_segments = undefined
  constructor: (options={}) ->
    @scanlines = options.scanlines ? []
    _temp_segments = []

  @factory: (values, number_of_lines) ->
    nol = number_of_lines
    lines = []
    for line in [1..nol]
      lines.push([])
    for val in values
      value = val.projection_index
      pos = Math.floor(value / nol)
      lines[pos].push(value)
    scanlines = []
    for line in lines 
      scanline = ScanLine.factory(line)
      scanlines.push(scanline)   
    clusterscan = new ClusterScan
      scanlines: scanlines
    return clusterscan

  lastLine: =>
    @scanlines[@scanlines.length - 1]

  connectSegments: =>
    for line, i in @scanlines
      unless line == @lastLine()
        line.connectSegments(@scanlines[i + 1])
    return true

  getAllSegments: =>
    segments = []
    for line in @scanlines
      segments.push(line.getSegments())
    merged = []
    merged = merged.concat.apply(merged, segments)
    return merged

  getClusters: =>
    @connectSegments()
    _start_segments = @getAllSegments()
    clusters = []
    while _start_segments.length
      segment = _start_segments.splice(0,1)[0]
      cluster = @buildGraph(segment)
      clusters.push(cluster) unless cluster.isEmpty()

    return clusters


  buildGraph: (segment) =>
    #console.log(segment)
    segments = []
    nexts = []
    segments.push(segment)
    @_removeFromStart(segment)
    for seg in segment.getConnections()
      nexts.push(seg)
      segments.push(seg)
      @_removeFromStart(seg)
    while nexts.length
      next = nexts.splice(0,1)[0]
      @_removeFromStart(next)
      for seg in next.getConnections()
        @_removeFromStart(seg) 
        if segments.indexOf(seg) < 0
          nexts.push(seg)
          segments.push(seg)

    return new Cluster({graph: segments})

  _removeFromStart: (segment) =>
    index = _start_segments.indexOf(segment)
    if index >= 0
      _start_segments.splice(index,1)
      return true
    return false




class @ScanLine
  constructor: (options={}) ->
    @line_segments = options.line_segments ? []
    @original_array = options.original_array


  @factory: (array) ->
    segments = []
    segment = new LineSegment
    segments.push(segment)
    for val in array
      unless segment.add(val)
        segment = new LineSegment
        segments.push(segment)
        segment.add(val)
    scanline = new ScanLine
      line_segments: segments
      original_array: array
    return scanline

  connectSegments: (scanline) =>
    for segment_1 in @line_segments
      for segment_2 in scanline.line_segments
        segment_1.tryToConnect(segment_2)

  getSegments: =>
    @line_segments



class @LineSegment
  constructor: (options={}) ->
    @elements = []
    @elements.push(options.first) if options.first
    @connections = []

  add: (element) =>
    if !@elements.length or @elements[@elements.length - 1] + 1 == element
      @elements.push(element)
      return true
    else
      return false

  tryToConnect: (segment, offsetY = 20) =>
    if @topConnectedTo(segment, offsetY)
      @connections.push(segment)
      segment.connections.push(@)

  topConnectedTo: (segment, offsetY = 20) =>
    for element in @elements
      if segment.elements.indexOf(element + offsetY) >= 0
        return true
    first = @elements[0]
    unless first % offsetY == 0
      if segment.elements.indexOf(first + offsetY - 1) >= 0
        return true
    last = @elements[@elements.length - 1] 
    unless last % offsetY == @elements.length - 1
      if segment.elements.indexOf(last + offsetY + 1) >= 0
        return true
    if @elements.length == 1
      console.log("topConnectedTo?")
      console.log(@)
      console.log(segment)
    return false

  getConnections: =>
    @connections

  getElements: =>
    @elements



class @Cluster
  _hover_id = undefined
  constructor: (options = {}) ->
    @array = []
    @false_array = []
    @graph = options.graph
    @tiles = []
    @_hover_id

  addAdjacent: (value) =>
    if @array.length
      if(@array.indexOf(value - 1) >= 0 or @array.indexOf(value - 20) >= 0)
        @array.push(value)
        return true
      else
        @false_array.push(value)
        return false
    else
      @array.push(value)
      return true

  size: =>
    @array.length

  getValues: =>
    @array

  getIndices: =>
    collected = []
    for segment in @graph
      collected.push(segment.getElements())
    merged = []
    merged = merged.concat.apply(merged, collected)
    merged.sort( (a, b) ->
      return a - b 
    )
    return merged

  numberOfTiles: =>
    @array.length

  setHoverId: (id) =>
    @_hover_id = "cluster-" + id

  getHoverId: =>
    return @_hover_id

  resetHoverId: =>
    @_hover_id = undefined

  isEmpty: =>
    return true if @getIndices().length == 0
    return false

  toRow: (options = {}) =>
    number = options.number
    tds = []
    string = "Region-" + number
    tds.push(HH.td(string))
    tds.push(HH.td(@tiles.length))
    button = HH.div
      id: "cluster-" + number
      data: HH.data("load-cluster", number - 1)
      class: "cluster region region-" + number
      content: "load"
    tds.push(HH.td(button))
    HH.tr(tds, "cluster-" + number)


  checkAdjacence: (cluster) =>
    if @size() > cluster.size()
      for value in cluster.getValues()
        if @getValues().indexOf(value - 1) >= 0 or @getValues().indexOf(value - 20) >= 0 or @getValues().indexOf(value + 1) >= 0 or @getValues().indexOf(value + 20) >= 0
          return true
      return false
    else
      for value in @getValues()
        if cluster.getValues().indexOf(value - 1) >= 0 or cluster.getValues().indexOf(value - 20) >= 0 or cluster.getValues().indexOf(value + 1) >= 0 or cluster.getValues().indexOf(value + 20) >= 0
          return true
      return false

  getTiles: =>
    return @tiles

  setTiles: (tiles) =>
    @tiles = tiles

  getTileBounds: =>
    array = []
    for tile in @tiles
      array.push(tile.getBoundingPositions())
    Array.merge(array)








