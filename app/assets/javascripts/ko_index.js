// Knockout ViewModel for System Status
function StatusViewModel() {
    var self = this;

    // OBSERVABLES /////////////////////////////////////////////////////////
    self.mpdStatus = ko.observable(null);
    self.icecastStatus = ko.observable(null);
    self.fileShareStatus = ko.observable();

    self.webPlayerHighVisible = ko.observable(false);
    self.webPlayerLowVisible = ko.observable(false);

    // ACTIONS /////////////////////////////////////////////////////////////
    self.getStatus = function() {
        $.ajax({
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            type: "GET",
            url: "/api/stats/share"
        }).success(function(data) {
           self.fileShareStatus(data);
        });

        $.ajax({
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            type: "GET",
            url: "/api/stats/mpd"
        }).success(function(data) {
            self.mpdStatus(data);
        });

        $.ajax({
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            type: "GET",
            url: "api/stats/icecast"
        }).success(function(data) {
            self.icecastStatus(data);
        });
    };

    self.showHighWebPlayer = function() {
        self.webPlayerHighVisible(true);
    }

    self.showLowWebPlayer = function() {
        self.webPlayerLowVisible(true);
    };
}
var vm = new StatusViewModel();

// Setup the loading to occur when the document is ready and after every 1min
$(document).ready(function() {
    ko.applyBindings(vm);

    vm.getStatus();
    setInterval(vm.getStatus, 60000);
});

