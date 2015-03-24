#= require line_chart
#= require estimation_function

class @Navigation
  constructor: (options={}) ->
    {@estimation_function, @boundaries} = options
    @set_default_boundaries() if not @boundaries
    @parameter_space = @estimation_function.parameter_space
    @busy = true    
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
      @value_arrays[key] = _domain.width_to_values(2)
      @setup_mousedown(_chart)
      _line = new EstLine({name: key, key: key, domainY: @quality, domainX: _domain, valuesX: @value_arrays[key]})
      _preview_line = new EstLine({name: key + "-preview", key: key, domainY: @quality, domainX: _domain, valuesX: @value_arrays[key], color: @preview_color})
      _navbar = new NavBar({name: key + "-navbar", key: key, domainY: @quality, domainX: _domain, position: _chart.currX()})
      _estnavbar = new EstNavBar({name: key + "-navbar-preview", key: key, domainY: @quality, domainX: _domain, position: _chart.currX()})
      _preview_line.hide()
      _chart.addLine(_line)
      _chart.addLine(_preview_line)
      _chart.addLine(_navbar)
      _chart.addLine(_estnavbar)
      _chart.drawNavBar()
      _curr = @current_position
      @charts[key] = _chart
    # cvh = new ComplexViewHolder({domains: @getAllDomains(), slider: @slider})

  mousedown: (options) ->
    console.log(this)

  setup_mousedown: (chart) =>
    _chart = chart
    _overlay = chart.display.overlay
    chart.display.overlay.on("mousedown", =>
      _chart.mousedown()
      @estimate_all_lines()
      chart.drawNavBar()
      $.ajax(
        url: document.URL + "/remotepost"
        cache: false
        type: "POST"
        data:
          parameters: @current_x_values()
      ).done (json) ->
        window.m.hist.createRun(json.run)
        window.m.hist.render()
        window.manager.updateLineChart(json.run)
      )
    _overlay.on("mouseover", =>
      @show_preview_lines()
      @fixed_hover = @current_x_values()
    )
    _overlay.on("mousemove", =>
      _value = _chart.mouseover()
      # console.log(_chart.currX(_value))
      if !@busy
        @busy = true
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
        bottom: 35
        left: 20
        top: 30
        right: 10

  current_positions: =>
    _positions = []
    for key, chart of @charts 
      _positions.push(chart.current_position())
    return 

  getAllDomains: =>
    domains = []
    for name, chart of @charts
      domains.push(chart.domain)
    return domains

  getDomain: (index) =>
    @getAllDomains()[index]


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

  set_current_x_values: (values) =>
    _count = 0
    for key, chart of @charts
      chart.set_position_from_value(values[_count])
      _count += 1

  current_hover_positions: =>
    return @_current_hover_positions

  set_current_hover_positions: (array) =>
    @_current_hover_positions = array

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
    _fixed = @current_x_values()
    for key, chart of @charts
      _line = chart.getLines()[key]
      _line.valuesY = @estimate_line(_line, _fixed)
      chart.drawLine(_line)
      chart.drawNavBar()


  estimate_preview: (key = null, value = null) =>
    _fixed = @current_x_values()
    _fixed[key] = value if key and value
    if key instanceof Array
      keys = Object.keys(_fixed)
      for k, i in keys
        _fixed[k] = key[i]
    for key, chart of @charts
      _line = chart.getLines()[key + "-preview"]
      _line.valuesY = @estimate_line(_line, _fixed)
      chart.drawLine(_line, 5)
      chart.drawEstNavBar(_fixed[key])
    @busy = false


  show_preview_lines: =>
    for key, chart of @charts
      _line = chart.getLines()[key + "-preview"]
      _line.show()
      _bar = chart.getLines()[key + "-navbar-preview"]
      _bar.show()
      chart.drawLine(_line, 0)
      chart.drawLine(_bar, 0)


  hide_preview_lines: =>
    for key, chart of @charts
      _line = chart.getLines()[key + "-preview"]
      _line.hide()
      _bar = chart.getLines()[key + "-navbar-preview"]
      _bar.hide()
      chart.drawLine(_line, 0)
      chart.drawLine(_bar, 0)


class @ComplexViewHolder
  _slide_counter = 0
  _nav_domains = undefined
  slides = []
  _current_slide = undefined
  _discrete = 0
  constructor: (options = {}) ->
    {@slider, @sampling} = options
    _nav_domains = options.domains
    slides = []
    @width = options.width ? 200

  newProjectionView: (x = 0, y = 3) =>
    # $("#webgl-area").prepend(@getTemplate())
    view = d3.select("#webgl-area")
    id = "complex-view-" + @getSlideCount()
    id2 = "complex-side-" + @getSlideCount()
    wplus = @width + 50
    div = view.insert("div",":first-child")
      .attr("class", "complex-view")
      .attr("id", id)
      .attr("style", "width:" + wplus + "px; height: " + wplus + "px;")
    axisY = div.append("svg").attr("class", "axis y")
      .attr("width", 30)
      .attr("height", @width)
      .attr("transform", "translate(30,0)")
    slide = div.append("canvas").attr("class", "complex-slide")
      .attr("id", id2)
      .attr("width", @width)
      .attr("height", @width)
      .attr("transform", "translate(30, 0)")
    axisX = div.append("svg").attr("class", "axis x")
      .attr("width", @width + 50)
      .attr("height", 30)
      .attr("transform", "translate(32,0)")
    @increaseSlideCounter()
    slide = new ProjectionView({slider: @slider, sampling: @sampling, select: "#" + id, holder: @, width: @width })
    @addSlide(slide)
    slide.getMaxima(x, y)
    return slide

  setCurrentSlide: (slide) =>
    _current_slide = slide
    @displayCurrentSlide()

  getCurrentSlide: =>
    return _current_slide


  getDomain: (number) =>
    return _nav_domains[number]

  increaseSlideCounter: =>
    _slide_counter += 1

  getSlideCount: =>
    return _slide_counter

  addSlide: (slide) =>
    slides.push(slide)
    @setCurrentSlide(slide)

  getSlides: (num = null) =>
    return slides if num == null
    @getSlide(num)

  getSlide: (num) =>
    slide = slides[num]
    @setCurrentSlide(slide)
    return slide

  getAxis: (num, orient) =>
    _domain = @getDomain(num)
    type = _domain.getScaleType()
    domain = _domain.domain.domain()
    range = if orient == "bottom" then [0,200] else [200,0]
    scale = d3.scale.linear()
      .domain(domain)
      .range(range)
    axis = d3.svg.axis()
      .scale(scale)
      .orient(orient)
    return axis

  displayCurrentSlide: =>
    select = @getCurrentSlide().select
    $('.complex-view').hide()
    $(select).show()

  prepareQOIs: =>
    slide = @getCurrentSlide()
    qoilist = slide.getQOIs()
    for qoi, i in qoilist.qois
      slide.slider.handles[i].setQOI(qoi)
    return true

  getTiles: (indices) =>
    tiles = @getCurrentSlide().getTiles(indices)

  setTilesForCluster: (cluster) =>
    indices = cluster.getIndices()
    cluster.setTiles(@getTiles(indices))

  drawClusterBounds: (cluster) =>
    bounds = cluster.getTileBounds()
    slide = @getCurrentSlide()
    slide.setBoxHighlighting(bounds)
    slide.redraw()

  resetClusterBounds: =>
    slide = @getCurrentSlide()
    slide.resetBoxHighlighting()
    slide.redraw()

  setHoverForCluster: (cluster) =>
    id = "#" + cluster.getHoverId()
    that = @
    $(id).mouseenter( (e) =>
      that.drawClusterBounds(cluster)
    ).mouseleave( (e) =>
      that.resetClusterBounds()
    )









