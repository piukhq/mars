var timeoutSeconds = 30;

var username = "%@";
var password = "%@";

var checkLogin = setInterval(checkLoginFields, 1000);
setTimeout(function() {
    clearInterval(checkLogin);
}, timeoutSeconds * 1000);

function checkLoginFields() {
    document.getElementById("email").value = username;
    document.getElementById("password").value = password;
    
    var buttons = document.getElementsByClassName("btn btn-secondary btn-disable");
    for (i = 0; i < buttons.length; i++) {
        if (buttons[i].value == "Log in") {
            buttons[i].click();
            clearInterval(checkLogin);
        }
    }
}
