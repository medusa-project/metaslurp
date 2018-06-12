var Application = {

    Events: {
        ITEM_ADDED_TO_FAVORITES: 'DLItemAddedToFavorites',
        ITEM_REMOVED_FROM_FAVORITES: 'DLItemRemovedFromFavorites'
    },

    /**
     * Enables the facets returned by one of the facets_as_x() helpers.
     */
    initFacets: function() {
        var addFacetEventListeners = function() {
            $('[name="fq[]"]').off('change').on('change', function() {
                var form = $(this).parents('form:first');

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
    view: null,

    /**
     * Provides an ajax filter field. This will contain HTML like:
     *
     * <form class="dl-filter">
     *     <input type="text">
     *     <select> <!-- optional -->
     * </form>
     *
     * @constructor
     */
    FilterField: function() {
        var INPUT_DELAY_MSEC = 500;

        $('form.dl-filter').submit(function () {
            $.get(this.action, $(this).serialize(), null, 'script');
            $(this).nextAll('input').addClass('active');
            return false;
        });

        var submitForm = function () {
            var forms = $('form.dl-filter');
            $.ajax({
                url: forms.attr('action'),
                method: 'GET',
                data: forms.serialize(),
                dataType: 'script',
                success: function(result) {}
            });
            return false;
        };

        var input_timer;
        // When text is typed in the filter field...
        $('form.dl-filter input').on('keyup', function () {
            // Reset the typing-delay counter.
            clearTimeout(input_timer);

            // After the user has stopped typing, wait a bit and then submit
            // the form via AJAX.
            input_timer = setTimeout(submitForm, INPUT_DELAY_MSEC);
            return false;
        });
        // When form controls accompanying the filter field are changed,
        // resubmit the form via AJAX.
        $('form.dl-filter select, ' +
            'form.dl-filter input[type=radio]').on('change', function() {
            submitForm();
        });
    }

};

var ready = function() {
    Application.init();
};

$(document).ready(ready);
