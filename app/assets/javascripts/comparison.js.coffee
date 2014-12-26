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
    @table = @base.append("table")
    @header = @table.append("thead").append("tr").attr("class", "header")
    @header.append("th").text("ID")
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
    _tr_run.append("td").attr("class", (d)-> 
      "thumbnail id" + d.id
    ).text( (d) ->
      # @createThumbnail("observed",)
      d.id
    )
    _tr_run.append("td").attr("class", "chi2").text( (d) ->
      d.chi2.value 
    )

    _tr_run.each( (d) =>
      classId = ".thumbnail.id" + d.id
      _thumb = @createThumbnail("thumbnail", classId)
      _thumb.addLine(d.lines.emulated)
      _thumb.drawLines()
    )


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




