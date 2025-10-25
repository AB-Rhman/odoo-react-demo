# Custom Odoo modules

This folder is for your organization's custom Odoo modules.

## How it works

- The Odoo container includes this path in its `addons_path` (`/mnt/extra-addons/custom`).
- Any valid module you put here will be detected automatically the next time you restart the Odoo service/container.
- Each module must be its own folder containing at least a `__manifest__.py` file (plus your `models/`, `views/`, etc.).
 - On container start/restart, a helper script (`prepare_addons.sh`) will:
	 - Symlink all discovered modules into `/mnt/extra-addons/auto` so Odoo can load them from one place.
	 - Install Python dependencies declared by modules (from `requirements.txt` or `external_dependencies['python']` in the manifest) automatically.
	 - Resolve duplicate module names by priority: `custom` > `enterprise` > `community`.

## Usage

1) Add or update your custom module folder(s) under this directory.
2) Restart Odoo to trigger auto-discovery:

```bash
docker compose restart odoo
```

3) In Odoo, enable Developer Mode and install/upgrade your module from Apps.

## Notes

- Keep module names unique across all addon paths (`custom`, `enterprise`, `community`).
- Python dependencies are installed automatically on restart. If a package needs OS-level libraries (e.g., build tools, headers), extend the image to include them.
