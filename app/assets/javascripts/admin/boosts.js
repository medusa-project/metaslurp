/**
 * @constructor
 */
var DLAdminBoostsView = function() {

    this.init = function() {
        var ROOT_URL = $('input[name="dl-root-url"]').val();

        $('button.dl-edit-boost').on('click', function() {
            var id = $(this).data('boost-id');
            var url = ROOT_URL + '/admin/boosts/' + id + '/edit';

            $.get(url, function(data) {
                $('#dl-edit-boost-modal .modal-body').html(data);
            });
        });
    };

};

var ready = function() {
    if ($('body#dl-admin-boosts').length) {
        new DLAdminBoostsView().init();
    }
};

$(document).ready(ready);
