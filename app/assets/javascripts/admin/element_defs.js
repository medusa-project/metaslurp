/**
 * @constructor
 */
var DLAdminElementDefsView = function() {

    var self = this;

    this.init = function() {
        self.initEditModal();

        $('#dl-sort').on('change', function() {
            $(this).closest('form').submit();
        });
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

    var self = this;

    this.init = function() {
        new DLAdminElementDefsView().initEditModal();
        self.initEditValueMappingModal();
    };

    this.initEditValueMappingModal = function() {
        var ROOT_URL     = $('input[name="dl-root-url"]').val();
        var element_name = $('[name=dl-element-name]').val();
        var panel        = $('#dl-edit-value-mapping-modal');

        $('button.dl-edit-value-mapping').on('click', function() {
            var url = ROOT_URL + '/admin/elements/' + element_name +
                '/value-mappings/' + $(this).data('value-mapping-id') + '/edit';
            $.get(url, function(html) {
                panel.find('.modal-body').html(html);
            });
        });
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
