# Odoo Enterprise modules

This folder is reserved for Odoo Enterprise edition modules.

## Important

- Odoo Enterprise modules are proprietary and require a valid Enterprise subscription and license.
- The code is not included in this repository. Obtain it from Odoo under your license terms and place the module folders here.

## How it works

- This path is included in `addons_path` (`/mnt/extra-addons/enterprise`).
- After adding Enterprise modules, restart Odoo so it can discover them:

```bash
docker compose restart odoo
```

- Then install the desired modules from the Apps menu in Odoo.

### Automatic linking and dependencies

- On container start/restart, `prepare_addons.sh` will:
	- Symlink discovered modules into `/mnt/extra-addons/auto` for unified loading.
	- Install Python dependencies declared in `requirements.txt` or `external_dependencies['python']` in the module manifest.
- If a module name exists in multiple sources, priority is: `custom` > `enterprise` > `community`.

## Compliance

Avoid committing licensed Odoo Enterprise code to public repositories. Keep credentials and license material private.
