import os
import subprocess
from pathlib import Path
import fitz  # PyMuPDF
import xml.etree.ElementTree as ET
import re

# === OPTIONS ===
ADD_MARGIN_CM = True           # Add 1 cm margin all around
MIN_WIDTH_PX = 9933            # Desired minimum PNG width in pixels

# === Constants for A formats in mm ===
A_SIZES = {
    'A0V': (841, 1189),   # width x height in mm (vertical)
    'A0H': (1189, 841),   # width x height in mm (horizontal)
    'A0S': (841, 841),    # square
    'A1V': (594, 841),
    'A1H': (841, 594),
    'A1S': (594, 594),
    'A2V': (420, 594),
    'A2H': (594, 420),
    'A2S': (420, 420),
}

# === Paths ===
base_dir = Path("assets/images")
svg_dir = base_dir / "svg"
pdf_dir = base_dir / "pdf"
png_dir = base_dir / "png"
wrapper_dir = base_dir / "wrapper"

for folder in [pdf_dir, png_dir, wrapper_dir]:
    folder.mkdir(parents=True, exist_ok=True)

# === HTML template, with object styled to fit area minus margin ===
HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    @page {{
      size: {page_width_mm}mm {page_height_mm}mm;
      margin: 0;
    }}
    html, body {{
      margin: 0;
      padding: 0;
      width: {page_width_mm}mm;
      height: {page_height_mm}mm;
      overflow: hidden;
      background: white;
    }}
    object {{
      display: block;
      width: {svg_width_mm}mm;
      height: {svg_height_mm}mm;
      margin: {margin_top_mm}mm {margin_right_mm}mm {margin_bottom_mm}mm {margin_left_mm}mm;
      border: none;
    }}
  </style>
</head>
<body>
  <object data="../svg/{svg_name}" type="image/svg+xml"></object>
</body>
</html>
"""

def svg_units_to_mm(units):
    return units * 0.2646  # 1 px ≈ 0.2646 mm at 96 DPI

def get_svg_size(svg_path):
    tree = ET.parse(svg_path)
    root = tree.getroot()
    viewBox = root.attrib.get("viewBox")
    width = root.attrib.get("width")
    height = root.attrib.get("height")

    if viewBox:
        parts = re.split(r"[,\s]+", viewBox.strip())
        if len(parts) == 4:
            _, _, w, h = map(float, parts)
        else:
            raise ValueError(f"Invalid viewBox format: {viewBox}")
    elif width and height:
        w = float(''.join(filter(lambda c: c.isdigit() or c == '.', width)))
        h = float(''.join(filter(lambda c: c.isdigit() or c == '.', height)))
    else:
        w, h = 1000.0, 1000.0

    return w, h

def create_wrapper(svg_path, wrapper_path, page_w_mm, page_h_mm,
                   svg_w_mm, svg_h_mm,
                   margin_left_mm, margin_right_mm, margin_top_mm, margin_bottom_mm):
    html_content = HTML_TEMPLATE.format(
        svg_name=svg_path.name,
        page_width_mm=page_w_mm,
        page_height_mm=page_h_mm,
        svg_width_mm=svg_w_mm,
        svg_height_mm=svg_h_mm,
        margin_left_mm=margin_left_mm,
        margin_right_mm=margin_right_mm,
        margin_top_mm=margin_top_mm,
        margin_bottom_mm=margin_bottom_mm,
    )
    with open(wrapper_path, 'w', encoding='utf-8') as f:
        f.write(html_content)

def generate_pdf(wrapper_file, pdf_file):
    subprocess.run([
        "chromium",
        "--headless",
        "--disable-gpu",
        "--no-margins",
        f"--print-to-pdf={pdf_file}",
        f"file://{wrapper_file.resolve()}"
    ], check=True)

def convert_pdf_to_png(pdf_file, png_output_path, min_width_px=MIN_WIDTH_PX):
    doc = fitz.open(str(pdf_file))
    page = doc.load_page(0)
    page_width_pt = page.rect.width

    zoom = min_width_px / page_width_pt
    mat = fitz.Matrix(zoom, zoom)
    pix = page.get_pixmap(matrix=mat)
    pix.save(str(png_output_path))
    doc.close()

def parse_a_format_from_filename(filename):
    # Matches prefixes like A0H, A1V, A2S at start of filename
    match = re.match(r"^(A[0-2][VHS])-", filename)
    if match:
        return match.group(1)
    return None

for svg_path in svg_dir.glob("*.svg"):
    base_name = svg_path.stem
    prefix = parse_a_format_from_filename(base_name)

    pdf_path = pdf_dir / f"{base_name}.pdf"
    png_path = png_dir / f"{base_name}.png"
    wrapper_path = wrapper_dir / f"{base_name}.html"

    if pdf_path.exists():
        print(f"Skipping existing PDF: {pdf_path.name}")
        continue

    print(f"Processing: {svg_path.name}")

    try:
        w_units, h_units = get_svg_size(svg_path)
        w_mm = svg_units_to_mm(w_units)
        h_mm = svg_units_to_mm(h_units)

        margin_cm = 1.0 if ADD_MARGIN_CM else 0.0
        margin_mm = margin_cm * 10

        if prefix and prefix in A_SIZES:
            paper_w, paper_h = A_SIZES[prefix]

            # Reduce available area by margins:
            avail_w = paper_w - 2 * margin_mm
            avail_h = paper_h - 2 * margin_mm

            # Scale SVG to fit inside avail_w x avail_h preserving aspect ratio
            scale = min(avail_w / w_mm, avail_h / h_mm)

            svg_w_scaled = w_mm * scale
            svg_h_scaled = h_mm * scale

            # Center SVG by computing margins
            margin_left = margin_mm + (avail_w - svg_w_scaled) / 2
            margin_right = margin_mm + (avail_w - svg_w_scaled) / 2
            margin_top = margin_mm + (avail_h - svg_h_scaled) / 2
            margin_bottom = margin_mm + (avail_h - svg_h_scaled) / 2

            page_w_mm = paper_w
            page_h_mm = paper_h

            svg_w_mm = svg_w_scaled
            svg_h_mm = svg_h_scaled

        else:
            # Use SVG natural size + optional margin
            page_w_mm = w_mm + 2 * margin_mm
            page_h_mm = h_mm + 2 * margin_mm

            svg_w_mm = w_mm
            svg_h_mm = h_mm

            margin_left = margin_right = margin_top = margin_bottom = margin_mm

        create_wrapper(svg_path, wrapper_path,
                       page_w_mm, page_h_mm,
                       svg_w_mm, svg_h_mm,
                       margin_left, margin_right, margin_top, margin_bottom)

        generate_pdf(wrapper_path, pdf_path)
        print(f"Generated PDF: {pdf_path}")

        convert_pdf_to_png(pdf_path, png_path, min_width_px=MIN_WIDTH_PX)
        print(f"Generated PNG: {png_path}")

    except Exception as e:
        print(f"Error processing {svg_path.name}: {e}")
