var restartfunction = false;

$(function () {
    $("html").hide()
    
    window.addEventListener('message', function(event) {
        var edata = event.data;
        if (edata.type === "show") {
            if (edata.status == true) {
                restartfunction = false;
                $("html").fadeIn();
                $("html").show();
            } else {
                restartfunction = true;
                $("html").hide();
            }
        }
    })

    window.addEventListener('message', function (event) {
        try {
            switch(event.data.action) {
                case 'hidebutton':
                    $("#button").hide()
                break;

                case 'showbutton':
                    $("#button").show()
                break;

                case 'starttimer':
                    if (event.data.value != null) fiveMinutes = 60 * event.data.value,
                    display = $('#timer');
                    startTimer(fiveMinutes, display);
                break;
            }
    } catch(err) {}
    });

    $("#button").click(function () {
        $.post('https://cink_ems/button', JSON.stringify({}));
        return
    })
})

function startTimer(duration, display) {
    var timer = duration, minutes, seconds;
    setInterval(function () {
        minutes = parseInt(timer / 60, 10);
        seconds = parseInt(timer % 60, 10);

        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;

        display.text(minutes + ":" + seconds);

        if (--timer < 0) {
            timer = duration;
        }
        
        if (restartfunction == true) {
            timer = duration;
        }

    }, 1000);
}