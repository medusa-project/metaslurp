/**
 * @constructor
 */
var DLFavoritesView = function() {

    this.init = function() {
        $(document).on(Application.Events.ITEM_REMOVED_FROM_FAVORITES, function(event, item) {
            $('[data-item-id="' + item.id + '"]').closest('li').fadeOut(function() {
                var badge = $('.dl-favorites-count');
                var num_favorites = DLItem.numFavorites();
                badge.text(num_favorites);
                if (num_favorites < 1) {
                    $('.dl-no-favorites').show();
                    $('#dl-download-menu').hide();
                } else {
                    $('.dl-no-favorites').hide();
                    $('#dl-download-menu').show();
                }
            });
        });

        if (DLItem.numFavorites() < 1) {
            $('.dl-no-favorites').show();
            $('#dl-download-menu').hide();
        } else {
            $('.dl-no-favorites').hide();
            $('#dl-download-menu').show();
        }
        $('.dl-remove-from-favorites').show();

        attachEventListeners();
    };

    var attachEventListeners = function() {
        $('button.dl-remove-from-favorites').on('click', function() {
            var item = new DLItem();
            item.id = $(this).data('item-id');
            item.removeFromFavorites();
        });

        $('.pagination:eq(1) a').on('click', function() {
            $('#dl-search-status')[0].scrollIntoView({behavior: "smooth"});
        });
    };

};

var ready = function() {
    if ($('body#favorites').length) {
        Application.view = new DLFavoritesView();
        Application.view.init();
    }
};

$(document).ready(ready);
