var timeoutSeconds = 30;

var username = "%@";
var password = "%@";

var checkLogin = setInterval(checkLoginFields, 1000);
setTimeout(function() {
    clearInterval(checkLogin);
}, timeoutSeconds * 1000);

function checkLoginFields() {
    var usernameInput = document.getElementsByClassName('card-number generic-textfield left margin10bottom clr')[0];
    var passwordInput = document.getElementById('password');
    var signInButton = document.getElementsByClassName('btn btn--primary')[0];
    usernameInput.value = username;
    passwordInput.value = password;
    if (signInButton == null) {
        return;
    }
    signInButton.click();
    clearInterval(checkLogin);
}
