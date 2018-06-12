/**
 * Handles list-harvests view.
 *
 * @constructor
 */
var DLAdminHarvestsView = function() {

    var HARVESTS_URL = $('input[name="dl-harvests-url"]').val();

    this.init = function() {
        new HarvestRefresher().start();
        new Application.FilterField();
    };

    var HarvestRefresher = function() {

        var FREQUENCY = 5000;

        var refreshTimer;

        var refresh = function() {
            var current_page = $('.pagination li.active > a:first')
                .text().replace(/[/\D]/g, '');
            if (current_page == 0) {
                current_page = 1;
            }
            var start = (current_page - 1) * $('[name=dl-limit]').val();
            var url = HARVESTS_URL + '?start=' + start;

            console.debug('Refreshing harvests: ' + url);

            $.ajax({
                url: url,
                data: $('form.dl-filter').serialize(),
                success: function (data) {
                    // this will be handled by index.js.erb
                }
            });
        };

        this.start = function() {
            refreshTimer = setInterval(refresh, FREQUENCY);
            refresh();
        };

    };

};

/**
 * Handles show-harvest view.
 *
 * @constructor
 */
var DLAdminHarvestView = function() {

    var HARVEST_URL = $('input[name="dl-current-path"]').val();

    this.init = function() {
        new HarvestRefresher().start();
    };

    var HarvestRefresher = function() {

        var FREQUENCY = 5000;

        var refreshTimer;

        var refresh = function() {
            console.debug('Refreshing harvest: ' + HARVEST_URL);
            $.ajax({
                url: HARVEST_URL,
                success: function (data) {
                    // this will be handled by show.js.erb
                }
            });
        };

        this.start = function() {
            refreshTimer = setInterval(refresh, FREQUENCY);
            refresh();
        };

    };

};

var ready = function() {
    if ($('body#dl-admin-harvests').length) {
        Application.view = new DLAdminHarvestsView();
        Application.view.init();
    } else if ($('body#dl-admin-harvest').length) {
        Application.view = new DLAdminHarvestView();
        Application.view.init();
    }
};

$(document).ready(ready);
