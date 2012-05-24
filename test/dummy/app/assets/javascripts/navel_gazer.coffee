
jQuery ->
  
  console.debug "navel_gazer init"
  $("#posts").on 'error', 'img', (event) -> $(event.target).detach()
  
  $("#posts").on 'click', '.post', (event) ->
    url = $(this).attr("data-href")
    window.open(url,"_blank")
    
  $container = $('#posts');
  $container.imagesLoaded ->
    $container.masonry
      itemSelector : '.post'
    $(".invisible").removeClass("invisible")
      
  $("#load_posts").click ->
    
    post_offset = $(".post").length - 1 # exclude about div
    $("#load_posts").html("Loading...").attr('disabled', 'disabled')
    $.ajax
      url: '/posts.json'
      data: 
        offset: post_offset
      success: (data) ->
        if data.collection.length == 0
          $("#load_posts").remove()
        else
          # load posts into intermediate invisible div to wait for images
          $("#posts").after("<div id='staging'>")
          $staging = $("#staging")
          $staging.html($(JST['posts/_ngposts'](data)))
          $staging.imagesLoaded ->
            $new_posts = $($staging.html())
            $staging.detach()
            $("#posts").append($new_posts).masonry( 'appended', $new_posts )
            $(".invisible").removeClass("invisible")
      complete: ->
        $("#load_posts").html("Load more").removeAttr('disabled')
    false