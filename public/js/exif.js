$(function() {
    console.log("Ready!");
    var source   = $("#entry-template").html();
    var template = Handlebars.compile(source);
    $(document).ajaxError(function() {
        console.log("AJAX error!");
    });
    $.ajax({
        url: 'http://localhost:9200/_cluster/nodes/stats?pretty=true',
        data: { },
        success: function( data ) {
            console.log("got index data!");
            var count = (data.nodes["2kT0nozsR1-dr9FsHmBL3w"].indices.docs.count);
            $("#nphotos").text(count);
        },
        dataType: 'json'
    });
    function hello (data) {
      console.log("got photo data!");
      var nhits = data.hits.total;
      $("#nhits").text(nhits);
      var hits = data.hits.hits;
      var hits_tidy = _.map(
        hits,
        function (hit) {
          //console.log('in each', hit);
          return {
            filename: hit._id,
            fields: JSON.stringify(hit.fields)
          };
        });
      //console.log(hits_tidy);
      var html = template({ hits: hits_tidy});
      $("#thumbnails").html(html);
    };
    $("button").each(function( index ) {
        console.log(index + ": " + $(this).text());
        console.log($(this).attr('es'));
        $(this).click(function() {
          $.ajax({
              url: $(this).attr('es'),
              success: hello,
          });
        });
    });
});
