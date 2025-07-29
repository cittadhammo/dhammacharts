> Going and coming freely, the substance of mind without blockage -- this is prajna.
> 
> -- Huineng

---

This Vault is meant to be a base content for dhammacharts.org website using jekyll template pineapple modified. This Vault is used to store all information and easely updatable via Obsidian or GitHub Web UI. 

- See [[DhammaCharts.org]] page for more information.
- See [[CHECK]] for what needs attention.
## Jekyll and Bash script

- script generate thumbnails small and medium, tiled maps, and lightbox size. Original files can be download on the page itself via links.
- GitHub Action is used to create the jekyll website from the other repo (or branch) containing content and assets.
- The proprieties of the pages are used to create the webpage but its content can be used as obsidian note for further reference ?
- Use: `draft: true` to not publish the item on the website

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
from "content/Charts"
group by parent_folder
```
#### By Others
```dataview
list
from "content/Charts/By Others"
```
#### Hand Made
```dataview
list
from "content/Charts/Hand Made"
```