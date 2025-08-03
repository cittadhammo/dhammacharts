import os
import subprocess
from pathlib import Path

# Set up paths
base_dir = Path("assets/images")
svg_dir = base_dir / "svg"
pdf_dir = base_dir / "pdf"
png_dir = base_dir / "png"
wrapper_dir = base_dir / "wrapper"

# Create output directories if they don't exist
for folder in [pdf_dir, png_dir, wrapper_dir]:
    folder.mkdir(parents=True, exist_ok=True)

# Template for the HTML wrapper
HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    @page {{
      size: 1000mm 1000mm;
      margin: 0;
    }}
    html, body {{
      margin: 0;
      padding: 0;
      width: 1000mm;
      height: 1000mm;
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

def create_wrapper(svg_path, wrapper_path):
    html_content = HTML_TEMPLATE.format(svg_name=svg_path.name)
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

def convert_pdf_to_png(pdf_file, png_output_base):
    subprocess.run([
        "pdftoppm",
        "-png",
        "-singlefile",
        str(pdf_file),
        str(png_output_base)
    ], check=True)

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

    # Create wrapper HTML
    create_wrapper(svg_path, wrapper_path)

    # Generate PDF
    try:
        generate_pdf(wrapper_path, pdf_path)
        print(f"Generated PDF: {pdf_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error generating PDF for {svg_path.name}: {e}")
        continue

    # Convert PDF to PNG
    try:
        convert_pdf_to_png(pdf_path, png_path.with_suffix(""))
        print(f"Generated PNG: {png_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error converting to PNG for {svg_path.name}: {e}")
