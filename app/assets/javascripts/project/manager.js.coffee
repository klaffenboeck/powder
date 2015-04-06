#= require ../estimation_function
#= require ../legend
#= require ../line_chart
#= require ../navigation
#= require ../webgl

class @Manager
  constructor: (options = {}) ->
    {@parameter_space, @name, @description, @accuracy, @measured_points, @data_angles} = options
    @orig_estfunc_contents = options.estimation_function
    @setup()

  setup: ->
    @black = new Color("black")
    @red = new Color("red")
    @blue = new Color("blue")
    @green = new Color("green")
    @purple = new Color("purple")
    @orange = new Color("orange")

    @param_space = ParameterSpace.factory(@parameter_space)
    @linechart = new LineChart()
    @linelist = {}

    @setupLine("measured", @linechart.domainX, @linechart.domainY, @data_angles.angles, @measured_points.points, @purple)
    
    @setupLine("simulated", @linechart.domainX, @linechart.domainY, @data_angles.angles, @getNullArray(1041), @blue)
    @setupLine("previous", @linechart.domainX, @linechart.domainY, @data_angles.angles, @measured_points.points, @black)
    @setupLine("compared", @linechart.domainX, @linechart.domainY, @data_angles.angles, @getNullArray(1041), @green)
    @linelist.previous.hide()
    @linechart.display.drawLines()
    #@setupDiffLine("error", @linelist.measured, @linelist.simulated, @red)
    @setupDiffLine("difference", @linelist.simulated, @linelist.compared, @orange)

    @legend = new Legend
      select: "#detailview-1"
      entries: [@linelist.measured, @linelist.simulated, @linelist.compared, @linelist.difference]
    @legend.drawEntries()
    #console.log(@orig_estfunc_contents)
    @func = EstimationFunction.factory(@orig_estfunc_contents)

    @estfunc_list = new EstimationFunctionList()
    @estfunc_list.addFunction(@func)


    @navigation = new Navigation
      estimation_function: @func
      boundaries: @param_space.getOptimumBoundaries()
    @navigation.estimate_all_lines()
    @navigation.estimate_preview()
    @navigation.hide_preview_lines

    #@exclusions_list = new ExclusionsList()
    #@selection_holder = new SelectionHolder()

    @selection_manager = SelectionManager.factory(@func, @measured_points.points, @data_angles.angles)

    @errorchart = new ErrorChart()

    @gl_legend = new WebglLegend2({select: "#gl_legend"})

    # @gl_legend.addHandle({color: "#2166ac", position: 400})
    # @gl_legend.addHandle({color: "#d1e5f0", position: 100})
    # @gl_legend.addHandle({color: "#ef8a62", position: 20})
    # @gl_legend.addHandle({color: "#b2182b", position: -1})

    @gl_legend.addHandle({color: "#2166ac", value: 0})
    @gl_legend.addHandle({color: "#d1e5f0", value: 0.7})
    @gl_legend.addHandle({color: "#ef8a62", value: 0.95})
    @gl_legend.addHandle({color: "#b2182b", position: -1})
    
    @sampling = @generateSamples()
    @complex_view_holder = new ComplexViewHolder
      domains: @navigation.getAllDomains()
      slider: @gl_legend.slider
      sampling: @sampling
    @complex_view_holder.newProjectionView()
    #@selection_manager.setupProjectionSelect()

    @param_space.renderOptionsY()
    @param_space.renderOptionsX()
    @param_space.setupSelectListener()
    $("#projection-y-select").val(1)
    that = @
    $("#projection-style-select").change( (e) ->
      that.complex_view_holder.setDisplayStyle($(@).val())
    )
    $(".quality-changer").change( (e) =>
      min = $("#min-quality #min-value").val()
      max = $("#max-quality #max-value").val()
      window.m.navigation.changeDomain([min, max])
      window.m.gl_legend.slider.changeDomain([min, max])
      window.m.selection_manager.renderDisplayRunList()
    )


  setupLine: (name, domainX, domainY, valuesX, valuesY, color = @black) =>
    @linelist[name] = new Line
      name: name
      domainX: domainX
      domainY: domainY
      valuesX: valuesX
      valuesY: valuesY
      color: color
    @linechart.display.addLine(@linelist[name])

  setupDiffLine: (name, line1, line2, color = @black) =>
    # console.log(line1)
    @linelist[name] = new DiffLine
      name: name
      domainX: line1.domainX
      domainY: line1.domainY
      valuesX: line1.valuesX
      valuesY: @getNullArray(line1.valuesY.length)
      color: color
      line1: line1
      line2: line2
    @linechart.display.addLine(@linelist[name])

  updateLineChart: (run) =>
    #@linelist.previous.valuesY = @linelist.simulated.valuesY
    #console.log(run)
    @linelist.simulated.valuesY = run.getPoints() #run.emulated_points.points
    @linelist.compared.valuesY = @getBaseArray()
    @linelist.difference.valuesY = @getBaseArray()
    #@linelist.error.calcDifference()
    #@linelist.difference.calcDifference()
    @linechart.drawLines()

  compareLineChart: (run = null) =>
    if run
      @linelist.compared.valuesY = run.getPoints()
      @linelist.difference.calcDifference()
      @linechart.drawLines()
    else 
      @linelist.compared.valuesY = @getBaseArray()
      @linelist.difference.valuesY = @getBaseArray()
      @linechart.drawLines()

  getNullArray: (n) =>
    arr = []
    for zero in [1..n]
      arr.push(0)
    return arr

  getBaseArray: (n) =>
    arr = []
    for zero in [1..n]
      arr.push(1)
    return arr

  generateSamples: (options={}) =>
    start = Date.now()
    amount = options.amount ? 25000
    computeResults = options.results ? true
    dims = options.dims ? Object.keys(@parameter_space.content).length
    sample_type = options.sample_type ? Hybrid

    @samples = sample_type.sample(amount, dims, @parameter_space)
    if computeResults
      func = @navigation.estimation_function
      @samples.computeResults({estfunc: func})
    end = Date.now() - start
    #alert(end)
    @samples

  generateNewSamples: (options={}) =>
    amount = options.amoutn ? 25000
    
    dims = options.dims ? Object.keys(@parameter_space.content).length

    sampling = Hybrid.sample(amount, dims, @parameter_space)
    func = @navigation.estimation_function
    results = sampling.computeResults({estfunc: func})
    return sampling



