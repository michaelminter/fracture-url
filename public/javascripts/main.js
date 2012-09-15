$(document).ready(function() {
  //EMAIL FORM AJAX HANDLERS
  $(function(){
     $('#contact_form').submit(function(e){
      e.preventDefault();
      var form = $(this);
      var post_url = form.attr('action');
      var post_data = form.serialize();
      $('#loader', form).html('<img src="loader.gif" /> Please Wait...');
        $.ajax({
          type: 'POST',
          url: post_url,
          data: post_data,
          dataType: 'json',
          success: function(msg) {
            $('#messages small').fadeOut(500);
            setTimeout(function() {
              $('#messages small').html(msg.fractured_url).fadeIn(500);
            }, 500);
          }
        });
      });
  });

  //TWITTER SET UP
  // getTwitters('tweet', { 
      // id: 'mothore',//ADD IN YOUR OWN TWITTER ID HERE
      // count: 1, 
      // enableLinks: true, 
      // ignoreReplies: true, 
      // clearContents: true,
      // template: '<img src="/images/twitterBird.png" alt="Twitter Bird" class="twitterBird" />"%text%" <a href="http://twitter.com/%user_screen_name%/statuses/%id_str%/">%time%</a>'
  // });
});
