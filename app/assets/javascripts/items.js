/**
 * Handles items a.k.a. results view.
 *
 * @constructor
 */
var DLItemsView = function() {

    var self = this;

    this.init = function() {
        Application.initFacets();
        new Application.FilterField();
        self.attachEventListeners();
    };

    this.attachEventListeners = function() {
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
            $(this).next('.dl-load-indicator').remove();
            $(this).fadeIn(300);
        }).on('error', function() {
            $(this).next('.dl-load-indicator').remove();
        }).each(function() {
            if (this.complete) {
                $(this).trigger('load');
            }
        });

        $('.pagination:eq(1) a').on('click', function() {
            $('#dl-search-status')[0].scrollIntoView({behavior: "smooth"});
        });
    };

};

var ready = function() {
    if ($('body#items_index, body#collections_index').length) {
        Application.view = new DLItemsView();
        Application.view.init();
    }
};

$(document).ready(ready);
