> Going and coming freely, the substance of mind without blockage -- this is prajna.
> 
> -- Huineng

---

This Vault is meant to be a base content for dhammacharts.org website using jekyll template pineapple modified. This Vault is used to store all information and easely updatable via Obsidian or GitHub Web UI. 

- See [[DhammaCharts.org]] page for more information.
- See [[CHECK]] for what needs attention.
## Jekyll and Bash script

- script generate thumbnails small and medium, tiled maps, and lightbox size. Original files can be download on the page itself via links.
- Use: `draft: true` to not publish the item on the website or publish: false

## SVG to PDF/PNG Converter

This script batch-converts SVG files into high-resolution PDF and PNG files using Chromium and PyMuPDF. It wraps each SVG in a margin-adjustable HTML template sized to standard A formats (e.g., A0S, A1V), renders the PDF using headless Chromium, and exports the PNG at 300 DPI with correct pixel dimensions. If no A-format is detected in the filename, it defaults to A1 vertical (`A1V`).

### Dependencies

Install the required Python package:

```bash
pip install pymupdf
sudo apt install chromium-browser
```

### 📄 Filename Convention

Each SVG filename should start with a format code to specify paper size, orientation, background, and margin:

**Format:** `A[0-2]x[B][M]-name.svg` or `2A0x[B][M]-name.svg`

- `A0`, `A1`, `A2`, `2A0`: Paper size
- `V`, `H`, `S`: Orientation — Vertical, Horizontal, or Square
- `B` (optional): Use **black background**
- `M` (optional): Add **1 cm margin** all around

**Examples:**
- `A1V-map.svg` → A1 Vertical, white background, no margin  
- `A0HBM-graph.svg` → A0 Horizontal, black background, with margin  
- `2A0S-design.svg` → 2A0 Square, white background, no margin  
- `A2VBM-sketch.svg` → A2 Vertical, black background, with margin  


## Templates

- Home Page
- Area Page
- Item Page
- Reference Page
- Reference
- Page from item list

## Tree Structure 

### Charts
#### Digital
```dataview
list
from "content/_charts/digital"
```
#### By Others
```dataview
list
from "content/_charts/by-others"
```
#### Hand Made
```dataview
list
from "content/Charts/Hand Made"
```