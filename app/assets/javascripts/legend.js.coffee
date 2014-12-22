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
    _enteries = _entries.enter()
      .append("g")
      .attr("class", (d) ->
        "legend-entry " + d.name )
      .on("click", (d, i) =>
        d.toggle()
        @drawEntries()
        window.m.linechart.drawLines() # this has to be exchanged
      )
      .attr("transform", @getTranslate)
    _enteries
      .append("rect")
      .attr("class", "legend-color")
      .attr("width", 10)
      .attr("height", 10)
      .style("fill", @getColor)
      .style("stroke", @getColor)
    _enteries
      .insert("text")
      .attr('x', @lineHeight)
      .attr('y', @lineHeight / 2)
      .text( (d) ->
        d.name
      )

    _entries
      .classed("muted", (d) ->
        d.muted()
      )

    _new_entries =       
      d3.selectAll(".legend-entry").selectAll("text")

    _new_entries
      .data((d) ->
        d
      )
      .attr("class","text")
      # .enter()
      # .each( (d) ->
      #   console.log(@)
      #   console.log(d)
      # )
      # .data(@entries)
      # # .data( (d) ->
      # #   console.log(d)
      # #   return d
      # # )
      # .enter()
      # .append("text")
      # .attr('x', @lineHeight)
      # .attr('y', @lineHeight/2)
      # .text( (d) ->
      #   d.name
      # )
    


  getTranslate: (data, index) =>
    top = @lineHeight * index
    return "translate(" + @lineHeight/2 + ", " + top + " )"

  getColor: (data, index) ->
    data.color.color



class @LegendEntry
