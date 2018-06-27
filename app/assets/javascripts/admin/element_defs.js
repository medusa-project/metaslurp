/**
 * @constructor
 */
var DLAdminElementDefsView = function() {

    this.init = function() {
        var ROOT_URL = $('input[name="dl-root-url"]').val();

        $('button.dl-edit-element').on('click', function() {
            var element_name = $(this).data('element-name');
            var url = ROOT_URL + '/admin/elements/' + element_name + '/edit';

            $.get(url, function(data) {
                $('#dl-edit-element-modal .modal-body').html(data);
            });
        });
    };

};

var ready = function() {
    if ($('body#dl-admin-elements').length) {
        new DLAdminElementDefsView().init();
    }
};

$(document).ready(ready);
