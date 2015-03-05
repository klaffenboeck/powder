#= require line_chart

class @SmallMultiples
  constructor: (options={}) ->
    @select = options.select ? "#comparison"
    @measured_points = options.measured_points ? window.m.measured_points
    @runs = []
    _temp_runs = options.runs ? []
    @temp_runs = _temp_runs

    @thumbnail_data =  {}
    @t = @thumbnail_data
    @t.boundaries = new Boundaries 
      width: 87
      height: 51
    @t.domainX = new Domain
      range: data_angles
      width: @t.boundaries.width
    @t.domainY = new Domain
      range: measured_points
      height: @t.boundaries.height
    @t.axisX = new Axis
      domain: @t.domainX
    @t.axisY = new Axis
      domain: @t.domainY 

    @setup()
    @setupRuns(_temp_runs.reverse())


  setup: =>
    @base = d3.select(@select)
    @tabletop = @base.append("table")
    @table = @base.append("table")
    @tabletop.attr("class","fixedheader")
    @table.attr("class","rundisplay")
    @header = @tabletop.append("thead").append("tr").attr("class", "header")
    @header.append("th").attr("class","id").text("ID")
    @th_expected = @header.append("th")
    @th_expected.attr("class", "expected")
    @thumb_expected = @createThumbnail("expected_line", "th.expected", false)
    @thumbline = m.linelist.measured.copy
      domainX: @t.domainX
      domainY: @t.domainY

    @thumb_expected.addLine(@thumbline)
    @thumb_expected.drawLines()
    @tbody = @table.append("tbody")


  setupRuns: (runs = []) =>
    for run in runs
      run.domainX = @t.domainX
      run.domainY = @t.domainY
      _run = new Run(run)
      _run.chi2 = new Chi2({run: _run})
      @addRun(_run)

  createRun: (options = {}) =>
    @setupRuns([options])

  addRun: (run) =>
    @runs.push(run)

  reverseRuns: =>
    @runs = @runs.reverse()

  createThumbnail: (name, select, interactive = true) =>
    # console.log(@t.boundaries)
    obj =
      name: name
      select: select
      boundaries: @t.boundaries
      domainX: @t.domainX
      domainY: @t.domainY
      axisX: @t.axisX
      axisY: @t.axisY
    thumb = new MiniChart(obj) if interactive == false
    thumb = new InteractiveMiniChart(obj) if interactive == true
    return thumb


  minifyLine: (line) =>
    new_line = new Line()


  render: =>
    @row = @tbody.selectAll("tr.run").data(@runs)
    @enter = @row.enter()
    _tr_run = @enter.insert("tr",".run").attr("class", (d) ->
      "run id" + d.id
    )
    _tr_run.append("td").attr("class", "run-id").text( (d) ->
      "(" + d.id + ")"
    )
    _tr_run.append("td").attr("class", (d)-> 
      "thumbnail id" + d.id
    )
    # ).text( (d) ->
    #   # @createThumbnail("observed",)
    #   d.id
    # )

    _td_chi2_val = _tr_run.append("td")
      .attr("class", "chi2-val")
      .text( (d) ->
        d.chi2.normal()
      )
    _td_chi2_bar = _tr_run.append("td")
      .attr("class", "chi2-bar")


    _td_chi2_bar.append("div").attr("class","bar")

    _tr_run.each( (d) =>
      classId = ".thumbnail.id" + d.id
      _thumb = @createThumbnail("thumbnail", classId)
      _thumb.addLine(d.lines.emulated)
      _thumb.drawLines()
    )

    @update = d3.selectAll(".chi2-bar div.bar").data(@runs)
    y = d3.scale.linear()
      .domain([0,1])
      .range([0,45])
    @update.style("height", (d) =>
      return y(d.chi2.normal()) + "px"
    )
    @update.style("background-color", (d) =>
      return window.m.gl_legend.slider.getColorAt(d.chi2.normal()).toString()
    )
    # @update.style("height", "20px")

class @History extends SmallMultiples
  constructor: (options={}) ->
    super(options)


class @Run
  constructor: (options={}) ->
    {@id, @input_params, @emulated_points, @domainX, @domainY} = options
    @lines = {}
    @lines.emulated = new Line
      name: "thumbnail"
      valuesY: @emulated_points.points
      valuesX: window.m.data_angles.angles
      domainX: @domainX
      domainY: @domainY
      color: window.m.blue




