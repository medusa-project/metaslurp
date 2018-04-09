var Application = {

    Events: {
        ITEM_ADDED_TO_FAVORITES: 'DLItemAddedToFavorites',
        ITEM_REMOVED_FROM_FAVORITES: 'DLItemRemovedFromFavorites'
    },

    /**
     * Enables the facets returned by one of the facets_as_x() helpers.
     *
     * @constructor
     */
    initFacets: function() {
        var addFacetEventListeners = function() {
            $('[name="dl-facet-term"]').off().on('change', function() {
                // Create hidden input counterparts of each checked checkbox, as
                // checkboxes' values can't change.
                var form = $(this).parents('form:first');
                form.find('[name="fq"]').remove();
                form.find('[name="fq[]"]').remove();
                form.find('[name=dl-facet-term]:checked').each(function() {
                    var input = $('<input type="hidden" name="fq[]">');
                    input.val($(this).data('query'));
                    form.append(input);
                });

                $.ajax({
                    url: $('[name=dl-current-path]').val(),
                    method: 'GET',
                    data: form.serialize(),
                    dataType: 'script',
                    success: function(result) {
                        eval(result);
                    },
                    error: function(xhr, status, error) {
                        console.error(xhr.responseText);
                        console.error(status);
                        console.error(error);
                    }
                });
            });
        };

        // When a filter field has been updated, it will change the facets.
        $(document).ajaxSuccess(function(event, request) {
            addFacetEventListeners();
        });
        addFacetEventListeners();
    },

    /**
     * Application-level initialization.
     */
    init: function() {
        // Disable disabled anchors.
        $('a[disabled="disabled"]').click(function(e){
            e.preventDefault();
            return false;
        });

        // make the active nav bar nav active
        $('.navbar-nav li').removeClass('active');
        $('.navbar-nav li#' + $('body').attr('data-nav') + '-nav')
            .addClass('active');
    },

    /**
     * @return An object representing the current view.
     */
    view: null

};

var ready = function() {
    Application.init();
};

$(document).ready(ready);
