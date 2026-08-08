extends Node

# Generates a SOLVABLE sort level by scrambling a solved state with random
# legal moves (every scramble is reversible, so the result is always solvable).
# Locked tubes are appended and flagged so the player cannot pick from them
# until unlocked (spend a key / rewarded ad).

func make_solved(tube_count: int, colors: int, capacity: int) -> Array:
    var tubes := []
    for c in range(colors):
        var t := []
        for i in range(capacity):
            t.append(c)
        tubes.append(t)
    for i in range(tube_count - colors):
        tubes.append([])
    return tubes

func generate(level_index: int, seed_value: int = -1) -> Dictionary:
    var cfg: Dictionary = GameConfig.chapter_for_level(level_index)
    var rng := RandomNumberGenerator.new()
    if seed_value >= 0:
        rng.seed = seed_value
    else:
        rng.randomize()

    var tubes := make_solved(cfg["tubes"], cfg["colors"], GameConfig.TUBE_CAPACITY)
    var moves: int = cfg["colors"] * GameConfig.TUBE_CAPACITY * 3 + 12
    for m in range(moves):
        var from := rng.randi_range(0, tubes.size() - 1)
        var to := rng.randi_range(0, tubes.size() - 1)
        if from == to:
            continue
        if tubes[from].is_empty():
            continue
        if tubes[to].size() >= GameConfig.TUBE_CAPACITY:
            continue
        var ball = tubes[from].pop_back()
        tubes[to].append(ball)

    if _is_solved(tubes):
        return generate(level_index, rng.randi())

    var locked: Array = []
    for i in range(cfg["locked"]):
        locked.append(tubes.size() - 1 - i)

    return {
        "level": level_index,
        "tubes": tubes,
        "capacity": GameConfig.TUBE_CAPACITY,
        "locked": locked,
        "chapter": cfg["name"]
    }

func _is_solved(tubes: Array) -> bool:
    for t in tubes:
        if t.is_empty():
            continue
        var first = t[0]
        for b in t:
            if b != first:
                return false
    return true
