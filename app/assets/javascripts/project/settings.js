$( document ).ready(function() {
  $.ajax({
    url: document.URL + "/remotecall",
    cache: false
  })
  .done(function( json ) {
    console.log(json["setting"]);
    window.manager = new Manager(json["setting"]);
    window.m = window.manager
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
});