function formatDate(dateTime) {
    var dateObj = new Date(dateTime);
    return dateObj.toLocaleTimeString() + ", " + dateObj.toLocaleDateString()
}

function formatTime(seconds) {
    // Greedily divide the seconds starting with hours
    var hours = Math.floor(seconds / 3600);
    seconds %= 3600;
    var minutes = Math.floor(seconds / 60);
    seconds %= 60;

    // Put the hours on if it's greater than 0
    var timeString = "";
    if(hours > 0) { timeString += hours + ":"; }

    // Put on minutes and seconds regardless
    if(minutes < 10 && hours > 0) { timeString += "0"; }
    timeString += minutes + ":";

    // Put on seconds last
    if(seconds < 10) { timeString += "0"; }
    timeString += seconds;

    return timeString;
}

var greedyTimeDivisors = [
    {
        divisor: 31557600000,
        name: "year"
    },
    {
        divisor: 2592000000,
        name: "month"
    },
    {
        divisor: 86400000,
        name: "day"
    },
    {
        divisor: 3600000,
        name: "hour"
    },
    {
        divisor: 60000,
        name: "minute"
    },
    {
        divisor: 1,
        name: "moment"
    }
];
function formatFriendlyTime(dateTime) {
    // Calculate the difference between now and the provided date
    var milliDifference = new Date() - new Date(dateTime);

    // Greedily select the highest difference time

    for(var i = 0; i < greedyTimeDivisors.length; ++i) {
        if(greedyTimeDivisors[i].divisor == 1) {
            return "just a moment ago"
        }
        var intDivision = Math.floor(milliDifference / greedyTimeDivisors[i].divisor);
        if(intDivision == 1) {
            return "1 " + greedyTimeDivisors[i].name + " ago"
        }
        if(intDivision > 1) {
            return intDivision + " " + greedyTimeDivisors[i].name + "s ago";
        }
    }
}