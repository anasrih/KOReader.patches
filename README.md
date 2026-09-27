# KOReader Patches

A small collection of [user patches](https://koreader.rocks/user_guide/#L2-userpatches) for [KOReader](https://github.com/koreader/koreader).

| Patch | Devices | Description |
| --- | --- | --- |
| [`2-fix-wifi-restore-on-resume.lua`](2-fix-wifi-restore-on-resume.lua) | All (tested on Kindle) | Keeps "Restore Wi-Fi connection on resume" working after a failed connection attempt |
| [`1-kindle-force-enable-screensaver.lua`](1-kindle-force-enable-screensaver.lua) | Kindle only | Forces KOReader to treat the Kindle as screensaver-capable |

## Installation

### From the device (recommended)

Both patches can be installed directly from KOReader with the community stores [Storefront](https://github.com/ultimatejimmy/storefront.koplugin) or [App Store](https://github.com/omer-faruq/appstore.koplugin): open the **Patches** section and search for the patch name. Updates are detected automatically.

### Manually

1. Create a `patches` folder inside your KOReader folder if it doesn't exist:
   - Kindle: `/mnt/us/koreader/patches/`
   - Kobo: `/mnt/onboard/.adds/koreader/patches/`
   - Android: `/sdcard/koreader/patches/`
   - Desktop: `~/.config/koreader/patches/`
2. Download the `.lua` file you want and copy it into that folder. **Keep the file name unchanged**: the number prefix tells KOReader when to load the patch.
3. Restart KOReader.
4. Check that the patch is active in **Menu → More tools → Patch management**.

---

## 🞂 2-fix-wifi-restore-on-resume.lua

Workaround for KOReader issue [#15728](https://github.com/koreader/koreader/issues/15728).

### The problem

With **Restore Wi-Fi connection on resume** enabled, KOReader stops reconnecting automatically after the first failed connection attempt (for example, waking the device somewhere with no known network). Even back home with full signal, Wi-Fi is no longer restored on wake.

The cause: `NetworkMgr:_abortWifiConnection()` resets the `wifi_was_on` setting whenever a connection attempt fails or times out. That setting represents the user's intent ("I want Wi-Fi on") and should only be cleared by an explicit user action. On Kindle, the same code path also turns the Wi-Fi radio off at the firmware level, which shows up as **Airplane mode** being switched on.

### What the patch does

It wraps the original function instead of rewriting it, so it stays in sync with upstream changes: the original teardown runs exactly as before, then the user's Wi-Fi intent is restored if it was set.

### Side effect

KOReader will now try to reconnect on every wake, even during long periods with no network available. This means a few extra quick, failed scans (and slightly higher battery use) while you are genuinely offline.

### When to remove it

Delete the file once the upstream issue is fixed in a stable KOReader release.

---

## 🞂 1-kindle-force-enable-screensaver.lua

**Kindle only.** Overrides the Kindle device definition so that KOReader always reports screensaver support. This makes KOReader's sleep screen options (book cover, image, message…) available on Kindle models where they are otherwise disabled.

It loads early (`1-` prefix) so the device capability is overridden before the UI is built.

---

## Compatibility

Tested on KOReader `v2026.07.01` with `Kindle Paperwhite PW3 and PW5`. Both patches rely on internal KOReader functions, so a future KOReader update may break them. If that happens, please [open an issue](../../issues).

## Troubleshooting

If KOReader fails to start or behaves strangely after installing a patch, remove the patch file from `koreader/patches/`, restart, and check `crash.log` in the KOReader folder. Please include the relevant lines when opening an issue.

## License

[GNU AGPL v3](LICENSE), the same license as KOReader.
