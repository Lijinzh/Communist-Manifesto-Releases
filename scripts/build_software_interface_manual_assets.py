#!/usr/bin/env python3
"""Build deterministic overview and crop images for the software UI manual."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "docs" / "software-interface-manual" / "assets"
MAIN_SOURCE = ROOT / "docs" / "assets" / "user-guide" / "autoclipboard-main.webp"


MAIN_REGIONS = {
    "main-device-status.webp": (4, 4, 890, 222),
    "main-editor-typeless.webp": (4, 220, 890, 616),
    "main-agent-dashboard.webp": (886, 4, 1176, 616),
}

DEVICE_REGIONS = {
    "device-top-status.webp": (2, 2, 1440, 80),
    "device-imu-preview.webp": (2, 80, 376, 850),
    "device-profile-and-quick-launch.webp": (378, 80, 1440, 405),
    "device-appearance-and-power.webp": (378, 402, 1084, 850),
    "device-maintenance.webp": (1086, 402, 1440, 850),
}


def _font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = (
        Path("C:/Windows/Fonts/seguisb.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf"),
    )
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


def _save_webp(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(path, "WEBP", quality=92, method=6)


def _crop_all(source: Image.Image, regions: dict[str, tuple[int, int, int, int]]) -> None:
    for filename, box in regions.items():
        _save_webp(source.crop(box), ASSET_DIR / filename)


def _numbered_overview(
    source: Image.Image,
    regions: list[tuple[int, tuple[int, int, int, int]]],
) -> Image.Image:
    image = source.convert("RGBA")
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    font = _font(23)
    colors = (
        (66, 211, 255, 255),
        (125, 242, 164, 255),
        (255, 178, 73, 255),
        (255, 103, 154, 255),
        (180, 139, 255, 255),
    )
    for index, box in regions:
        color = colors[(index - 1) % len(colors)]
        x1, y1, x2, y2 = box
        draw.rounded_rectangle(box, radius=12, outline=color, width=4)
        cx = min(x2 - 22, x1 + 25)
        cy = min(y2 - 22, y1 + 25)
        draw.ellipse((cx - 18, cy - 18, cx + 18, cy + 18), fill=(12, 17, 28, 235), outline=color, width=3)
        label = str(index)
        text_box = draw.textbbox((0, 0), label, font=font)
        text_width = text_box[2] - text_box[0]
        text_height = text_box[3] - text_box[1]
        draw.text(
            (cx - text_width / 2, cy - text_height / 2 - 2),
            label,
            font=font,
            fill=(255, 255, 255, 255),
        )
    return Image.alpha_composite(image, overlay).convert("RGB")


def build(device_source: Path) -> None:
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    main = Image.open(MAIN_SOURCE).convert("RGB")
    device = Image.open(device_source).convert("RGB")

    if main.size != (1180, 620):
        raise ValueError(f"unexpected main screenshot size: {main.size}")
    if device.size != (1442, 852):
        raise ValueError(f"unexpected device screenshot size: {device.size}")

    _save_webp(main, ASSET_DIR / "main-window-full.webp")
    _save_webp(device, ASSET_DIR / "device-settings-full.webp")
    _save_webp(device, ROOT / "docs" / "assets" / "user-guide" / "autoclipboard-settings.webp")
    _crop_all(main, MAIN_REGIONS)
    _crop_all(device, DEVICE_REGIONS)

    main_overview = _numbered_overview(
        main,
        [
            (1, (5, 5, 890, 222)),
            (2, (5, 220, 890, 615)),
            (3, (886, 5, 1175, 615)),
        ],
    )
    _save_webp(main_overview, ASSET_DIR / "main-window-numbered.webp")

    device_overview = _numbered_overview(
        device,
        [
            (1, (3, 3, 1438, 78)),
            (2, (3, 82, 374, 849)),
            (3, (382, 82, 1438, 402)),
            (4, (382, 406, 1080, 849)),
            (5, (1090, 406, 1438, 849)),
        ],
    )
    _save_webp(device_overview, ASSET_DIR / "device-settings-numbered.webp")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--device-source",
        type=Path,
        default=ASSET_DIR / "device-settings-full.webp",
        help="real device-settings screenshot; defaults to the committed full image",
    )
    args = parser.parse_args()
    build(args.device_source.resolve())
    print(f"updated {ASSET_DIR.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
