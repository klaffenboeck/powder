class @LineChart
  constructor: (options={}) ->
    boundaries = new Boundaries
      margin:
        top: 10
        right: 10
        bottom: 30
        left: 50
      total_width: 540
      total_height: 340
    @stepsX = options.stepsX ? data_angles
    @domainX = new Domain
      range: data_angles
      width: boundaries.width
    @domainY = new Domain
      range: measured_points
      height: boundaries.height
    axisX = new Axis(
      domain: @domainX)
    axisY = new Axis({domain: @domainY})
    @display = new Display(
      select: "#detailview-1 .main"
      boundaries: boundaries
      xAxis: axisX
      yAxis: axisY)
    @lines = []



class @Domain
  constructor: (options={}) ->
    {@min, @max} = options
    @range = options.range ? [@min, @max]
    @width = options.width ? 0
    @height = options.height ? 0
    @setup()

  setup: =>
    scale = if @width then d3.scale.linear() else d3.scale.log().base(10)
    @rangeband = scale.range([@height, @width])
    @domain = @rangeband.domain(d3.extent(@range))
        

  orientation: =>
    if @height then "left" else "bottom"



class @Boundaries
  constructor: (options={}) ->
    {@total_width, @total_height, @width, @height} = options
    @margin = options.margin ? {}
    @margin.top ?= 0
    @margin.bottom ?= 0
    @margin.left ?= 0
    @margin.right ?= 0
    @width ?= @total_width - @margin.left - @margin.right
    @height ?= @total_height - @margin.bottom - @margin.top
    @total_width ?= @width + @margin.left + @margin.right
    @total_height ?= @height + @margin.bottom + @margin.top



class @Axis
  constructor: (options={}) ->
    {@domain} = options
    @orientation = options.orientation ? @domain.orientation()
    @setup()

  setup: =>
    @axis =
      d3.svg.axis()
        .scale(@domain.domain)
        .orient(@orientation);



class @Display
  constructor: (options={}) ->
    {@select, @boundaries, @xAxis, @yAxis} = options
    
    @lines = {}
    @setup()
    @create()

  setup: =>
    b = @boundaries
    @view =
      d3.select(@select).append("svg")
        .attr("width", b.total_width)
        .attr("height", b.total_height)
        .append("g")
        .attr(
          "transform",
          "translate(" +
          b.margin.left + "," +
          b.margin.top + ")");

  create: =>
    @view.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + @boundaries.height + ")")
      .call(@xAxis.axis);

    @view.append("g")
      .attr("class", "y axis")
      .call(@yAxis.axis);

  addLine: (line) =>
    @lines[line.name] = line

  drawLines: =>
    keys = Object.keys(@lines)
    for key, index in keys
      line = @lines[key]
      @drawLine(line)

  drawLine: (line) =>
    return_function = (d) ->
      line.line(d)
    base =
      @view.selectAll("." + line.name)
      .data(new Array(line.valuesY) )

    base.enter()
      .append("g")
      .attr("class", line.name)
      .append("path")

      .attr("class", line.name + "-line line")
      .attr("stroke", line.color)
      .attr("d", return_function)
      .attr("stroke", line.color.color)

    @view.selectAll(line.fullClassSpecifier())
      .data(new Array(line.valuesY))
      .transition().delay(10).duration(1000)
      .attr("d", return_function)



class @Line
  constructor: (options={}) ->
    {@name, @valuesX, @valuesY, @domainX, @domainY} = options
    @interpolation = options.interpolation ? "basis"
    @color = options.color ? new Color("black")
    @setup()

  setup: =>
    funcX = (d,i) ->
      @domainX.domain(@valuesX[i])
    funcY = (d,i) ->
      @domainY.domain(@valuesY[i])
    @line =
      d3.svg.line()
        .interpolate("basis")
        .x(funcX)
        .y(funcY)

  className: =>
    "." + @name

  classNameLine: =>
    @className() + "-line"

  fullClassSpecifier: =>
    @className() + " " + @classNameLine()

  @difference: (line1, line2, with_offset = true) ->
    return "doesn't match" if line1.length != line2.length
    values1 = line1.valuesY
    values2 = line2.valuesY
   
    newValues = []
    for value, index in line1.valuesY
      newValues.push(Math.abs(value - values2[index]))
    newValues

  setDifference: (line1, line2, with_offset = true) =>
    diff = Line.difference(line1, line2, with_offset)
    @valuesY = diff

class @Color
  constructor: (options={}) ->
    @color = @getColor(options) if typeof options == "string"
    @color = @getColor(options.color) if typeof options == "object"

  getColor: (string) ->
    d3.rgb(string)



