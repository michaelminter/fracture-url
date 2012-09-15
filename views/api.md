#Documentation::API

##Console

    curl -d 'url=yourdomain' http://fracture.it

**Returns**

`{"fractured_url":"http://fracture.it/3"}`

or 

`{"fractured_url":"","error":["Not a valid URL format"]}`

Which is if your URL is more than 200 characters or simply isn't a URL at all

##AJAX

Form:

    <form method="POST" action="/">
      <input type="text" name="url" />
      <button type="submit" value="Submit" id="submit" />
    </form>
    <div id="message"></div>

Javascript

    <script src="http://code.jquery.com/jquery-latest.js"></script>
    <script type="text/javascript">
    $('#submit').click(function() {
      $.ajax({
        type: "POST",
        url: "http://fracture.it",
        data: { url: "yourdomain" },
        dataType: 'JSON'
      }).done(function(data) {
        $('#message').html("Fractured URL: " + data.fractured_url);
      });
    });
    </script>
