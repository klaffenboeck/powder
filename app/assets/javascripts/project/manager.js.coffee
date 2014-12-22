#= require ../estimation_function
#= require ../legend
#= require ../line_chart
#= require ../navigation

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
    console.log(line1)
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

  updateLineChart: (json) =>
    @linelist.previous.valuesY = @linelist.emulated.valuesY
    @linelist.emulated.valuesY = json.run.emulated_points.points
    @linelist.error.calcDifference()
    @linelist.difference.calcDifference()
    @linechart.drawLines()

  getNullArray: (n) =>
    arr = []
    for zero in [1..n]
      arr.push(0)
    return arr


