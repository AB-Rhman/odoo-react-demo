# -*- coding: utf-8 -*-
from odoo import http
from odoo.http import request
import os

class ReactDemoController(http.Controller):

    @http.route('/react_demo', type='http', auth='public', website=True)
    def react_demo(self):
        react_index_path = os.path.join(
            request.env['ir.config_parameter'].sudo().get_param('addons_path'),
            'custom/odoo-react-demo/static/dist/index.html'
        )
        with open(react_index_path, 'r') as file:
            return http.Response(file.read(), content_type='text/html')

    @http.route('/react_demo/data', type='json', auth='public')
    def react_demo_data(self):
        return {"message": "Hello from Odoo!"}