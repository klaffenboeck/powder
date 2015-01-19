class @QualityMetric
  constructor: (options={}) ->
    @expected = options.expected ? window.m.measured_points
    @observed = options.run.emulated_points
    @observed ? options.observed


class @Chi2 extends QualityMetric
  constructor: (options={}) ->
    super(options)
    @value = Chi2.perform_comparison(@observed.points, @expected.points)

  @perform_comparison: (observed, expected = window.m.measured_points.points) =>
    sum = 0
    for val, i in observed
      sum += Chi2.perform_single(val, expected[i])
    res = (sum / observed.length)
    return res

  @perform_single: (observed, expected) =>
    v = observed - expected
    v2 = v*v
    res = v2 / expected
    return res

  normal: (max = 10000) =>
    bounded_value = @value
    bounded_value = max if @value > max
    val = Math.round(bounded_value)
    res = max - val
    return res / max


