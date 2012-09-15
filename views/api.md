#Documentation::API

##Console

    curl -d 'url=yourdomain' http://fracture.it

**JSON Return**

`{"fractured_url":"http://fracture.it/3"}`

or, if your URL is more than 200 characters, or simply isn't a URL at all

`{"fractured_url":"","error":["Not a valid URL format"]}`

##AJAX

    $.ajax({
      type: "POST",
      url: "http://fracture.it",
      data: { url: "yourdomain" },
      dataType: 'JSON'
    }).done(function(data) {
      $('#message').html("Fractured URL: " + data.fractured_url);
    });
