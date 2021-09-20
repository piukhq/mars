var username = "%@"
var password = "%@"
var configurator = "%@"

var usernameInputQuery = "input[name=email]"
var passwordInputQuery = "input[type=password]"
var submitButtonQuery = "button"

var menuIconQuery = "svg"

var rewardsNavButtonQuery = "a[href*=my-rewards]"
var loginNavButtonQuery = "a[href*=login]"

var pointsValueQuery = "text[fill=white]"

var incorrectCredentialsQuery = "p.js-title"

handleNavigation()

function handleNavigation() {
    if (window.location === "https://order.kfc.co.uk") {
        window.location === "https://order.kfc.co.uk/account/login"
    }

    if (window.location === "https://order.kfc.co.uk/account/login") {
        window.location === "https://www.google.co.uk"
    }


    // console.log('1')
    // // 1. Can we identify a points balance?

    // var pts = document.querySelector(pointsValueQuery)
    // if (pts) {

    //     console.log('2')
    //     // 2. Scrape the balance if possible
    //     return {
    //         "points": pts.innerHTML
    //     }
    // }

    // console.log('3')
    // // 3. Can we identify a login form?

    // var u = document.querySelector(usernameInputQuery)
    // var p = document.querySelector(passwordInputQuery)
    // var b = document.querySelector(submitButtonQuery)
    // if (u && p && b && b.innerHTML === "Sign In") {

    //     // 4. Can we identify an incorrect credentials error message?

    //     // 5. Return the error message

    //     console.log('6')
    //     // 6. Attempt to login
    //     var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set
    //     nativeInputValueSetter.call(u, username)
    //     nativeInputValueSetter.call(p, password)

    //     var valueSetterEvent = new Event('input', { bubbles: true })
    //     u.dispatchEvent(valueSetterEvent)
    //     p.dispatchEvent(valueSetterEvent)

    //     b.click()

    //     return {
    //         "did_attempt_login": true
    //     }
    // }

    // console.log('7')
    // // 7. Can we identify a menu icon?

    // var m = document.querySelector(menuIconQuery)
    // if (m) {

    //     console.log('8')
    //     // 8. Tap the menu icon
    //     m.parentElement.click()

    //     console.log('9')
    //     // 9. Can we identify a link to account/my-rewards?
    //     var rewards = document.querySelector(rewardsNavButtonQuery)
    //     if (rewards) {

    //         console.log('10')
    //         // 10. Tap the reward link link
    //         rewards.click()
    //         return {}
    //     }

    //     console.log('11')
    //     // 11. Can we identify a link to the login screen?

    //     var login = document.querySelector(loginNavButtonQuery)
    //     if (login) {

    //         console.log('12')
    //         // 12. Tap the login link
    //         login.click()
    //         return {}
    //     }
    // }

    // If we can't identify a points value, can we identify one of the following an incorrect credentials message

    // var error = document.querySelector(incorrectCredentialsQuery)
    // if (error && error.innerHTML !== "") {
    //     return {
    //         "did_attempt_login": true,
    //         "error_message": "Login failed. Incorrect credentials identified: " + error.innerHTML
    //     }
    // }


    // If we cannot identify a login form, points value, recaptcha or incorrect credentials
    // We should assume the client is redirecting, and the idle timer should handle moving to retry state
    return {}
}
