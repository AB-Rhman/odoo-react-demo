# -*- coding: utf-8 -*-
from odoo import http
from odoo.http import request

class ReactRedirectController(http.Controller):
    @http.route('/react_redirect/disable', type='http', auth='user', website=False)
    def disable_redirect(self, **kwargs):
        # Clear the current user's home action to avoid redirect loops
        request.env.user.sudo().write({'action_id': False})
        return request.redirect('/web')

    @http.route('/react_redirect/enable', type='http', auth='user', website=False)
    def enable_redirect(self, **kwargs):
        action = request.env.ref('odoo_react_redirect.action_open_react', raise_if_not_found=False)
        if action:
            request.env.user.sudo().write({'action_id': action.id})
        return request.redirect('/react/')
