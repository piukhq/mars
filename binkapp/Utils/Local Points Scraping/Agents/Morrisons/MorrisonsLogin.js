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
}
