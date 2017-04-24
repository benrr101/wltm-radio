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
            if(self.currentTrack() === null) {
                // We haven't had a track set yet, just set it
                self.currentTrack(data);
            } else if(self.currentTrack().id !== data.current_track.id) {
                // This is a new track, append to the front of the list, and change the current track
                self.historyRecords.unshift(data.current_track);
                self.historyRecords.pop(); // Remove the bottom to prevent duplicates on load more
                self.currentTrack(data.current_track)
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
