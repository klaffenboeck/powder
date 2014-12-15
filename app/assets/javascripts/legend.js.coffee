#= require line_chart

class @Legend
  constructor: (options={}) ->
    {@select, @boundaries} = options
    @lineHeight = options.lineHeight ? 20
    @entries = options.entries ? []
    @setup()

  setup: =>
    @container = d3.select(@select)
    @legend =
      @container
        .append("svg")
        .datum("legend")
        .attr("class", "legend")
        .attr("style", "width: 100px; height: 100px")

  add: (entry) =>
    @entries.push(entry)
  
  drawEntries: (new_entries = []) =>
    if new_entries.length > 0
      @entries = new_entries
      @legend.selectAll(".legend-entry").data([]).exit().remove()
    _entries =
      @legend.selectAll(".legend-entry")
        .data(@entries)
    _entries
      .enter()
      .append("g")
      .attr("class","legend-entry")
      .attr("transform", @getTranslate)
      .append("rect")
      .attr("width", 10)
      .attr("height", 10)
      .style("fill", @getColor)
      .style("stroke", @getColor)
    _entries
      .append("text")
      .attr('x', @lineHeight)
      .attr('y', @lineHeight/2)
      .text( (d) ->
        d.name
      )


  getTranslate: (data, index) =>
    top = @lineHeight * index
    return "translate(" + @lineHeight/2 + ", " + top + " )"

  getColor: (data, index) ->
    data.color.color



class @LegendEntry
