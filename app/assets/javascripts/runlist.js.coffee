class @BaseRunList
  constructor: (options={}) ->
    {@run_list} = options

  compareWithSelection: (selection) ->
    results = []
    for run in @run_list
      simulated = run.emulated_points.points
      result = Chi2.compare(simulated, selection)
      results.push(result)
    return results


class @InitialRunList extends BaseRunList
  constructor: (options={}) ->
    super(options)

