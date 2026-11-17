"""Generate the Cloud Dragon Studio app icon matching the ADR visual style."""

import json
import math
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "CloudDragonStudio" / "Resources" / "Assets.xcassets"


def draw_adr_style_icon(size: int = 1024) -> Image.Image:
    grad = Image.new("RGBA", (size, size))
    g_draw = ImageDraw.Draw(grad)
    for y in range(size):
        ratio = y / size
        r = int(150 * (1 - ratio) + 232 * ratio)
        g = int(230 * (1 - ratio) + 212 * ratio)
        b = int(210 * (1 - ratio) + 242 * ratio)
        g_draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    img = grad.copy()
    cx, cy = size / 2, size / 2

    def draw_cloud(bx, by, scale):
        w = int(260 * scale)
        h = int(120 * scale)
        c_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        cd = ImageDraw.Draw(c_img)
        cd.ellipse([bx - w // 2, by - h // 2, bx + w // 2, by + h // 2], fill=(255, 255, 255, 210))
        cd.ellipse([bx - w // 3, by - int(h // 1.6), bx + w // 4, by + h // 3], fill=(255, 255, 255, 230))
        return c_img

    img = Image.alpha_composite(img, draw_cloud(int(size * 0.24), int(size * 0.88), 1.1))
    img = Image.alpha_composite(img, draw_cloud(int(size * 0.76), int(size * 0.90), 1.2))
    img = Image.alpha_composite(img, draw_cloud(int(size * 0.50), int(size * 0.93), 1.4))
    draw = ImageDraw.Draw(img)

    d_center_x = cx
    d_center_y = cy + int(size * 0.07)

    wing_color = (195, 170, 235, 255)
    wing_border = (150, 120, 200, 255)
    w_border_w = int(size * 0.012)
    draw.ellipse(
        [d_center_x - int(size * 0.43), d_center_y - int(size * 0.22), d_center_x - int(size * 0.16), d_center_y + int(size * 0.05)],
        fill=wing_color,
        outline=wing_border,
        width=w_border_w,
    )
    draw.ellipse(
        [d_center_x + int(size * 0.16), d_center_y - int(size * 0.22), d_center_x + int(size * 0.43), d_center_y + int(size * 0.05)],
        fill=wing_color,
        outline=wing_border,
        width=w_border_w,
    )

    horn_color = (255, 195, 150, 255)
    horn_border = (230, 150, 100, 255)
    draw.polygon(
        [(d_center_x - int(size * 0.14), d_center_y - int(size * 0.20)), (d_center_x - int(size * 0.24), d_center_y - int(size * 0.37)), (d_center_x - int(size * 0.06), d_center_y - int(size * 0.24))],
        fill=horn_color,
        outline=horn_border,
    )
    draw.polygon(
        [(d_center_x + int(size * 0.14), d_center_y - int(size * 0.20)), (d_center_x + int(size * 0.24), d_center_y - int(size * 0.37)), (d_center_x + int(size * 0.06), d_center_y - int(size * 0.24))],
        fill=horn_color,
        outline=horn_border,
    )

    crown_y_base = d_center_y - int(size * 0.29)
    crown_pts = [
        (d_center_x - int(size * 0.11), crown_y_base),
        (d_center_x - int(size * 0.13), crown_y_base - int(size * 0.10)),
        (d_center_x - int(size * 0.05), crown_y_base - int(size * 0.05)),
        (d_center_x, crown_y_base - int(size * 0.13)),
        (d_center_x + int(size * 0.05), crown_y_base - int(size * 0.05)),
        (d_center_x + int(size * 0.13), crown_y_base - int(size * 0.10)),
        (d_center_x + int(size * 0.11), crown_y_base),
    ]
    draw.polygon(crown_pts, fill=(255, 222, 89, 255), outline=(230, 170, 40, 255), width=int(size * 0.008))
    gem_r = int(size * 0.020)
    gem_y = crown_y_base - int(size * 0.045)
    draw.ellipse([d_center_x - gem_r, gem_y - gem_r, d_center_x + gem_r, gem_y + gem_r], fill=(255, 110, 150, 255))

    body_color = (115, 218, 185, 255)
    body_border = (65, 158, 130, 255)
    bw = int(size * 0.29)
    bh = int(size * 0.32)
    draw.rounded_rectangle(
        [d_center_x - bw, d_center_y - bh, d_center_x + bw, d_center_y + bh],
        radius=int(size * 0.21),
        fill=body_color,
        outline=body_border,
        width=int(size * 0.014),
    )

    belly_color = (255, 243, 160, 255)
    belly_border = (230, 205, 100, 255)
    belly_w = int(size * 0.19)
    belly_h = int(size * 0.17)
    belly_y = d_center_y + int(size * 0.11)
    draw.ellipse(
        [d_center_x - belly_w, belly_y - belly_h, d_center_x + belly_w, belly_y + belly_h],
        fill=belly_color,
        outline=belly_border,
        width=int(size * 0.008),
    )
    draw.arc(
        [d_center_x - int(belly_w * 0.7), belly_y - int(belly_h * 0.4), d_center_x + int(belly_w * 0.7), belly_y + int(belly_h * 0.2)],
        start=20,
        end=160,
        fill=belly_border,
        width=int(size * 0.007),
    )

    cheek_color = (255, 150, 165, 230)
    ch_w = int(size * 0.055)
    ch_h = int(size * 0.032)
    ch_y = d_center_y - int(size * 0.02)
    draw.ellipse([d_center_x - int(size * 0.20) - ch_w, ch_y - ch_h, d_center_x - int(size * 0.20) + ch_w, ch_y + ch_h], fill=cheek_color)
    draw.ellipse([d_center_x + int(size * 0.20) - ch_w, ch_y - ch_h, d_center_x + int(size * 0.20) + ch_w, ch_y + ch_h], fill=cheek_color)

    eye_r = int(size * 0.052)
    eye_y = d_center_y - int(size * 0.08)
    for ex in [d_center_x - int(size * 0.11), d_center_x + int(size * 0.11)]:
        draw.ellipse([ex - eye_r, eye_y - eye_r, ex + eye_r, eye_y + eye_r], fill=(45, 52, 68, 255))
        draw.ellipse([ex - eye_r + int(size * 0.015), eye_y - eye_r + int(size * 0.012), ex + int(size * 0.012), eye_y + int(size * 0.012)], fill=(255, 255, 255, 255))
        draw.ellipse([ex + int(size * 0.01), eye_y + int(size * 0.015), ex + int(size * 0.028), eye_y + int(size * 0.033)], fill=(255, 255, 255, 220))

    m_y = d_center_y - int(size * 0.01)
    m_color = (50, 60, 75, 255)
    m_w = int(size * 0.009)
    draw.arc([d_center_x - int(size * 0.055), m_y - int(size * 0.02), d_center_x, m_y + int(size * 0.03)], start=10, end=170, fill=m_color, width=m_w)
    draw.arc([d_center_x, m_y - int(size * 0.02), d_center_x + int(size * 0.055), m_y + int(size * 0.03)], start=10, end=170, fill=m_color, width=m_w)

    def draw_star(sx, sy, rad, color):
        points = []
        for i in range(10):
            r = rad if i % 2 == 0 else rad * 0.42
            angle = i * math.pi / 5 - math.pi / 2
            points.append((sx + r * math.cos(angle), sy + r * math.sin(angle)))
        draw.polygon(points, fill=color, outline=(255, 255, 255, 220))

    draw_star(int(size * 0.16), int(size * 0.19), int(size * 0.052), (255, 225, 80, 255))
    draw_star(int(size * 0.84), int(size * 0.21), int(size * 0.044), (255, 215, 70, 255))
    draw_star(int(size * 0.86), int(size * 0.52), int(size * 0.034), (255, 235, 120, 255))
    draw_star(int(size * 0.14), int(size * 0.53), int(size * 0.032), (255, 235, 120, 255))

    rgb = Image.new("RGB", (size, size), (255, 255, 255))
    rgb.paste(img, mask=img.split()[3])
    return rgb


def main():
    ASSETS.mkdir(parents=True, exist_ok=True)
    (ASSETS / "Contents.json").write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2), encoding="utf-8")

    accent = ASSETS / "AccentColor.colorset"
    accent.mkdir(exist_ok=True)
    (accent / "Contents.json").write_text(
        json.dumps(
            {
                "colors": [
                    {
                        "color": {
                            "color-space": "srgb",
                            "components": {"alpha": "1.000", "blue": "0.690", "green": "0.847", "red": "0.447"},
                        },
                        "idiom": "universal",
                    }
                ],
                "info": {"author": "xcode", "version": 1},
            },
            indent=2,
        ),
        encoding="utf-8",
    )

    iconset = ASSETS / "AppIcon.appiconset"
    iconset.mkdir(exist_ok=True)
    icon_img = draw_adr_style_icon(1024)
    icon_img.save(iconset / "AppIcon.png", format="PNG")
    (iconset / "Contents.json").write_text(
        json.dumps(
            {
                "images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
                "info": {"author": "xcode", "version": 1},
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    print(f"Generated ADR-matched assets in {ASSETS}")


if __name__ == "__main__":
    main()
