# HoYoLAB daily check-in — source request

Captured 2026-09-06 from a logged-in browser session on
`https://act.hoyolab.com/`. **All credential values below are redacted** —
the live cookie was provided separately and belongs in a repository
secret, never in the repo.

## Request

```
curl 'https://sg-act-public-api.hoyolab.com/event/sol/sign?lang=en-us' \
  -X POST \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:154.0) Gecko/20100101 Firefox/154.0' \
  -H 'Accept: application/json, text/plain, */*' \
  -H 'Content-Type: application/json;charset=utf-8' \
  -H 'x-rpc-signgame: hk4e' \
  -H 'x-rpc-platform: 4' \
  -H 'x-rpc-device_id: <REDACTED>' \
  -H 'Origin: https://act.hoyolab.com' \
  -H 'Referer: https://act.hoyolab.com/' \
  -H 'Cookie: mi18nLang=en-us; ... ltoken_v2=<REDACTED>; ltmid_v2=<REDACTED>; ltuid_v2=<REDACTED>; ...' \
  --data-raw '{"act_id":"e202102251931481"}'
```

The browser also sent `Sec-*`, `TE`, `Priority`, `x-rpc-lrsag`,
`x-rpc-app_version`, `x-rpc-device_name`, `Accept-Encoding`,
`Accept-Language`, `Sec-GPC`, `Connection` headers. These are client
noise and are not required by the endpoint.

## Field notes

- `act_id` `e202102251931481` + `x-rpc-signgame: hk4e` identify the
  Genshin Impact check-in event. Other games use different `act_id` /
  `signgame` values (and Star Rail uses a different `luna/os/sign`
  endpoint).
- Auth is entirely the `Cookie` header. The parts that matter:
  `ltoken_v2`, `ltuid_v2`, `ltmid_v2`. The rest are analytics /
  fingerprint cookies.
- `x-rpc-device_id` mirrors the `_HYVUUID` cookie. The `sol/sign`
  endpoint appears to accept requests without it; keep it available as a
  fallback if sign-ins start being rejected.
- Response is JSON: `retcode 0` on success, `-5003` when already signed
  in today, negative values otherwise. `message` carries the human
  string.
- Cookies expire after roughly a few weeks and must be re-copied from a
  browser session.
