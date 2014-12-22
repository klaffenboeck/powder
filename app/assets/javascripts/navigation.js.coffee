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
    @preview_color = new Color("red")
    for key, range of @parameter_space
      _domain = new Domain({name: key, range: range, width: @boundaries.width })
      _chart = new NavChart({boundaries: @boundaries, quality: @quality, domain: _domain, name: key })
      @value_arrays[key] = _domain.width_to_values(10)
      @setup_mousedown(_chart)
      _line = new EstLine({name: key, key: key, domainY: @quality, domainX: _domain, valuesX: @value_arrays[key]})
      _preview_line = new EstLine({name: key + "-preview", key: key, domainY: @quality, domainX: _domain, valuesX: @value_arrays[key], color: @preview_color})
      _preview_line.hide()
      _chart.addLine(_line)
      _chart.addLine(_preview_line)
      _curr = @current_position
      @charts[key] = _chart

  mousedown: (options) ->
    console.log(this)

  setup_mousedown: (chart) =>
    _chart = chart
    _overlay = chart.display.overlay
    chart.display.overlay.on("mousedown", =>
      _chart.mousedown()
      @estimate_all_lines()
      $.ajax(
        url: document.URL + "/remotepost"
        cache: false
        type: "POST"
        data:
          parameters: @current_x_values()
      ).done (json) ->
        window.manager.updateLineChart(json)
      )
    _overlay.on("mouseover", =>
      @show_preview_lines()
      @fixed_hover = @current_x_values()
    )
    _overlay.on("mousemove", =>
      _value = _chart.mouseover()
      # console.log(_chart.currX(_value))
      @estimate_preview(_chart.name, _chart.currX(_value))
    )
    _overlay.on("mouseout", =>
      @hide_preview_lines()
      @fixed_hover = null
    )

  set_default_boundaries: =>
    @boundaries = new Boundaries
      width: 100
      height: 100
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
    _samplekey = line.key
    for key in _keys
      _params[key] = fixed[key]
    _values = []
    for val, i in line.valuesX
      _values.push(val)
    _retval = []
    for value in _values
      _params[_samplekey] = value
      _retval.push(@estimation_function.est(_params))
    _retval

  estimate_all_lines: =>
    _start = Date.now()
    _fixed = @current_x_values()
    console.log("FIXED")
    console.log(_fixed)
    for key, chart of @charts
      _line = chart.getLines()[key]
      _line.valuesY = @estimate_line(_line, _fixed)
      chart.drawLine(_line)
    _end = Date.now()
    console.log("TIME: " + (_end - _start))

  estimate_preview: (key = null, value = null)=>
    _fixed = @current_x_values()
    _fixed[key] = value if key and value
    for key, chart of @charts
      _line = chart.getLines()[key + "-preview"]
      _line.valuesY = @estimate_line(_line, _fixed)
      chart.drawLine(_line, 5)

  show_preview_lines: =>
    _start = Date.now()
    for key, chart of @charts
      _line = chart.getLines()[key + "-preview"]
      _line.show()
      chart.drawLine(_line, 0)
    _end = Date.now()
    console.log("TIME: " + (_end - _start))

  hide_preview_lines: =>
    for key, chart of @charts
      _line = chart.getLines()[key + "-preview"]
      _line.hide()
      chart.drawLine(_line, 0)







