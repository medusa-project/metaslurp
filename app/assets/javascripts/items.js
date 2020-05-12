/**
 * Handles items a.k.a. results view.
 *
 * @constructor
 */
var DLItemsView = function() {

    var RESULTS_STYLE_COOKIE = 'results-style';

    var self = this;

    this.init = function() {
        var results_style = Cookies.get(RESULTS_STYLE_COOKIE);
        if (results_style) {
            self.initResultsStyle(results_style);
        }

        Application.initFacets();
        new Application.FilterField();
        self.attachEventListeners();
    };

    this.attachEventListeners = function() {
        $('[name=dl-results-style]').off().on('change', function() {
            self.setResultsStyle($(this).val());
        });
        // Submit the sort form on change.
        $('select[name="sort"]').off().on('change', function () {
            var query = $(this).parents('form:first')
                .find(':not(input[name=dl-results-style])').serialize();
            $.ajax({
                url: $('[name=dl-current-path]').val(),
                method: 'GET',
                data: query,
                dataType: 'script',
                success: function (result) {
                    // Enables results page persistence after back/forward
                    // navigation.
                    window.location.hash = query;
                    eval(result);
                }
            });
        });

        // Override Rails' handling of link_to() with `remote: true` option.
        // We are doing the same thing but also updating the hash.
        $('.page-link').on('click', function() {
            var url   = $(this).attr('href');
            var query = url.substring(url.indexOf("?") + 1);
            $.ajax({
                url: url,
                method: 'GET',
                dataType: 'script',
                success: function(result) {
                    window.location.hash = query;
                    eval(result);
                }
            });
            return false;
        });

        $('.dl-thumbnail-container img[data-location="remote"]').one('load', function() {
            $(this).parent().next('.spinner-border').hide();
            $(this).animate({'opacity': 1}, 300);
        }).on('error', function() {
            $(this).parent().next('.spinner-border').hide();
        }).each(function() {
            if (this.complete) {
                $(this).trigger('load');
            }
        });

        $('.pagination:eq(1) a').on('click', function() {
            $('#dl-search-status')[0].scrollIntoView({behavior: "smooth"});
        });
    };

    /**
     * @param results_style [String] `more` or `less`
     */
    this.initResultsStyle = function(results_style) {
        self.setResultsStyle(results_style);

        $('.dl-result-controls .btn-group label').removeClass('active');
        var radio = $('[name=dl-results-style][value=' + results_style +']');
        radio.prop('checked', true);
        radio.parent().addClass('active');
    };

    /**
     * @param results_style [String] `more` or `less`
     */
    this.setResultsStyle = function(results_style) {
        var collapse_buttons = $('a.result-collapse');
        var collapses        = $('div.result-collapse');
        if (results_style === 'more') {
            collapse_buttons.hide();
            collapses.addClass('show');
        } else {
            collapse_buttons.show();
            collapses.removeClass('show');
        }
        Cookies.set(RESULTS_STYLE_COOKIE, results_style,
            {expires: 3650, path: '/'});
    };

};

$(document).ready(function() {
    if ($('body#items_index, body#collections_index').length) {
        Application.view = new DLItemsView();
        Application.view.init();
    }
});

/**
 * When the page is shown, restore page state based on the query embedded in
 * the hash. This has to be done on pageshow because document.ready doesn't
 * fire on back/forward.
 */
$(window).on("pageshow", function(event) {
    if ($('body#items_index, body#collections_index').length) {
        if (!event.originalEvent.persisted) {
            var query = window.location.hash;
            if (query.length) {
                query = query.substring(1); // trim off the `#`
                console.debug('Restoring ' + query);
                $.ajax({
                    url: $('[name=dl-current-path]').val(),
                    method: 'GET',
                    data: query,
                    dataType: 'script',
                    success: function (result) {
                        eval(result);
                    }
                });
            }
        }
    }
});
