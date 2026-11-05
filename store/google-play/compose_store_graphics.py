"""Composes Google Play graphics from raw app screenshots.

Usage (Pillow required):
  python3 compose_store_graphics.py <raw_screens_dir> <lang> <out_dir>

Raw screens come from integration_test/store_screenshots_test.dart.
Outputs 1080x1920 phone screenshots, a 1024x500 feature graphic and the
512x512 icon. Everything runs locally.
"""

import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
FONTS = HERE / "fonts"
ICON = HERE.parents[1] / "assets/app_icon/app_icon.png"

BG = (11, 12, 16)
SURFACE = (22, 24, 31)
TEXT = (226, 226, 236)
MUTED = (133, 149, 136)
MINT, CYAN, AMBER = (45, 227, 142), (0, 210, 255), (249, 202, 36)
LAVENDER, ROSE, ORANGE, PINK = (162, 155, 254), (255, 118, 117), (255, 159, 67), (255, 77, 148)
PALETTE = [MINT, CYAN, AMBER, LAVENDER, ROSE, ORANGE, PINK]

# (file stem, accent, headline, subline) per language.
SLIDES = {
    "vi": [
        ("01-matrix", MINT, "Mỗi thói quen\nlà một viên gạch", "Xếp gạch pixel mỗi ngày, nhìn là thấy tiến bộ"),
        ("04-templates", CYAN, "Gõ tên là có\nmẫu sẵn", "Chạm một cái, điền đủ biểu tượng, màu, lịch, mục tiêu"),
        ("02-tasks", AMBER, "Trang, phút, lần, ly\nhay chỉ đánh dấu", "Lịch linh hoạt và nhắc nhở lặp lại thông minh"),
        ("03-stats", LAVENDER, "Lên cấp,\ngiữ chuỗi", "XP, huy hiệu và thống kê tuần tháng"),
        ("05-themes", PINK, "6 giao diện gạch\nđể mở khóa", "Mỗi bộ có hiệu ứng và âm thanh arcade riêng"),
    ],
    "en": [
        ("01-matrix", MINT, "Every habit\ndrops a brick", "Stack pixel bricks daily and watch progress grow"),
        ("04-templates", CYAN, "Type a name,\nget a template", "One tap fills icon, color, schedule and goal"),
        ("02-tasks", AMBER, "Pages, minutes, times\nor a simple check", "Flexible schedules and smart repeat reminders"),
        ("03-stats", LAVENDER, "Level up,\nkeep the streak", "XP, badges and weekly / monthly stats"),
        ("05-themes", PINK, "6 brick themes\nto unlock", "Each with its own effects and arcade sounds"),
    ],
}

FEATURE = {
    "vi": ("Habit Tracker - Pixel", "Xây thói quen, từng viên gạch pixel"),
    "en": ("Habit Tracker - Pixel", "Build habits one pixel brick at a time"),
}


def font(name: str, size: int, weight: int = 700) -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(str(FONTS / name), size)
    try:
        f.set_variation_by_axes([weight])
    except (OSError, ValueError):
        pass
    return f


def pixel_backdrop(size, accent, seed, cell=36, density=0.10):
    """Dark background with a faint grid and scattered glowing bricks."""
    w, h = size
    img = Image.new("RGB", size, BG)
    d = ImageDraw.Draw(img)
    for x in range(0, w, cell):
        d.line([(x, 0), (x, h)], fill=(20, 22, 30))
    for y in range(0, h, cell):
        d.line([(0, y), (w, y)], fill=(20, 22, 30))
    rnd = random.Random(seed)
    glow = Image.new("RGB", size, (0, 0, 0))
    g = ImageDraw.Draw(glow)
    for x in range(0, w, cell):
        for y in range(0, h, cell):
            if rnd.random() < density:
                c = accent if rnd.random() < 0.5 else rnd.choice(PALETTE)
                dim = rnd.uniform(0.18, 0.45)
                col = tuple(int(v * dim) for v in c)
                g.rounded_rectangle([x + 4, y + 4, x + cell - 4, y + cell - 4], 6, fill=col)
    return Image.composite(glow, img, glow.convert("L").point(lambda v: 255 if v else 0)), d


def vertical_fade(size, top_alpha, bottom_alpha):
    w, h = size
    mask = Image.new("L", (1, h))
    for y in range(h):
        t = y / max(h - 1, 1)
        mask.putpixel((0, y), int(top_alpha + (bottom_alpha - top_alpha) * t))
    return mask.resize(size)


