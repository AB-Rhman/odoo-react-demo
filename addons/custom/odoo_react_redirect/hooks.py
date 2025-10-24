# -*- coding: utf-8 -*-
from odoo import api


def post_init_hook(env):
    """After installation, set ALL internal users' home action to open the React app.

    Internal users are members of base.group_user. This can be changed later by each user
    in Preferences > Home Action.
    """
    action = env.ref('odoo_react_redirect.action_open_react', raise_if_not_found=False)
    if not action:
        return

    internal_group = env.ref('base.group_user', raise_if_not_found=False)
    if not internal_group:
        return

    # Only set for users who don't already have a custom Home Action
    users = env['res.users'].sudo().search([
        ('groups_id', 'in', [internal_group.id]),
        ('active', '=', True),
        ('action_id', '=', False),
    ])
    if users:
        users.write({'action_id': action.id})


def uninstall_hook(env):
    """On uninstall, clear the home action from users that were pointing to this module's action."""
    action = env.ref('odoo_react_redirect.action_open_react', raise_if_not_found=False)
    if not action:
        return
    users = env['res.users'].sudo().search([('action_id', '=', action.id)])
    if users:
        users.write({'action_id': False})
