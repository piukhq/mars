var timeoutSeconds = 30;

var username = "%@";
var password = "%@";

var checkLogin = setInterval(checkLoginFields, 1000);
setTimeout(function() {
    clearInterval(checkLogin);
}, timeoutSeconds * 1000);

function checkLoginFields() {
    var usernameInput = document.getElementById('login_form_email');
    var passwordInput = document.getElementById('login_form_password');
    var buttons = document.getElementsByClassName('button button-teal button-formsubmit');
    var signInButton = buttons[0];
    usernameInput.value = username;
    passwordInput.value = password;
    if (signInButton == null) {
        return;
    }
    signInButton.click();
    clearInterval(checkLogin);
}
