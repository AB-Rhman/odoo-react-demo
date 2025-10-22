# -*- coding: utf-8 -*-
{
    'name': 'Odoo React Demo',
    'version': '1.0',
    'category': 'Tools',
    'summary': 'Integrates a React frontend with Odoo',
    'description': 'This module serves a React app built with Vite directly through Odoo.',
    'author': 'Your Name',
    'depends': ['base', 'web', 'website'],
    'data': [
        'views/templates.xml',
    ],
    'assets': {
        'web.assets_frontend': [
            '/odoo-react-demo/static/dist/index.html',
        ],
    },
    'installable': True,
    'application': True,
    'auto_install': False,
}