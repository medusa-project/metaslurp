/**
 * @constructor
 */
var DLAdminElementDefsView = function() {

    var self = this;

    this.init = function() {
        self.initEditModal();
    };

    this.initEditModal = function() {
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

var DLAdminElementDefView = function() {

    this.init = function() {
        new DLAdminElementDefsView().initEditModal();
    };

};

var ready = function() {
    if ($('body#dl-admin-elements').length) {
        new DLAdminElementDefsView().init();
    } else if ($('body#dl-admin-show-element').length) {
        new DLAdminElementDefView().init();
    }
};

$(document).ready(ready);
