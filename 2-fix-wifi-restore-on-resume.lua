-- 2-fix-wifi-restore-on-resume.lua
--
-- Fix for KOReader issue #15728:
-- https://github.com/koreader/koreader/issues/15728
--
-- PROBLEM
-- NetworkMgr:_abortWifiConnection() unconditionally resets `wifi_was_on`
-- to false every time a Wi-Fi connection *attempt* fails or times out
-- (e.g. no known network in range after being away all day). But
-- `wifi_was_on` is documented elsewhere in the codebase as meaning
-- "the user wants Wi-Fi enabled", and is only supposed to be cleared by
-- a direct user action (Menu / Gesture toggle).
--
-- Because a failed *attempt* silently erases that intent, "Restore Wi-Fi
-- connection on resume" stops trying to reconnect automatically after the
-- very first failure - even later, back home, in full signal. On Kindle,
-- the same code path also calls turnOffWifi(), which kills the Wi-Fi radio
-- at the firmware level (visible as "Airplane mode" turning ON).
--
-- FIX
-- Instead of reimplementing _abortWifiConnection() (which would drift out
-- of sync with upstream changes), wrap the original: let it run exactly
-- as-is, then restore wifi_was_on to what it was before the call if the
-- user's standing intent was "Wi-Fi on".
--
-- INSTALL
-- 1. Create a "patches" folder inside your koreader folder, if it doesn't
--    already exist: koreader/patches/
-- 2. Copy this file into that folder.
-- 3. Restart KOReader.
-- 4. Optional: check it's loaded under
--    Menu > More tools > Patch management.
--
-- NOTE
-- Side effect: KOReader will now retry Wi-Fi on every wake, even during
-- long stretches with no network available, instead of giving up after
-- the first failed attempt. That's the whole point (auto-reconnect once
-- you're back in range), but it does mean a few extra, quick, failed scan
-- attempts (and a little extra battery use) while you're genuinely offline.
--
-- Remove this file once the upstream bug is fixed in a stable release.

local NetworkMgr = require("ui/network/manager")

-- Keep a reference to the original function
local orig_abortWifiConnection = NetworkMgr._abortWifiConnection

function NetworkMgr:_abortWifiConnection()
    -- Save the user's Wi-Fi intent before the original function clears it
    local had_wifi_intent = G_reader_settings:isTrue("wifi_was_on")

    -- Let the original function do all its normal work
    -- (connectivity check teardown, lease_ssid reset, async script pkill,
    -- turnOffWifi() on seamless-toggle platforms, pending_connection reset)
    orig_abortWifiConnection(self)

    -- Restore the user's Wi-Fi intent
    if had_wifi_intent then
        self.wifi_was_on = true
        G_reader_settings:makeTrue("wifi_was_on")
    end
end
