/**
 * Handles items a.k.a. results view.
 *
 * @constructor
 */
var DLItemsView = function() {

    var self = this;

    this.init = function() {
        Application.initFacets();

        // Show the add-to- or remove-from-favorites button for each item
        // depending on whether it's already a favorite.
        $('button.dl-remove-from-favorites, button.dl-add-to-favorites').each(function() {
            var item = new DLItem();
            item.id = $(this).data('item-id');
            if (item.isFavorite()) {
                if ($(this).hasClass('dl-remove-from-favorites')) {
                    $(this).show();
                } else {
                    $(this).hide();
                }
            } else {
                if ($(this).hasClass('dl-add-to-favorites')) {
                    $(this).show();
                } else {
                    $(this).hide();
                }
            }
        });

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

        $('.pagination:eq(1) a').on('click', function() {
            $('#dl-search-status')[0].scrollIntoView({behavior: "smooth"});
        });

        $(document).on(Application.Events.ITEM_ADDED_TO_FAVORITES, function(event, item) {
            $('button.dl-remove-from-favorites[data-item-id="' + item.id + '"]').show();
            $('button.dl-add-to-favorites[data-item-id="' + item.id + '"]').hide();
            updateFavoritesCount();
        });
        $(document).on(Application.Events.ITEM_REMOVED_FROM_FAVORITES, function(event, item) {
            $('button.dl-remove-from-favorites[data-item-id="' + item.id + '"]').hide();
            $('button.dl-add-to-favorites[data-item-id="' + item.id + '"]').show();
            updateFavoritesCount();
        });
        $('button.dl-add-to-favorites').on('click', function(e) {
            var item = new DLItem();
            item.id = $(this).data('item-id');
            item.addToFavorites();
            e.preventDefault();
        });
        $('button.dl-remove-from-favorites').on('click', function(e) {
            var item = new DLItem();
            item.id = $(this).data('item-id');
            item.removeFromFavorites();
            e.preventDefault();
        });
    };

    var updateFavoritesCount = function() {
        $('.dl-favorites-count').text(DLItem.numFavorites());
    };

};

var ready = function() {
    if ($('body#items_index, body#collections_index').length) {
        Application.view = new DLItemsView();
        Application.view.init();
    }
};

$(document).ready(ready);
