# Classroom Air & Cognition — Supabase backend

This package adapts the supplied HTML prototype for central data collection. It is a pilot implementation, not yet a validated research instrument.

## Package files

- `index.html` — participant interface; retains the questionnaire, PVT and Stroop tasks and submits one session record at completion.
- `dashboard.html` — researcher sign-in, submission overview and CSV downloads.
- `config.js` — public Supabase URL and publishable key placeholders.
- `schema.sql` — database table, indexes, grants and row-level security policies.
- `qr-generator.html` — creates a PNG QR code for the deployed participant URL.

## 1. Create the Supabase project

1. Create a project at https://supabase.com/dashboard.
2. In **Project Settings / Connect / API Keys** (labels may vary), copy the Project URL and the **publishable key** (or legacy `anon` key).
3. Never use a `service_role` or secret key in browser files.
4. Open **SQL Editor**, paste all of `schema.sql`, and run it.
5. In **Authentication settings**, disable public sign-ups. Create individual accounts for authorized researchers from the Supabase dashboard. Do not share one account among the team.
6. Confirm that only approved research-team members have accounts. The dashboard policy grants every authenticated user in this Supabase project read access to all study records.

## 2. Configure the website

Edit `config.js` and replace:
- `https://YOUR_PROJECT_ID.supabase.co` with the actual Project URL
- `YOUR_SUPABASE_PUBLISHABLE_KEY` with the publishable key (or legacy anon key)

The publishable key is intended for browser use, but it is safe only alongside correct Row Level Security policies. Do not put database passwords, secret keys or `service_role` keys in any website file.

## 3. Deploy to a public HTTPS website

One static hosting route is GitHub Pages:

1. Create a GitHub repository for this project. Avoid storing participant data, credentials or exported CSV files in the repository.
2. Upload `index.html`, `config.js`, `dashboard.html`, `qr-generator.html` and (optionally) `.nojekyll`. `schema.sql` and this README may also be included.
3. In repository **Settings → Pages**, choose deployment from the branch and root folder, then save.
4. Wait for GitHub Pages to publish. The public participant URL will usually be `https://YOUR-USERNAME.github.io/YOUR-REPOSITORY/`.
5. Test the participant page using the exact URL on a phone over mobile data, not only your computer.
6. The researcher dashboard URL is the same base URL followed by `dashboard.html`.

GitHub Pages sites are public. Only publish code and configuration placeholders; do not commit participant data. An institution-approved hosting option may be preferable for research governance.

## 4. Generate the QR code

1. Open the deployed `qr-generator.html`.
2. Paste the final participant URL, ending in `/` or `/index.html`.
3. Click **Generate QR code**, then **Download QR PNG**.
4. Scan the saved PNG using a phone that is not signed in to your developer account. Verify it opens the live HTTPS questionnaire.

## 5. Test before real participants

Use clearly fake IDs such as `TEST001`. Complete one pre-class and one post-class session. Verify:
- Both records appear in `dashboard.html` after researcher sign-in.
- Session CSV downloads.
- PVT and Stroop CSVs contain individual trials.
- An unsigned visitor cannot read rows through the database API.
- The site still lets a participant export local JSON if the backend is unavailable.

Delete test rows from Supabase Table Editor before real data collection, or keep them and mark their IDs clearly as test records.

## Important security and research limitations

- This starter allows anonymous browser inserts only; it does not allow anonymous reads, updates or deletes. Since a public client can be scripted, anonymous insert policies can still be abused with fake submissions. Before real recruitment, consider a server-side Supabase Edge Function with rate limiting / bot protection, plus institutional review of the data-management plan.
- The participant ID must be a pseudonymous study code, not a name, roll number, email address or other directly identifying information. Keep any re-identification key separately with restricted access.
- Use the minimum data required and obtain the required ethics approval, consent, retention and deletion procedures before recruitment.
- Client-side reaction times are affected by phone/browser hardware, background activity, touch latency and task implementation. Validate the PVT/Stroop tasks on the intended devices and do not treat this prototype as a validated instrument without protocol review.
- The current database stores one row per assessment, with questionnaire answers and trial arrays in JSON. The dashboard flattens trial arrays into separate PVT and Stroop CSVs. The `id` UUID is stable during the page session; a participant should use the same pseudonymous participant ID for pre- and post-class records.
- The app currently uploads after the tasks are completed. If the participant closes the browser before the final submission, no server record is guaranteed. Ask participants to wait for the success message. For robust offline recovery, a later iteration should add an explicit local retry queue.
