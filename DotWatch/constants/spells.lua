-- constants/spells.lua
DOTS_BY_NAME = {
  ["Siphon Life"]            = 1,
  ["Corruption"]             = 2,

  -- Curses (slot 3). Include both "Curse of X" and "X" aliases.
  ["Curse of Agony"]         = 3, ["Agony"]       = 3,
  ["Curse of Weakness"]      = 3, ["Weakness"]    = 3,
  ["Curse of the Elements"]  = 3, ["Elements"]    = 3,
  ["Curse of Recklessness"]  = 3, ["Recklessness"]= 3,
  ["Curse of Shadow"]        = 3, ["Shadow"]      = 3,
  ["Curse of Tongues"]       = 3, ["Tongues"]     = 3,
  ["Curse of Doom"]          = 3, ["Doom"]        = 3,
  ["Curse of Exhaustion"]    = 3, ["Exhaustion"]  = 3,

  ["Immolate"]               = 4,
}

DotColorsByName = {
  ["Siphon Life"]            = { r=0.6, g=1.0, b=0.6 },
  ["Corruption"]             = { r=0.8, g=0.6, b=0.9 },

  ["Curse of Agony"]         = { r=0.9, g=0.5, b=0.5 }, ["Agony"]        = { r=0.9, g=0.5, b=0.5 },
  ["Curse of Weakness"]      = { r=0.5, g=0.6, b=0.9 }, ["Weakness"]     = { r=0.5, g=0.6, b=0.9 },
  ["Curse of the Elements"]  = { r=0.5, g=0.9, b=0.9 }, ["Elements"]     = { r=0.5, g=0.9, b=0.9 },
  ["Curse of Recklessness"]  = { r=1.0, g=0.9, b=0.5 }, ["Recklessness"] = { r=1.0, g=0.9, b=0.5 },
  ["Curse of Shadow"]        = { r=0.6, g=0.6, b=1.0 }, ["Shadow"]       = { r=0.6, g=0.6, b=1.0 },
  ["Curse of Tongues"]       = { r=1.0, g=0.6, b=1.0 }, ["Tongues"]      = { r=1.0, g=0.6, b=1.0 },
  ["Curse of Doom"]          = { r=0.8, g=0.4, b=0.4 }, ["Doom"]         = { r=0.8, g=0.4, b=0.4 },
  ["Curse of Exhaustion"]    = { r=0.4, g=0.9, b=0.4 }, ["Exhaustion"]   = { r=0.4, g=0.9, b=0.4 },

  ["Immolate"]               = { r=1.0, g=0.8, b=0.5 },
  ["default"]                = { r=0.8, g=0.8, b=0.8 },
}