extends ColorRect

# A single colored ball. Procedural so no art asset is required.

func apply_color(c: Color) -> void:
    color = c
    custom_minimum_size = Vector2(70, 70)
    size = Vector2(70, 70)
    # Soft rounded look via corner radius is not native to ColorRect; emulate
    # by drawing in _draw instead (kept simple: flat circle using a CanvasItem).
    queue_redraw()

func _draw() -> void:
    var r := size.x / 2.0
    draw_circle(Vector2(r, r), r - 2, color)
    draw_circle(Vector2(r * 0.7, r * 0.7), r * 0.3, Color(1, 1, 1, 0.35))
