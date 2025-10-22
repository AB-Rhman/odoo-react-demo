1. Place the `odoo_react_demo` folder into your Odoo addons path.
2. Restart Odoo and update apps list (or run: odoo -u all or refresh Apps in UI).
3. Install the `Odoo React Demo` module from Apps.
4. Build the React app:
   cd odoo_react_demo/static/src
   npm install
   npm run build
   # this writes production files into static/dist
5. Visit http://<odoo-host>/react_demo while logged in.

Development options:
- Run the React dev server (npm run start) and use a dev proxy to forward /react_demo/data to Odoo.
- Or keep the iframe approach and load the dev server URL in the iframe while developing.

Notes:
- When using cookie-based auth, ensure `credentials: 'same-origin'` in fetch calls so the browser sends cookies to Odoo.
- For production, copy the `dist/` contents into `static/dist/` and reference the generated index.html from your template or iframe.