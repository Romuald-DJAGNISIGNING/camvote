from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw


@dataclass(frozen=True)
class Color:
    r: int
    g: int
    b: int
    a: int = 255

    def lerp(self, other: "Color", t: float) -> "Color":
        return Color(
            r=int(self.r + (other.r - self.r) * t),
            g=int(self.g + (other.g - self.g) * t),
            b=int(self.b + (other.b - self.b) * t),
            a=int(self.a + (other.a - self.a) * t),
        )


BRAND_GRADIENT = (
    Color(0xF7, 0xC8, 0x4A),
    Color(0xF0, 0x6D, 0x3B),
    Color(0x0E, 0x8A, 0x54),
)

INK_SOFT = Color(0x1C, 0x22, 0x2C, 220)
INK_DARK = Color(0x0B, 0x0F, 0x12, 255)
WHITE_SOFT = Color(255, 255, 255, 210)
WHITE_RING = Color(255, 255, 255, 140)
WHITE = Color(255, 255, 255, 255)


def _tri_gradient(size: int, c1: Color, c2: Color, c3: Color) -> Image.Image:
    base = min(size, 256)
    img = Image.new("RGBA", (base, base))
    px = img.load()
    max_idx = base - 1
    denom = max(1, max_idx * 2)
    for y in range(base):
        for x in range(base):
            t = (x + y) / denom
            if t < 0.5:
                color = c1.lerp(c2, t / 0.5)
            else:
                color = c2.lerp(c3, (t - 0.5) / 0.5)
            px[x, y] = (color.r, color.g, color.b, color.a)
    if base != size:
        img = img.resize((size, size), Image.BICUBIC)
    return img


def _draw_logo(base: Image.Image, center: tuple[float, float], r: float) -> None:
    size = int(r * 2)
    gradient = _tri_gradient(size, *BRAND_GRADIENT)

    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.ellipse((0, 0, size, size), fill=255)
    base.paste(gradient, (int(center[0] - r), int(center[1] - r)), mask)

    draw = ImageDraw.Draw(base)
    inner_r = r * 0.72
    draw.ellipse(
        (
            center[0] - inner_r,
            center[1] - inner_r,
            center[0] + inner_r,
            center[1] + inner_r,
        ),
        fill=(WHITE_SOFT.r, WHITE_SOFT.g, WHITE_SOFT.b, WHITE_SOFT.a),
    )

    ring_r = r * 0.56
    ring_w = max(1, int(r * 0.12))
    draw.ellipse(
        (
            center[0] - ring_r,
            center[1] - ring_r,
            center[0] + ring_r,
            center[1] + ring_r,
        ),
        outline=(WHITE_RING.r, WHITE_RING.g, WHITE_RING.b, WHITE_RING.a),
        width=ring_w,
    )

    shield = r * 0.46
    shield_points = [
        (center[0], center[1] - shield),
        (center[0] + shield, center[1] - shield * 0.35),
        (center[0] + shield * 0.76, center[1] + shield * 0.9),
        (center[0], center[1] + shield * 1.2),
        (center[0] - shield * 0.76, center[1] + shield * 0.9),
        (center[0] - shield, center[1] - shield * 0.35),
    ]
    draw.polygon(
        shield_points,
        fill=(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, INK_SOFT.a),
    )

    check = r * 0.22
    check_points = [
        (center[0] - check * 0.9, center[1] + check * 0.1),
        (center[0] - check * 0.2, center[1] + check * 0.75),
        (center[0] + check * 1.1, center[1] - check * 0.55),
    ]
    check_w = max(1, int(check * 0.35))
    draw.line(
        check_points,
        fill=(WHITE.r, WHITE.g, WHITE.b, WHITE.a),
        width=check_w,
        joint="curve",
    )
    cap_r = check_w / 2
    for px, py in (check_points[0], check_points[-1]):
        draw.ellipse(
            (px - cap_r, py - cap_r, px + cap_r, py + cap_r),
            fill=(WHITE.r, WHITE.g, WHITE.b, WHITE.a),
        )


def generate_app_icon(path: Path) -> None:
    size = 1024
    base = Image.new("RGBA", (size, size), (INK_DARK.r, INK_DARK.g, INK_DARK.b, INK_DARK.a))
    r = size * 0.42
    _draw_logo(base, (size / 2, size / 2), r)
    base.save(path, format="PNG", optimize=False, compress_level=6)


def generate_app_logo(path: Path) -> None:
    size = 1024
    base = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    r = size * 0.42
    _draw_logo(base, (size / 2, size / 2), r)
    base.save(path, format="PNG", optimize=False, compress_level=6)


def generate_pattern(path: Path) -> None:
    size = 256
    base = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(base)
    step = 32
    dot_r = 3
    dot = Color(255, 255, 255, 48)
    for y in range(step // 2, size, step):
        for x in range(step // 2, size, step):
            draw.ellipse(
                (x - dot_r, y - dot_r, x + dot_r, y + dot_r),
                fill=(dot.r, dot.g, dot.b, dot.a),
            )
    base.save(path, format="PNG", optimize=False, compress_level=6)


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    icon_path = root / "assets" / "icons" / "app_icon.png"
    logo_path = root / "assets" / "images" / "app_logo.png"
    pattern_path = root / "assets" / "illustrations" / "cam_pattern.png"
    icon_path.parent.mkdir(parents=True, exist_ok=True)
    logo_path.parent.mkdir(parents=True, exist_ok=True)
    pattern_path.parent.mkdir(parents=True, exist_ok=True)
    generate_app_icon(icon_path)
    generate_app_logo(logo_path)
    generate_pattern(pattern_path)
    print(f"Updated {icon_path}")
    print(f"Updated {logo_path}")
    print(f"Updated {pattern_path}")


if __name__ == "__main__":
    main()
