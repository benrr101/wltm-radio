// Knockout ViewModel for History page
function HistoryViewModel() {
    var self = this;

    // OBSERVABLES /////////////////////////////////////////////////////////
    self.historyRecords = ko.observableArray(null);
    self.currentTrack = ko.observable(null);
    self.currentPage = ko.observable(0);

    // ACTIONS /////////////////////////////////////////////////////////////
    self.getHistory = function() {
        $.ajax({
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            type: "GET",
            url: "/api/history/date?start=0&desc=true&pagesize=100&page=0"
        }).success(function(data) {
            self.currentTrack(data[0]);
            self.historyRecords(data.slice(1));
        });
    };

    self.getCurrent = function() {
        $.ajax({
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            type: "GET",
            url: "/api/history/current"
        }).success(function(data) {
            if(self.currentTrack() == null) {
                // We haven't had a track set yet, just set it
                self.currentTrack(data);
            } else if(self.currentTrack().id != data.id) {
                // This is a new track, append to the front of the list, and change the current track
                self.historyRecords.unshift(data);
                self.historyRecords.pop(); // Remove the bottom to prevent duplicates on load more
                self.currentTrack(data)
            }
            // Otherwise, we don't need to do anything
        });
    };

    self.loadMore = function() {
        self.currentPage(self.currentPage() + 1);
        $.ajax({
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            type: "GET",
            url: "/api/history/date?start=0&desc=true&pagesize=100&page=" + self.currentPage()
        }).success(function(data) {
            self.historyRecords.pushAll(data);
        })
    };
}
var vm = new HistoryViewModel();

// Setup the loading to occur when the document is ready and after every minute
$(document).ready(function() {
    ko.applyBindings(vm);

    vm.getHistory();
    setInterval(vm.getCurrent, 60000);
});

function formatDate(dateTime) {
    var dateObj = new Date(dateTime);
    return dateObj.toLocaleTimeString() + ", " + dateObj.toLocaleDateString()
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
