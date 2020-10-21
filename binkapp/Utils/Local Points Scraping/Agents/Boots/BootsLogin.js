var timeoutSeconds = 30;

var username = "%@";
var password = "%@";

var checkLogin = setInterval(checkLoginFields, 1000);
setTimeout(function() {
    clearInterval(checkLogin);
}, timeoutSeconds * 1000);

function checkLoginFields() {
    var usernameInput = document.getElementById('gigya-loginID-126189670420823710');
    var passwordInput = document.getElementById('gigya-password-21094567555302330');
    usernameInput.value = username;
    passwordInput.value = password;
    var buttons = document.getElementsByClassName('gigya-input-submit');
    
    for (i = 0; i < buttons.length; i++) {
        if (buttons[i].value == "Log in") {
            buttons[i].click();
            clearInterval(checkLogin);
        }
    }
}
