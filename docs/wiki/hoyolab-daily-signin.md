# HoYoLAB daily check-in

A [scheduled automation](scheduled-automations.md) that claims the
HoYoLAB daily check-in reward for one Genshin Impact account.

## Files

| File | Role |
|------|------|
| `.github/workflows/hoyolab-genshin-signin.yml` | Cron trigger (`0 17 * * *` UTC ≈ 00:00 UTC+7) + `workflow_dispatch`, `environment: hoyolab` |
| `scripts/hoyolab-signin.sh` | Sends the POST, interprets the response |

## How it works

The script POSTs to
`https://sg-act-public-api.hoyolab.com/event/sol/sign?lang=en-us` with
body `{"act_id":"e202102251931481"}` and a trimmed header set
(`Content-Type`, `Accept`, `x-rpc-platform`, `x-rpc-signgame`, `Origin`,
`Referer`, `User-Agent`, `Cookie`). Browser `Sec-*` / `TE` / `Priority`
headers are omitted as unnecessary.

Response handling by `retcode`:

| `retcode` | Meaning | Script exit |
|-----------|---------|-------------|
| `0` | Signed in now | 0 |
| `-5003` | Already signed in today | 0 |
| anything else | Failure (e.g. auth expired) | 1 |

The script prints only `http`, `retcode`, and `message` — never the raw
body or the cookie.

## Configuration

Overridable via environment variables, so other games reuse the script
through a new workflow file:

| Variable | Default | Purpose |
|----------|---------|---------|
| `HOYOLAB_COOKIE` | *(required)* | Full browser cookie string |
| `HOYOLAB_ENDPOINT` | Genshin `sol/sign` URL | Sign endpoint |
| `HOYOLAB_ACT_ID` | `e202102251931481` | Event id in the body |
| `HOYOLAB_SIGNGAME` | `hk4e` | `x-rpc-signgame` header |
| `HOYOLAB_DEVICE_ID` | *(unset)* | Adds `x-rpc-device_id` header when set |
| `HOYOLAB_USER_AGENT` | Firefox UA string | `User-Agent` header |

## Secret

`HOYOLAB_COOKIE` — the full `Cookie:` value from a logged-in session on
`act.hoyolab.com` (must contain `ltoken_v2`, `ltuid_v2`, `ltmid_v2`).

Stored in a GitHub Environment named **`hoyolab`** with no protection
rules. Create it at Settings → Environments, add the secret there, and
the workflow's `environment: hoyolab` line picks it up. Do not add
required reviewers or a wait timer — they would block scheduled runs.

## Operations

- **Cookie expiry:** the cookie lasts roughly a few weeks. When the job
  starts failing with a "not logged in" `retcode`, re-copy the cookie
  from the browser and update the secret.
- **If sign-ins are rejected outright:** set a `HOYOLAB_DEVICE_ID` secret
  (the `_HYVUUID` cookie value) and wire it into the workflow `env:`.
- **Scheduled-workflow suspension:** GitHub disables cron workflows after
  60 days with no repository commits.
- **Terms of service:** automating check-in is technically against
  HoYoLAB's ToS; low risk for a single personal account.

## Testing

1. `bash -n scripts/hoyolab-signin.sh` and `shellcheck` (pre-installed on
   `ubuntu-latest`).
2. Local: `HOYOLAB_COOKIE='...' ./scripts/hoyolab-signin.sh` → expect
   `retcode=0` or `-5003`.
3. Actions → run the workflow manually → confirm a green run with a
   masked log.

## Sources

- [`../raw/2026-09-06-hoyolab-daily-signin.md`](../raw/2026-09-06-hoyolab-daily-signin.md)
