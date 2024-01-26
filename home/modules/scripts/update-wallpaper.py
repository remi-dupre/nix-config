"""
Download wallpaper from Bing, crop image and add legend to it.

Usage:
    update-wallpaper <width> <height> <font-file> <dest-file>
"""
import sys
import time
import urllib.request

import yaml
from PIL import Image, ImageDraw, ImageFont


TMP_FILE_PATH = "/tmp/wallpaper.png"
BASE_URL = "https://www.bing.com"
META_URL = f"{BASE_URL}/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=fr-FR"


def wait_for_internet():
    while True:
        try:
            with urllib.request.urlopen(BASE_URL, timeout=1):
                break
        except urllib.request.URLError:
            print("Waiting for internet...", file=sys.stderr)
            time.sleep(1)


def add_caption(img: Image, text: str, font_path: str) -> Image:
    tmp = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(tmp)
    font = ImageFont.truetype(font=font_path, size=24)

    text_params = {
        "xy": tuple(c - 8 for c in img.size),
        "text": text,
        "anchor": "rs",
        "font": font,
        "spacing": 20,
    }

    text_bbox = draw.textbbox(**text_params)

    draw.rectangle(
        (
            text_bbox[0] - 8,
            text_bbox[1] - 8,
            text_bbox[2] + 8,
            text_bbox[3] + 8,
        ),
        fill=(0, 0, 0, 150),
    )

    draw.text(**text_params)
    return Image.alpha_composite(img, tmp)


def main(screen_width: int, screen_height: int, font_path: str, dest: str):
    wait_for_internet()

    # Get the image
    with urllib.request.urlopen(META_URL) as data:
        data = yaml.safe_load(data)

    url = BASE_URL + data["images"][0]["url"]
    urllib.request.urlretrieve(url, TMP_FILE_PATH)

    # Add legend
    img = Image.open(TMP_FILE_PATH)
    print(f"Image size: {img.width}x{img.height}", file=sys.stderr)
    img = img.convert("RGBA")
    img = img.resize((screen_width, screen_height), Image.LANCZOS)
    img = add_caption(img, data["images"][0]["copyright"], font_path)
    img.save(dest)


if __name__ == "__main__":
    width, height, font_path, dest = sys.argv[1:]
    width = int(width)
    height = int(height)
    main(width, height, font_path, dest)
