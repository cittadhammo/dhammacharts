import os
import subprocess
from pathlib import Path
import fitz  # PyMuPDF
import xml.etree.ElementTree as ET
import re

# Desired minimum PNG width in pixels (e.g., A1 square = 7016px, A0 square = 9933px)
MIN_WIDTH_PX = 9933

# Set up paths
base_dir = Path("assets/images")
svg_dir = base_dir / "svg"
pdf_dir = base_dir / "pdf"
png_dir = base_dir / "png"
wrapper_dir = base_dir / "wrapper"

# Create output directories if they don't exist
for folder in [pdf_dir, png_dir, wrapper_dir]:
    folder.mkdir(parents=True, exist_ok=True)

# HTML wrapper template with dynamic page size
HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    @page {{
      size: {width_mm}mm {height_mm}mm;
      margin: 0;
    }}
    html, body {{
      margin: 0;
      padding: 0;
      width: {width_mm}mm;
      height: {height_mm}mm;
      overflow: hidden;
    }}
    object {{
      display: block;
      width: 100%;
      height: 100%;
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
    # 1 SVG unit (px) ≈ 0.2646 mm at 96 DPI
    return units * 0.2646

def get_svg_size(svg_path):
    tree = ET.parse(svg_path)
    root = tree.getroot()
    viewBox = root.attrib.get("viewBox")
    width = root.attrib.get("width")
    height = root.attrib.get("height")

    if viewBox:
        # Allow space or comma-separated values
        parts = re.split(r"[,\s]+", viewBox.strip())
        if len(parts) == 4:
            _, _, w, h = map(float, parts)
        else:
            raise ValueError(f"Invalid viewBox format: {viewBox}")
    elif width and height:
        # Remove any units like 'px' or 'mm'
        w = float(''.join(filter(lambda c: c.isdigit() or c == '.', width)))
        h = float(''.join(filter(lambda c: c.isdigit() or c == '.', height)))
    else:
        # Fallback if neither viewBox nor width/height are present
        w, h = 1000.0, 1000.0

    return w, h

def create_wrapper(svg_path, wrapper_path, width_mm, height_mm):
    html_content = HTML_TEMPLATE.format(
        svg_name=svg_path.name,
        width_mm=width_mm,
        height_mm=height_mm
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
    page = doc.load_page(0)  # First page
    page_width_pt = page.rect.width  # In points (1 pt = 1/72 inch)

    # Calculate zoom factor to meet minimum width
    zoom = min_width_px / page_width_pt
    mat = fitz.Matrix(zoom, zoom)
    pix = page.get_pixmap(matrix=mat)
    pix.save(str(png_output_path))
    doc.close()

# Process each SVG
for svg_path in svg_dir.glob("*.svg"):
    base_name = svg_path.stem
    pdf_path = pdf_dir / f"{base_name}.pdf"
    png_path = png_dir / f"{base_name}.png"
    wrapper_path = wrapper_dir / f"{base_name}.html"

    if pdf_path.exists():
        print(f"Skipping existing PDF: {pdf_path.name}")
        continue

    print(f"Processing: {svg_path.name}")

    try:
        # Extract SVG dimensions
        w_units, h_units = get_svg_size(svg_path)
        w_mm = svg_units_to_mm(w_units)
        h_mm = svg_units_to_mm(h_units)

        # Create wrapper HTML with proper page size
        create_wrapper(svg_path, wrapper_path, w_mm, h_mm)

        # Generate PDF
        generate_pdf(wrapper_path, pdf_path)
        print(f"Generated PDF: {pdf_path}")

        # Convert PDF to PNG with dynamic zoom
        convert_pdf_to_png(pdf_path, png_path, min_width_px=MIN_WIDTH_PX)
        print(f"Generated PNG: {png_path}")

    except Exception as e:
        print(f"Error processing {svg_path.name}: {e}")
