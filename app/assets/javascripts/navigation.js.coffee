#= require line_chart
#= require estimation_function

class @Navigation
  constructor: (options={}) ->
    {@estimation_function, @boundaries} = options
    @set_default_boundaries() if not @boundaries
    @parameter_space = @estimation_function.parameter_space
    @quality = new Domain
      name: "quality"
      range: [1,10000]
      height: @boundaries.height
      scaletype: "linear"
      order: "desc"
    @charts = {}
    @value_arrays = {}
    @current_values = {}
    for key, range of @parameter_space
      _domain = new Domain({name: key, range: range, width: @boundaries.width })
      _chart = new NavChart({boundaries: @boundaries, quality: @quality, domain: _domain, name: key })
      @value_arrays[key] = _domain.width_to_values()
      @setup_mousedown(_chart)
      #_chart.display.overlay.on("mousedown", _chart.mousedown)
      #_chart.display.overlay.on("mousedown", @mousedown)
      _line = new Line({name: key, domainY: @quality, domainX: _domain, valuesX: @value_arrays[key]})
      _chart.addLine(_line)
      _curr = @current_position

      @charts[key] = _chart

  mousedown: (options) ->
    console.log(this)

  setup_mousedown: (chart) =>

    _chart = chart
    chart.display.overlay.on("mousedown", =>
      _chart.mousedown()
      @estimate_all_lines()
      console.log(@current_positions())
      console.log(@current_x_values("array"))
      $.ajax(
        url: document.URL + "/remotepost"
        cache: false
        type: "POST"
        data:
          parameters: @current_x_values()
      ).done (json) ->
        window.previous_line.valuesY = window.emulated_points.valuesY
        window.emulated_points.valuesY = json
        window.error_line.setDifference(window.measured_points, window.emulated_points)
        window.change_line.setDifference(window.emulated_points, window.previous_line)
        window.linechart.drawLines()
        return
    )

  set_default_boundaries: =>
    @boundaries = new Boundaries
      width: 200
      height: 200
      margin:
        bottom: 60
        left: 60
        top: 10
        right: 20

  current_positions: =>
    _positions = []
    for key, chart of @charts 
      _positions.push(chart.current_position())
    return _positions

  current_x_values: (returntype = "hash")=>
    if returntype == "array"
      _values = []
      for key, chart of @charts 
        _values.push(chart.currX())
      return _values
    else
      _hash = {}
      for key, chart of @charts 
        _hash[key] = chart.currX()
      return _hash

  estimate_line: (line, fixed) =>
    _params = {}
    _keys = Object.keys(fixed)
    _samplekey = line.name
    for key in _keys
      _params[key] = fixed[key]
    _values = line.valuesX
    _retval = []
    for value in _values
      _params[_samplekey] = value
      _retval.push(@estimation_function.est(_params))
    _retval

  estimate_all_lines: =>
    _start = Date.now()
    _fixed = @current_x_values()
    for key, chart of @charts
      _line = chart.getLines()[key]
      _line.valuesY = @estimate_line(_line, _fixed)
      chart.drawLines()
    _end = Date.now()
    console.log(_end - _start)








