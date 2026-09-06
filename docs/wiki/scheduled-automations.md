# Scheduled automations

The pattern for running a recurring task from this repository via GitHub
Actions.

## Shape

One automation = one `.github/workflows/*.yml` file that:

- triggers on `schedule:` (cron) plus `workflow_dispatch:` for manual runs;
- sets `permissions: contents: read` — nothing more is granted to
  `GITHUB_TOKEN`;
- names a GitHub Environment (`environment: <service>`) so its credential
  is isolated from every other workflow;
- declares a `concurrency` group so runs cannot overlap, and a short
  `timeout-minutes`;
- runs a single script from `scripts/`, passing credentials through
  `env:` from a secret.

Non-sensitive configuration (endpoints, IDs, cron expression) lives in
plain text in the workflow file or as script defaults. The **only**
repository secret per automation is the credential it needs.

## Scripts

`scripts/<name>.sh` holds the logic: `set -euo pipefail`, no `set -x`,
never echo the credential. The script reads tunables from environment
variables with sensible defaults so a second, similar automation is a new
workflow file passing different env values rather than a forked script.
Exit non-zero on real failure so GitHub emails the repo admins for
scheduled runs.

## Secrets

- Each service gets its own **GitHub Environment** (`hoyolab`,
  `serviceB`, ...) holding that service's secrets. The job declares
  `environment: <service>`, so a mistake in one workflow cannot read
  another service's credential.
- The environment must have **no protection rules** — no required
  reviewers, no wait timer, no deployment-branch limits. Any of those
  would pause or block every scheduled run. (Bare environment secrets
  work on free private repos; protection rules need GitHub Pro or a
  public repo anyway.)
- Name secrets `SERVICE_PURPOSE` (e.g. `HOYOLAB_COOKIE`) even inside an
  environment — it keeps `env:` blocks self-describing.
- Avoid packing multiple credentials into one JSON secret — you lose
  per-credential rotation and visibility.

## Third-party actions

First-party actions (`actions/checkout`, `actions/setup-go`) are pinned
to a major tag (`@v4`) for readability. Pin any **third-party** action to
a full commit SHA: a tag can be re-pointed at new code by its
maintainer, a commit SHA cannot.

## Instances

- [HoYoLAB daily check-in](hoyolab-daily-signin.md)

## Sources

- [`../raw/2026-09-06-hoyolab-daily-signin.md`](../raw/2026-09-06-hoyolab-daily-signin.md)
