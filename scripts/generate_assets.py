"""Generate 100% original pastel Cloud Dragon Studio app icon and color assets."""

import json
import math
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "CloudDragonStudio" / "Resources" / "Assets.xcassets"


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3)) + (255,)


def draw_app_icon(size: int = 1024) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    px = img.load()

    # Soft sky pastel gradient: sky mint -> lavender -> warm butter glow
    top = (198, 240, 255)
    mid = (224, 214, 255)
    bot = (255, 244, 200)
    for y in range(size):
        t = y / (size - 1)
        if t < 0.55:
            col = lerp_color(top, mid, t / 0.55)
        else:
            col = lerp_color(mid, bot, (t - 0.55) / 0.45)
        for x in range(size):
            px[x, y] = col

    draw = ImageDraw.Draw(img, "RGBA")

    # Background fluffy clouds
    clouds = [
        (180, 770, 175),
        (360, 810, 205),
        (580, 825, 210),
        (800, 785, 185),
        (220, 230, 100),
        (820, 220, 110),
    ]
    for cx, cy, r in clouds:
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(255, 255, 255, 235))
        draw.ellipse((cx - r * 0.7, cy - r * 1.15, cx + r * 0.65, cy + r * 0.3), fill=(255, 255, 255, 225))

    # Baby cloud dragon wings (lavender)
    left_wing = [(310, 470), (145, 345), (175, 495), (275, 560)]
    right_wing = [(714, 470), (879, 345), (849, 495), (749, 560)]
    draw.polygon(left_wing, fill=(208, 188, 255, 255))
    draw.polygon(right_wing, fill=(208, 188, 255, 255))

    # Dragon body (mint pastel oval)
    draw.ellipse((320, 445, 704, 800), fill=(154, 231, 203, 255))
    # Belly (butter yellow)
    draw.ellipse((395, 535, 629, 775), fill=(255, 243, 176, 255))

    # Cute curved horns (butter gold)
    draw.polygon([(385, 295), (330, 165), (435, 255)], fill=(255, 222, 125, 255))
    draw.polygon([(639, 295), (694, 165), (589, 255)], fill=(255, 222, 125, 255))

    # Dragon head (mint pastel)
    draw.ellipse((325, 235, 699, 560), fill=(168, 238, 212, 255))
    # Snout highlight
    draw.ellipse((395, 390, 629, 540), fill=(195, 247, 226, 255))

    # Cute cheeks
    draw.ellipse((365, 410, 430, 462), fill=(255, 176, 192, 185))
    draw.ellipse((594, 410, 659, 462), fill=(255, 176, 192, 185))

    # Sparkly friendly eyes
    for ex in (430, 594):
        draw.ellipse((ex - 34, 340, ex + 34, 412), fill=(48, 52, 78, 255))
        draw.ellipse((ex - 16, 352, ex + 6, 374), fill=(255, 255, 255, 255))
        draw.ellipse((ex + 8, 384, ex + 20, 396), fill=(255, 255, 255, 220))

    # Gentle smile
    draw.arc((465, 430, 559, 495), start=15, end=165, fill=(65, 72, 102, 255), width=10)

    # Sparkle stars
    for sx, sy, sr, scol in [
        (512, 130, 34, (255, 248, 185, 255)),
        (195, 210, 22, (255, 255, 255, 240)),
        (835, 210, 24, (255, 245, 195, 245)),
    ]:
        pts = []
        for i in range(8):
            angle = i * math.pi / 4.0
            rad = sr if i % 2 == 0 else sr * 0.38
            pts.append((sx + math.cos(angle) * rad, sy + math.sin(angle) * rad))
        draw.polygon(pts, fill=scol)

    # Flatten to opaque RGB for App Store icon rules
    rgb = Image.new("RGB", (size, size), (255, 255, 255))
    rgb.paste(img, mask=img.split()[3])
    return rgb


def main():
    ASSETS.mkdir(parents=True, exist_ok=True)
    (ASSETS / "Contents.json").write_text(
        json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2),
        encoding="utf-8",
    )

    accent = ASSETS / "AccentColor.colorset"
    accent.mkdir(exist_ok=True)
    (accent / "Contents.json").write_text(
        json.dumps(
            {
                "colors": [
                    {
                        "color": {
                            "color-space": "srgb",
                            "components": {"alpha": "1.000", "blue": "0.910", "green": "0.580", "red": "0.520"},
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
    icon_img = draw_app_icon(1024)
    icon_img.save(iconset / "AppIcon.png", format="PNG")
    (iconset / "Contents.json").write_text(
        json.dumps(
            {
                "images": [
                    {
                        "filename": "AppIcon.png",
                        "idiom": "universal",
                        "platform": "ios",
                        "size": "1024x1024",
                    }
                ],
                "info": {"author": "xcode", "version": 1},
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    print(f"Generated assets in {ASSETS}")


if __name__ == "__main__":
    main()
