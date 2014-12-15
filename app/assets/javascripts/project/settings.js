$( document ).ready(function() {
  $("#button").click(function() {
    $.ajax({
      url: document.URL + "/remotecall",
      cache: false
    })
    .done(function( json ) {
      alert( json.name );
    });
  });
  $("#post").click(function() {
    $.ajax({
      url: document.URL + "/remotepost",
      cache: false,
      type: "POST",
      data: { parameters: {param1: 10, param2: 2}}
    })
    .done(function( json ) {
      //do nothing
      window.ajax_value = json;
    });
  });
});