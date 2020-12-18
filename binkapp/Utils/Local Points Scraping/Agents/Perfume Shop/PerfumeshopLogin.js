var timeoutSeconds = 30;

var username = "%@";
var password = "%@";

var checkLogin = setInterval(checkLoginFields, 1000);
setTimeout(function() {
    clearInterval(checkLogin);
}, timeoutSeconds * 1000);

function checkLoginFields() {
    var usernameInput = document.getElementById('login-email');
    var passwordInput = document.getElementById('login-pwd');
    var buttons = document.getElementsByClassName('btn btn-green custom_field__btn j-submit Login');
    var signInButton = buttons[0];
    usernameInput.value = username;
    passwordInput.value = password;
    if (signInButton == null) {
        return;
    }
    signInButton.click();
    clearInterval(checkLogin);
}
