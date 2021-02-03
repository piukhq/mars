var queryString = "%@"

performQuery()

function performQuery() {
    if (document.querySelector(queryString)) {
        return {
            "element_detected": true
        }
    } else {
        return {
            "element_detected": false
        }
    }
}
