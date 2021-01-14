const queryStrings = [".pointvalue", ".total-points", ".plus-balance-row strong", ".sd-panel p:last-of-type b"]

performPointsScraping()

function performPointsScraping() {
    var queryString
    for (i = 0; i < queryStrings.length; i++) {
        var points = document.querySelector(queryStrings[i])
        if (points !== null) {
            queryString = queryStrings[i]
            break
        }
    }

    const p = document.querySelector(queryString)

    if (p.innerHTML) {
        if (isNaN(p.innerHTML)) {
            var num = p.innerHTML.match(/\d+/);
            return {
                "points": num[0]
            }
        }
        return {
            "points": p.innerHTML
        }
    } else if (p.innerText) {
        if (isNaN(p.innerText)) {
            var num = p.innerText.match(/\d+/);
            return {
                "points": num[0]
            }
        }
        return {
            "points": p.innerText
        }
    } else {
        return {
            "error_message": "Could not scrape points value."
        }
    }
}
