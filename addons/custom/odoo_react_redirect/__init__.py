# -*- coding: utf-8 -*-
# Expose hooks at module root so Odoo can find them by name in __manifest__
from .hooks import post_init_hook, uninstall_hook
# Ensure HTTP routes are loaded
from . import controllers

# Keep module package import (optional, for clarity)
from . import hooks
