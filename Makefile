# Run Jekyll local server with livereload and local config
serve:
	jekyll serve --livereload --config _config.yml,_config_local.yml

# Run the search and mapping script
assets:
	bash ./scripts/searchAndMap.sh

# Generate PDF and PNG by running Python script in the vault directory
images:
	cd vault && python ./scripts/generate_pdf_png.py
