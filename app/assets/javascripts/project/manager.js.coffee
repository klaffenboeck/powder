#= require ../estimation_function
#= require ../legend
#= require ../line_chart
#= require ../navigation
#= require ../webgl

class @Manager
  constructor: (options = {}) ->
    {@parameter_space, @name, @description, @accuracy, @measured_points, @data_angles, @run_list, @runs, @estimation_function} = options
    @setup()

  setup: ->
    @black = new Color("black")
    @red = new Color("red")
    @blue = new Color("blue")
    @green = new Color("green")
    @purple = new Color("purple")

    @linechart = new LineChart()
    @linelist = {}

    @setupLine("measured", @linechart.domainX, @linechart.domainY, @data_angles.angles, @measured_points.points, @purple)
    
    @setupLine("emulated", @linechart.domainX, @linechart.domainY, @data_angles.angles, @getNullArray(1041), @blue)
    @setupLine("previous", @linechart.domainX, @linechart.domainY, @data_angles.angles, @measured_points.points, @black)
    @linelist.previous.hide()
    @linechart.display.drawLines()
    @setupDiffLine("error", @linelist.measured, @linelist.emulated, @red)
    @setupDiffLine("difference", @linelist.emulated, @linelist.previous, @green)

    @legend = new Legend
      select: "#detailview-1"
      entries: [@linelist.measured, @linelist.emulated, @linelist.error, @linelist.difference]
    @legend.drawEntries()
    @func = EstimationFunction.factory(@estimation_function)
    @navigation = new Navigation({estimation_function: @func})
    @navigation.estimate_all_lines()
    @navigation.estimate_preview()

    @gl_legend = new WebglLegend2({select: "#gl_legend"})
    @gl_legend.addHandle({color: "#0000ff", position: 100})
    @gl_legend.addHandle({color: "#ff0000", position: 350})
    @gl_legend.addHandle({color: "#00ff00", position: 200})
    @gl_legend.addHandle({color: "#ffff00", position: 450})
    @sampling = @generateSamples()
    @complex_view_holder = new ComplexViewHolder
      domains: @navigation.getAllDomains()
      slider: @gl_legend.slider
      sampling: @sampling
    @complex_view_holder.newProjectionView()


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
    @linelist.previous.valuesY = @linelist.emulated.valuesY
    @linelist.emulated.valuesY = run.emulated_points.points
    @linelist.error.calcDifference()
    @linelist.difference.calcDifference()
    @linechart.drawLines()

  getNullArray: (n) =>
    arr = []
    for zero in [1..n]
      arr.push(0)
    return arr

  generateSamples: (options={}) =>
    amount = options.amount ? 25000
    computeResults = options.results ? true
    dims = options.dims ? Object.keys(@parameter_space.content).length
    sample_type = options.sample_type ? Hybrid

    @samples = sample_type.sample(amount, dims, @parameter_space)
    if computeResults
      func = @navigation.estimation_function
      @samples.computeResults({estfunc: func})
    @samples


