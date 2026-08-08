extends Node

# Central tunables for Tidy Tank. Change difficulty / economy here.

const VERSION := "0.1.0"
const TARGET_AGE := 13

# Ad pacing (safe for 13+): never spam.
const AD_INTERSTITIAL_EVERY := 4        # show interstitial every N levels won
const AD_INTERSTITIAL_COOLDOWN_SEC := 120

# Free hints per day (extra hints require a rewarded ad).
const FREE_HINTS_PER_DAY := 3

# Core sort rules.
const TUBE_CAPACITY := 4
const SORT_COLORS := [
    "#ff5a5a", "#ffb13d", "#ffe14d", "#5ad15a",
    "#4db8ff", "#9b5aff", "#ff5ad1", "#ffffff"
]

# Economy.
const COINS_PER_LEVEL := 10
const COINS_STREAK_BONUS := 5

# Chapter curve: difficulty ramps; last chapters add locked tubes.
# (Gravity / rainbow variants are extension points — see level_generator.)
const CHAPTERS := [
    {"name":"Chapter 1: The Starter Tank", "tubes":3, "colors":2, "locked":0},
    {"name":"Chapter 2: Coral Reef",        "tubes":4, "colors":3, "locked":0},
    {"name":"Chapter 3: Locked Vault",      "tubes":5, "colors":4, "locked":1},
    {"name":"Chapter 4: Deep Blue",         "tubes":6, "colors":5, "locked":1},
    {"name":"Chapter 5: Rainbow Bay",       "tubes":7, "colors":6, "locked":2}
]
const LEVELS_PER_CHAPTER := 15

func chapter_for_level(level_index: int) -> Dictionary:
    var idx := mini(level_index / LEVELS_PER_CHAPTER, CHAPTERS.size() - 1)
    return CHAPTERS[idx]

func color_to_color(hex: String) -> Color:
    return Color.from_string(hex, Color.WHITE)
