#= require brush

class @Webgl
  constructor: (options={}) ->
    {@select} = options
    @canvas = document.querySelector(@select)
    @gl = @canvas.getContext("webgl") or @canvas.getContext("experimental-webgl")
    @setupGL(@gl)

  program = undefined
  size = undefined

  setupGL: (gl) ->
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
    @sizeUniform = gl.getUniformLocation(program, "u_size")
    @u_step = gl.getUniformLocation(program, "u_step")
    @u_colorValues = gl.getUniformLocation(program, "u_colorValues")
    @u_length = gl.getUniformLocation(program, "u_length")
    gl.uniform1f(@sizeUniform, 1.0)
    return

  redraw: =>
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    @gl.uniform1f(@sizeUniform, 3.0)

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

    @gl.uniform1fv(@u_step, new Float32Array([0.25, 0.50, 0.75, 1.0]))
    @gl.uniform4fv(@u_colorValues, new Float32Array([
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


  # redraw2: =>
  #   @gl.clear(@gl.COLOR_BUFFER_BIT)
  #   @gl.uniform1f(@sizeUniform, 3.0)
  #   @gl.uniform1fv(@u_size, new Float32Array([0.25, 0.5, 0.75, 1.0]))
  #   @gl.uniform4fv(@u_colorValues, new Float32Array([
  #     1.0, 0.0, 0.0, 1.0,
  #     0.0, 1.0, 0.0, 1.0,
  #     0.0, 0.0, 1.0, 1.0,
  #     1.0, 1.0, 1.0, 1.0
  #   ]))

  #   # Define the colors (as RGBA vec4) for each vertex in the square.
  #   @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
  #   @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
  #     0.0
  #     1.0
  #     0.0
  #     1.0

  #   ]), @gl.STATIC_DRAW

  #   # Bind the color buffer to the color attribute.
  #   @gl.colorAttribute = @gl.getAttribLocation(program, "a_color")
  #   @gl.enableVertexAttribArray @gl.colorAttribute
  #   @gl.vertexAttribPointer @gl.colorAttribute, 1, @gl.FLOAT, false, 0, 0

  #   # Draw the square!
  #   @gl.drawArrays @gl.TRIANGLE_FAN, 0, 4


class @WebglLegend extends Webgl
  program = undefined
  size = undefined

  constructor: (options = {}) ->
    super(options)
    @orientation = options.orientation ? "horizontal"
    @slider = options.slider
    # @setPoints()

  setPoints: =>
    @gl.clear(@gl.COLOR_BUFFER_BIT)

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.positionBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      -1.0, -1.0,
      +1.0, -1.0,
      +1.0, +1.0,
      -1.0, +1.0
    ]), @gl.STATIC_DRAW

  redraw: =>
    @gl.clear(@gl.COLOR_BUFFER_BIT)

    @gl.uniform1f(@sizeUniform, 3.0)

    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.positionBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      -1.0, -1.0,
      +1.0, -1.0,
      +1.0, +1.0,
      -1.0, +1.0
    ]), @gl.STATIC_DRAW

    # Bind the position buffer to the position attribute.
    @gl.getAttribLocation(program, "a_position")
    @gl.enableVertexAttribArray @gl.positionAttribute
    @gl.vertexAttribPointer @gl.positionAttribute, 2, @gl.FLOAT, false, 0, 0

    # @gl.uniform1fv(@u_step, @slider.getCompleteValueArray())
    # @gl.uniform4fv(@u_colorValues, @slider.getCompleteColorArray())
    # console.log(@slider.getCompleteValueArray())
    # console.log(@slider.getCompleteColorArray())

    @gl.uniform1fv(@u_step, new Float32Array([0.25, 0.50, 0.75, 1.0]))
    @gl.uniform4fv(@u_colorValues, new Float32Array([
      1.0, 0.0, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,
      0.0, 0.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    ]))


    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      0.0
      1.0
      1.0
      0.0
    ]), @gl.STATIC_DRAW

    # Bind the color buffer to the color attribute.
    @gl.colorAttribute = @gl.getAttribLocation(program, "a_color")
    @gl.enableVertexAttribArray @gl.colorAttribute
    @gl.vertexAttribPointer @gl.colorAttribute, 1, @gl.FLOAT, false, 0, 0

    # Draw the square!
    @gl.drawArrays @gl.TRIANGLE_FAN, 0, 4

  redraw2: =>
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    @gl.uniform1f(@sizeUniform, 3.0)

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

    @gl.uniform1fv(@u_step, new Float32Array([0.25, 0.50, 0.75, 1.0]))
    @gl.uniform4fv(@u_colorValues, new Float32Array([
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

class @WebglLegend2
  constructor: (options={}) ->
    {@select} = options
    @slider = new Slider({select: "#brush", legend: @})
    @canvas = document.querySelector(@select)
    @gl = @canvas.getContext("webgl") or @canvas.getContext("experimental-webgl")
    @setupGL(@gl)
    @redraw()
    @clickPosition()

  program = undefined
  size = undefined

  setupGL: (gl) ->
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
    @sizeUniform = gl.getUniformLocation(program, "u_size")
    @u_step = gl.getUniformLocation(program, "u_step")
    @u_colorValues = gl.getUniformLocation(program, "u_colorValues")
    @u_length = gl.getUniformLocation(program, "u_length")
    gl.uniform1f(@sizeUniform, 1.0)
    return

  redraw: =>
    @gl.clear(@gl.COLOR_BUFFER_BIT)
    @gl.uniform1f(@sizeUniform, 3.0)

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

    # @gl.uniform1fv(@u_step, new Float32Array([0.25, 0.50, 0.75, 1.0]))
    # @gl.uniform4fv(@u_colorValues, new Float32Array([
    #   1.0, 0.0, 0.0, 1.0,
    #   0.0, 1.0, 0.0, 1.0,
    #   0.0, 0.0, 1.0, 1.0,
    #   1.0, 1.0, 1.0, 1.0
    # ]))

    @gl.uniform1fv(@u_step, @slider.getCompleteValueArray())
    @gl.uniform4fv(@u_colorValues, @slider.getCompleteColorArray())


    # Define the colors (as RGBA vec4) for each vertex in the square.
    @gl.bindBuffer @gl.ARRAY_BUFFER, @gl.colorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([
      0.0
      1.0
      1.0
      0.0

    ]), @gl.STATIC_DRAW

    # Bind the color buffer to the color attribute.
    @gl.cattribute = @gl.getAttribLocation(program, "a_color")
    @gl.enableVertexAttribArray @gl.cattribute
    @gl.vertexAttribPointer @gl.colorAttribute, 1, @gl.FLOAT, false, 0, 0

    # Draw the square!
    @gl.drawArrays @gl.TRIANGLE_FAN, 0, 4

  addHandle: (options={}) =>
    @slider.addHandle(options)


  # Only for presentation, has to be rewritten
  clickPosition: =>
    _slider = @slider
    $("#webgl").click( (e) ->
      posX = $(@).offset().left
      # alert(e.pageX - posX)
      pos = (e.pageX - posX)
      _slider.addHandle({position: pos, autocolor: true})
    )






