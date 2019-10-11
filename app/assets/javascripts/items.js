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
            $.ajax({
                url: $('[name=dl-current-path]').val(),
                method: 'GET',
                data: $(this).parents('form:first').serialize(),
                dataType: 'script',
                success: function (result) {
                    eval(result);
                }
            });
        });

        $('.dl-thumbnail-container img[data-location="remote"]').one('load', function() {
            $(this).parent().next('.dl-load-indicator').hide();
            $(this).animate({'opacity': 1}, 300);
        }).on('error', function() {
            $(this).parent().next('.dl-load-indicator').hide();
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

var ready = function() {
    if ($('body#items_index, body#collections_index').length) {
        Application.view = new DLItemsView();
        Application.view.init();
    }
};

$(document).ready(ready);
