#= require line_chart

class @SMD
  constructor: (options = {}) ->
    @select = options.select ? "#smd"
    @min = 0.0
    @max = 1.0
    @domainY = new Domain
      name: "smd-quality"
      min: 0
      max: 1
      height: 40
      scaletype: "linear"
      @setup()


  setup: =>
    @base = d3.select(@select)
    @table = @base.append("table")
    @tbody = @table.append("tbody")

  changeDomain: (bounds) =>
    @min = bounds[0]
    @max = bounds[1]


  render: (runlist = null) =>
    $("#runlist .run .clickable").unbind("click")
    $("#smd .run .value").unbind("mouseenter")
    $("#runlist .run").unbind("mouseenter")
    $("#runlist").unbind("mouseleave")
    #$("#td.value").tooltip("destroy")
    runs = runlist.getRuns()
    _data = runlist.getNormalResults()
    if runlist.constructor == Run
      _data = [_data]

    # console.log(runs)

    @tbody.selectAll("tr.run").data([]).exit().remove()

    y = d3.scale.linear()
      .domain([@min,@max])
      .range([0,40])


    @rows = @tbody.selectAll("tr.run").data(_data)

    @rows.transition().duration(750)

    @enter = @rows.enter()
    _tr_run = @enter.append("tr").attr("class", (d, i) ->

      "run id" + runs[i].id
    ).attr("data-tr-index", (d, i) ->
      i
    ).attr("data-run-id", (d, i) ->
      runs[i].id
    )
    _tr_run.on("mouseenter", (d, i) ->
      window.m.outer = i
      window.m.selection_manager.setTempRun(i)
      window.m.selection_manager.showTempEstimation()
      # window.m.navigation.show_preview_lines()
      # window.m.navigation.estimate_preview(runs[i].input_params)
    ).on("mouseleave", (d, i) ->
      window.m.selection_manager.hideTempEstimation()
      #window.m.navigation.hide_preview_lines()
    )

    _tr_run.append("td").attr("class", "run-loaded")
    _tr_run.append("td").attr("class", "run-id clickable")  

    @text = d3.selectAll(@select + " .run-id").text( (d, i) ->
      "(" + runs[i].id + ")"
    )

    @input = d3.selectAll(@select + " .run-loaded").html( (d,i) ->
      "<input type='checkbox' value='" + i + "'>"
    )
    

    @values = @rows.selectAll("td.value").data( (d, i) ->
      d
    )

    @td_enter = @values.enter()
    @tds = @td_enter.append("td").attr("class","value clickable highlightable")
      .attr("data-td-index", (d, i) ->
        i
      )
      .attr("data-result", (d, i) ->
        d
      ).attr("data-toggle", "tooltip")
      .attr("data-placement", "top")
      .attr("title", (d, i) ->
        "fit: " + Math.roundFloat(d, 4)
      )

    @bars = @tds.append("div").attr("class", "bar")
    @compared = @tds.append("div").attr("class", "compared")

    # @bars.style("height", (d, i) ->
    #     return y(d) + "px"
    #   )

    #NOTE: working code, in case I need it!!

    # @tds.on("mouseenter", (d, i) ->
    #   console.log("outer: " + window.m.outer + ", inner: " + i)
    # )
      
    # @tds

    #@bars = @values.selectAll("div.bar")


    @values.selectAll("div.bar").style("height", (d, i) ->
      return y(d) + "px"
    )


    @rows.exit().transition().duration(750).remove()



    that = @
    that._temp_id = undefined
    that._current_slide = 

    $("#runlist .run").mouseenter( (e) ->
      that._temp_id = $(@).data("run-id")
      window.m.selection_manager.compareRun(that._temp_id)
      #window.m.selection_manager.compareRun($(@).
    )

    #$("td.value").tooltip()

    $("#runlist").mouseleave( (e) ->
      window.m.selection_manager.resetComparedRun()
      slide_id = window.m.selection_manager.restoreProjectionSlide()
    )

    $("#runlist .run .clickable").click( (e) ->
      window.m.selection_manager.loadRun($(@).parent().data("run-id"))

      # $("#runlist .run.id" + that._temp_id).unbind("mouseenter")
    ) 

    $("#smd .run .value").each( (e) ->
      res = $(@).data("result")
      color = window.m.gl_legend.slider.getColorAt(res).toString()
      $(".bar", @).css("background-color", color)
    )

    $("#smd .run .value").mouseenter( (e) ->
      _index_id = $(@).data("td-index")
      window.m.selection_manager.setTempEstimationFunction(_index_id)
      window.m.selection_manager.showTempEstimation()
      window.m.complex_view_holder.getSlide(_index_id)
    )

    $("#runlist .run .clickable").click( (e) ->
      window.m.selection_manager.loadRun($(@).parent().data("run-id"))
      _index = $(@).data("td-index")
      console.log("_index")
      console.log(_index)
      if _.isNumber(_index)
        console.log("_index inside")
        console.log(_index)
        window.m.selection_manager.updateProjectionSlide(_index)
      # $("#runlist .run.id" + that._temp_id).unbind("mouseenter")
    ) 


    $(".run-loaded input:checkbox").change( (e) ->
      window.m.selection_manager.updateLoaded(0)
    )



class @Bar 
  constructor: (options = {}) ->
    {domain} = options



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



  #   @simluated_points = options.simulated_points ? options_emulated_points
  #   @emulated_points = @simulated_points
  #   # the previous construct should be resolved, no emulated point anymore
  #   @lines = {}
  #   @lines.emulated = new Line
  #     name: "thumbnail"
  #     valuesY: @emulated_points.points
  #     valuesX: window.m.data_angles.angles
  #     domainX: @domainX
  #     domainY: @domainY
  #     color: window.m.blue

  # getSimulation: (points = true) =>
  #   return @emulated_points.points if points == true
  #   return @emulated_points






