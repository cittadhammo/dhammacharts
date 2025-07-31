## Add a new area

(could be made automatic based on folder structure of content)

- Need an area_name.md file in the root (with title and area frontmatter)
- Add collection to the `_config.yml` file
- Adjust the `areas.yml` file in the `content/_data/` folder

Note: pages are part of the collection and need a frontmatter "type: page" to be displayed
at the top right of an area. (we could consider having a `_pages` collection and layout the pages
in the areas.yml)

Categories of the items are extracted via their path.

## Generating assets

- Every original images in the assets that are listed in the frontmatter `images` of the pages
    should be processed into thumbnail of different size, map moisaic, lightbox depending 
    on the layout chosen.

### searchAndMaps script

This script scans all markdown files in your content folder to find images listed in their frontmatter. For each image, it copies the original and creates three resized thumbnails. If the image is marked as a map, it generates map tiles and records the image’s dimensions in `maps.yml`, updating existing entries or adding new ones.


## Obsidian

THe content folder can be edited via Obsidian. Actually, a vault containing content is stored on another repo that when a commit is pushed it get sync with this one.

## install 

Pineaple Jekyll template for this website

Run: `jekyll serve` no need to `bundle install` or `bundle exec jekyll serve` on this repo.

`jekyll serve --livereload` for live reload.

Change `baseurl` in `_confilg.yml` to: `` if it is the root folder for the website.

# Dhamma Charts

Site for displaying and storing Dhamma Charts and Art. 

Using the [Pinaple](https://github.com/DhammaCharts/pineapple) template

## Old To Do

- Import nice charts in Others
- Fix JoeRucker
- Fix names
- ~~Fix masonry~~
- Add masonry to links
- Update charts page
    - links to image, fullscreen, etc.
- change email image
- Fix high res files, SVG etc.
- Div sources links
