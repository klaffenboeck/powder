var ready;
ready = function() {
  $.ajax({
    url: document.URL + "/remotecall",
    cache: false
  })
  .done(function( json ) {
    console.log("SETTING")
    console.log(json["setting"]);
    window.manager = new Manager(json["setting"]);
    console.log("MANAGER");
    console.log(window.manager);
    window.m = window.manager;
    get_runs();
  });

  // $("#post").click(function() {
  //   $.ajax({
  //     url: document.URL + "/remotepost",
  //     cache: false,
  //     type: "POST",
  //     data: { parameters: {param1: 10, param2: 2}}
  //   })
  //   .done(function( json ) {
  //     //do nothing
  //     window.ajax_value = json;
  //   });
  // });
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
    console.log("remote done, start setup")
    window.m.runs = json
    window.m.hist = new History({runs: m.runs.runs})
    window.m.hist.render()
  });
};