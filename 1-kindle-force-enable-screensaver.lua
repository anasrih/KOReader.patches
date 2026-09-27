-- 1-kindle-force-enable-screensaver.lua
--
-- This overrides the device configuration for Kindles to always indicate it
-- supports a screensaver.
-- 
-- To use, create a patches folder in the KOReader directory, place the patch
-- there, and restart KOReader.
--
-- For example, on a Kindle PW4 it should be placed here:
-- /mnt/us/koreader/patches/1-kindle-force-enable-screensaver.lua

local Device = require("device/kindle/device")

Device.supportsScreensaver = function(self) return true end