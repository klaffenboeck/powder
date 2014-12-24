#= require line_chart

class @SmallMultiples
  constructor: (options={}) ->
    @select = options.select ? "#comparison"
    @measured_points = options.measured_measured_points ? window.m.measured_points
    @runs = []
    @temp_runs = options.runs ? []

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
    @setupRuns(@temp_runs)


  setup: =>
    @base = d3.select(@select)
    @table = @base.append("table")
    @header = @table.append("tr").attr("class", "header")
    @header.append("th").text("ID")
    @th_expected = @header.append("th")
    @th_expected.attr("class", "expected")
    @thumb_expected = @createThumbnail("expected_line", "th.expected")
    @thumbline = m.linelist.measured.copy
      domainX: @t.domainX
      domainY: @t.domainY
    # @thumbline.domainX = @t.domainX
    # @thumbline.domainY = @t.domainY

    @thumb_expected.addLine(@thumbline)
    @thumb_expected.drawLines()


  setupRuns: (runs = []) =>
    for run in runs
      _run = new Run(run)
      _run.chi2 = new Chi2({run: _run})
      @addRun(_run)

  addRun: (run) =>
    @runs.push(run)

  createThumbnail: (name, select) =>
    # console.log(@t.boundaries)
    thumb = new MiniChart
      name: name
      select: select
      boundaries: @t.boundaries
      domainX: @t.domainX
      domainY: @t.domainY
      axisX: @t.axisX
      axisY: @t.axisY

  minifyLine: (line) =>
    new_line = new Line()


  render: =>
    @row = @table.selectAll("tr.run").data(@runs)
    @enter = @row.enter()
    _tr_run = @enter.append("tr").attr("class", "run")
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
      _thumbline = @thumbline.copy
        name: "calculated"
        valuesY: d.emulated_points.points
        domainX: @t.domainX
        domainY: @t.domainY
        color: window.m.blue
      console.log(_thumbline)
      _thumb.addLine(_thumbline)
      _thumb.drawLines()
    )


class @History extends SmallMultiples
  constructor: (options={}) ->
    super(options)



class @Run
  constructor: (options={}) ->
    {@id, @input_params, @emulated_points} = options
    @lines = {}



