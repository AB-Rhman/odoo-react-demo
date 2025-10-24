{
    'name': 'React Redirect (Entry App)',
    'summary': 'Redirects users to the external React app after install and adds a menu entry.',
    'version': '17.0.1.0.0',
    'category': 'Tools',
    'author': 'AB-Rhman',
    'website': '',
    'license': 'LGPL-3',
    'depends': ['base', 'web'],
    'data': [
        'data/actions.xml',
    ],
    'assets': {
        'web.assets_backend': [
            'odoo_react_redirect/static/src/js/react_systray.js',
            'odoo_react_redirect/static/src/xml/react_systray.xml',
        ],
    },
    'post_init_hook': 'post_init_hook',
    'uninstall_hook': 'uninstall_hook',
    'installable': True,
    'application': False,
}
