/** @odoo-module **/
import { registry } from "@web/core/registry";
import { Component } from "@odoo/owl";

class ReactSystray extends Component {
  onClick() {
    window.location.href = "/react/";
  }
}
ReactSystray.template = "odoo_react_redirect.ReactSystray";

registry.category("systray").add("ReactSystray", {
  Component: ReactSystray,
  sequence: 100,
});
