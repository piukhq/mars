var username = "%@"
var password = "%@"
var configurator = "%@"

var usernameInputQuery = "input[name=email]"
var passwordInputQuery = "input[type=password]"
var submitButtonQuery = "button"

var menuIconQuery = "svg"

var rewardsNavButtonQuery = "a[href*=rewards-offers]"
var loginNavButtonQuery = "a[href*=login]"

var pointsValueQuery = "text[fill=white]"

var incorrectCredentialsQuery = "p.js-title"

handleNavigation()

function handleNavigation() {
    console.log("handling navigation")

    if (window.location.href === "https://order.kfc.co.uk/account/my-details") {
        console.log("moving from my-details to my-rewards")
        window.location.href = "https://order.kfc.co.uk/account/my-rewards"
    }

    if (window.location.href === "https://order.kfc.co.uk/account/my-rewards") {
        console.log("getting points")
        var pts = document.querySelector(pointsValueQuery)
        if (pts) {
            // return {
            //     "points": pts.innerHTML
            // }
            console.log(pts.innerHTML)
        }
    }

    if (window.location.href === "https://order.kfc.co.uk/account/login" && configurator !== "skipLogin") {
        var u = document.querySelector(usernameInputQuery)
        var p = document.querySelector(passwordInputQuery)
        var b = document.querySelector(submitButtonQuery)
        if (u && p && b && b.innerHTML === "Sign In") {
            var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set
            var valueSetterEvent = new Event('input', { bubbles: true })

            nativeInputValueSetter.call(u, username)
            u.dispatchEvent(valueSetterEvent)

            nativeInputValueSetter.call(p, password)        
            p.dispatchEvent(valueSetterEvent)

            b.click()

            // return {
            //     "did_attempt_login": true
            // }
            console.log("did attempt login")
        }
    }

    if (window.location.href === "https://order.kfc.co.uk/") {
        window.location.href = "https://order.kfc.co.uk/account/login"
    }

    // var loginButton = document.querySelector(loginNavButtonQuery)
    // if (loginButton && configurator !== "skipLogin") {
    //     loginButton.click()
    //     return {}
    // }

    // var rewardsButton = document.querySelector(rewardsNavButtonQuery)
    // if (rewardsButton) {
    //     rewardsButton.click()
    //     return {}
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
