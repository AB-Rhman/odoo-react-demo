# Community modules

This folder is for community/open‑source Odoo modules (e.g., OCA and other vendors).

## How it works

- This path is included in `addons_path` (`/mnt/extra-addons/community`).
- Place module folders here. Odoo will detect them after a restart:

```bash
docker compose restart odoo
```

## Tips

- Make sure the module is compatible with your Odoo version.
- Python dependencies are installed automatically on restart from a module's `requirements.txt` or `external_dependencies['python']` in its manifest.
- Keep module names unique across `community`, `custom`, and `enterprise` paths.
- If the same module name exists in multiple sources, the load priority is: `custom` > `enterprise` > `community`.
