extends Node

# App-wide event bus. Decouples UI from game logic.

signal level_completed(level: int)
signal fish_collected(fish_id: String)
signal coins_changed(amount: int)
signal gems_changed(amount: int)
signal streak_changed(days: int)
signal ad_reward_granted(reward_type: String)
signal ui_muted_changed(muted: bool)
signal request_screen(screen_name: String)
