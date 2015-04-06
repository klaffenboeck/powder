var ready;
var temp_result_vector;
ready = function() {
  console.log(document.URL + "/remotecall");
  $.ajax({
    url: document.URL + "/remotecall",
    cache: false
  })
  .done(function( json ) {
    console.log("creating manager")
    console.log(json);
    window.manager = new Manager(json["setting"]);
    window.m = window.manager;
    window.m.selection_manager.navigation = window.m.navigation
    console.log("get runs");
    get_runs();
    get_initial_runs();

  });

  $(".set-exclude").click(function(e) {
    window.m.linechart.createCurrentBlock();
    $(this).addClass("disabled")
    e.preventDefault();
  });
  $(".create-overview").click(function(e) {
    // exc = window.m.exclusions_list.getCurrent();
    // sel = BaseSelection.factory(exc);
    if($(this).data("base-selection")) {
      window.m.selection_manager.createNewBaseSelection();
    }
    if($(this).data("selection")) {
      window.m.selection_manager.createNewSelection(window.m.errorchart.getCurrentExtent());
    }
    sel = window.m.selection_manager.getCurrentSelection()
    result_vector = window.m.selection_manager.initial_run_list.compareWithSelection(sel);
    temp_result_vector = result_vector;
    console.log(result_vector);
    $.ajax({
      url: document.URL + "/alternative_estfunc",
      cache: false,
      type: "POST",
      data: {
        parameters: result_vector
      }

    })
    .done(function( json ) {
      json.gaussian_process_model.result_vector = temp_result_vector;
      func = EstimationFunction.factory(json);
      //window.m.estfunc_list.addFunction(func);
      window.m.selection_manager.setFunction(func)
      window.m.navigation.estimation_function = func;
      oldviews = $(".complex-view");
      samples = m.generateSamples();
      window.m.complex_view_holder.sampling = window.m.samples;
      window.m.selection_manager.renderDisplayRunList()
      m.complex_view_holder.newProjectionView();
      oldviews.hide();

    });
    e.preventDefault();
  })
};

$(document).ready(ready);
$(document).on('page:load', ready);

var get_runs;
get_runs = function() {
  $.ajax({
    url: document.URL + "/get_runs",
    cache: false
  })
  .done(function( json ) {
    window.m.selection_manager.full_run_list = RunList.factory(json.runs, m.selection_manager)
    window.m.selection_manager.renderDisplayRunList()
    //window.m.hist = new History({runs: m.runs.runs})
    //window.m.hist.render()
  });
};

var get_initial_runs;
get_initial_runs = function() {
  $.ajax({
    url: document.URL + "/get_initial_runs",
    cache: true
  })
  .done(function( json ) {
    //window.m.initial_runs = new InitialRunList({run_list: json.initial_runs})
    window.m.selection_manager.initial_run_list = InitialRunList.factory(json.initial_runs, m.selection_manager)

  });
};