/**
 * @constructor
 */
var DLAdminUsersView = function() {

    this.init = function() {
        $('.popover-dismiss').popover({
            trigger: 'focus'
        });
    };

};

var ready = function() {
    if ($('body#dl-admin-users').length) {
        Application.view = new DLAdminUsersView();
        Application.view.init();
    }
};

$(document).ready(ready);
