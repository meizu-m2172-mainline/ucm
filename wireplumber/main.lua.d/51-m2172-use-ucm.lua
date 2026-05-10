-- Use ALSA UCM for the Meizu M2172 mainline sound card.
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "device.name", "matches", "alsa_card.platform-sound" },
    },
  },
  apply_properties = {
    ["api.alsa.use-acp"] = true,
    ["api.alsa.use-ucm"] = true,
    ["api.acp.auto-profile"] = false,
    ["api.acp.auto-port"] = false,
  },
})

-- Let the smart amplifier see clean start/stop cycles instead of keeping
-- the Qualcomm PCM running forever while the desktop is idle.
table.insert(alsa_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "alsa_output.platform-sound.*" },
    },
  },
  apply_properties = {
    ["node.pause-on-idle"] = true,
    ["session.suspend-timeout-seconds"] = 1,
    ["api.alsa.disable-mmap"] = true,
    ["api.alsa.disable-batch"] = true,
    ["audio.format"] = "S16LE",
  },
})