def phone(screen: Image.Image, width: int, accent) -> Image.Image:
    """Screenshot in a rounded device frame with a neon glow."""
    ratio = screen.height / screen.width
    sw = width
    sh = int(sw * ratio)
    screen = screen.convert("RGB").resize((sw, sh), Image.LANCZOS)
    bezel, radius = 14, 64
    fw, fh = sw + bezel * 2, sh + bezel * 2
    pad = 60
    out = Image.new("RGBA", (fw + pad * 2, fh + pad * 2), (0, 0, 0, 0))
    glow = Image.new("RGBA", out.size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle(
        [pad, pad, pad + fw, pad + fh], radius + bezel, fill=accent + (150,)
    )
    out.alpha_composite(glow.filter(ImageFilter.GaussianBlur(34)))
    frame = ImageDraw.Draw(out)
    frame.rounded_rectangle([pad, pad, pad + fw, pad + fh], radius + bezel, fill=(28, 30, 38, 255))
    frame.rounded_rectangle(
        [pad, pad, pad + fw, pad + fh], radius + bezel, outline=accent + (200,), width=3
    )
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw, sh], radius, fill=255)
    out.paste(screen, (pad + bezel, pad + bezel), mask)
    return out


def draw_centered(d, text, y, fnt, fill, width, spacing=10):
    for line in text.split("\n"):
        box = d.textbbox((0, 0), line, font=fnt)
        d.text(((width - (box[2] - box[0])) / 2 - box[0], y), line, font=fnt, fill=fill)
        y += box[3] - box[1] + spacing
    return y


def screenshot_slide(raw: Path, accent, headline, subline, seed) -> Image.Image:
    W, H = 1080, 1920
    img, _ = pixel_backdrop((W, H), accent, seed)
    shade = Image.new("RGB", (W, H), BG)
    img = Image.composite(shade, img, vertical_fade((W, H), 235, 120))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([W / 2 - 60, 92, W / 2 + 60, 104], 6, fill=accent)
    y = draw_centered(d, headline, 140, font("SpaceGrotesk.ttf", 92), TEXT, W, spacing=18)
    draw_centered(d, subline, y + 22, font("PlusJakartaSans.ttf", 40, 500), MUTED, W)
    device = phone(Image.open(raw), 760, accent)
    top = 560
    img.paste(device, ((W - device.width) // 2, top - 60), device)
    # Fade the device out at the bottom edge so tall screens crop cleanly.
    fade = Image.new("RGB", (W, 260), BG)
    img.paste(fade, (0, H - 260), vertical_fade((W, 260), 0, 255))
    return img


def feature_graphic(raws, lang) -> Image.Image:
    W, H = 1024, 500
    img, _ = pixel_backdrop((W, H), MINT, 7, cell=28, density=0.16)
    shade = Image.new("RGB", (W, H), BG)
    left = Image.new("L", (W, H))
    for x in range(W):
        a = 245 if x < 470 else max(0, int(245 - (x - 470) * 0.9))
        ImageDraw.Draw(left).line([(x, 0), (x, H)], fill=a)
    img = Image.composite(shade, img, left)
    icon = Image.open(ICON).convert("RGBA").resize((120, 120), Image.LANCZOS)
    m = Image.new("L", icon.size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, 120, 120], 28, fill=255)
    img.paste(icon, (56, 60), m)
    d = ImageDraw.Draw(img)
    title, tag = FEATURE[lang]
    d.text((56, 206), "Habit Tracker", font=font("SpaceGrotesk.ttf", 62), fill=TEXT)
    d.text((56, 276), "PIXEL", font=font("SpaceGrotesk.ttf", 62), fill=MINT)
    d.text((56, 366), tag, font=font("PlusJakartaSans.ttf", 26, 600), fill=MUTED)
    for i, c in enumerate(PALETTE):
        d.rounded_rectangle([56 + i * 30, 420, 80 + i * 30, 444], 5, fill=c)
    for raw, x, y, accent in [(raws[1], 560, 70, CYAN), (raws[0], 740, 20, MINT)]:
        dev = phone(Image.open(raw), 210, accent)
        img.paste(dev, (x, y), dev)
    return img


def main():
    raw_dir, lang, out_dir = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3])
    (out_dir / lang).mkdir(parents=True, exist_ok=True)
    for i, (stem, accent, head, sub) in enumerate(SLIDES[lang], 1):
        slide = screenshot_slide(raw_dir / f"{stem}.png", accent, head, sub, i)
        slide.save(out_dir / lang / f"phone-{i:02d}.png", optimize=True)
    raws = [raw_dir / "01-matrix.png", raw_dir / "04-templates.png"]
    feature_graphic(raws, lang).save(out_dir / f"feature-graphic-{lang}.png", optimize=True)
    icon = Image.open(ICON).convert("RGBA").resize((512, 512), Image.LANCZOS)
    flat = Image.new("RGB", icon.size, BG)
    flat.paste(icon, (0, 0), icon)
    flat.save(out_dir / "icon-512.png", optimize=True)
    print("done", out_dir)


if __name__ == "__main__":
    main()
