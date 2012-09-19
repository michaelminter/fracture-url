$(document).ready(function() {
  //EMAIL FORM AJAX HANDLERS
  $(function(){
     $('#contact_form').submit(function(e){
      e.preventDefault();
      var form      = $(this);
      var post_url  = form.attr('action');
      var post_data = form.serialize();
      $('#loader', form).html('<img src="/images/loader.gif" /> Please Wait...');
      $.ajax({
        type: 'POST',
        url: post_url,
        data: post_data,
        dataType: 'json',
        success: function(msg) {
          console.log(msg.errors.length);
          $('#messages small').fadeOut(500);
          setTimeout(function() {
            $('#messages small').html(msg.fractured_url).fadeIn(500);
          }, 500);
          if (msg.errors.length > 0) {
            setTimeout(function() {
              $('#messages small').html(msg.errors).fadeIn(500)
            },500);
          }
        }
      });
    });
  });
});
