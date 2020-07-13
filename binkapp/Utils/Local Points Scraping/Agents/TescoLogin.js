var timeoutSeconds = 30;

var username = "%@";
var password = "%@";

var checkLogin = setInterval(checkLoginFields, 1000);
setTimeout(function() {
    clearInterval(checkLogin);
}, timeoutSeconds * 1000);

function checkLoginFields() {
    var usernameInput = document.getElementById('username');
    var passwordInput = document.getElementById('password');
    var buttons = document.getElementsByClassName('ui-component__button');
    var signInButton = buttons[0];
    usernameInput.value = username;
    passwordInput.value = password;
    if (signInButton == null) {
        return;
    }
    signInButton.click();
    clearInterval(checkLogin);
}
