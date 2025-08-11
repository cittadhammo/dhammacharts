{% assign area_name = include.area %}

{% assign area = site.data.areas | where: "name", area_name | first %}

{% assign items = site[area_name] %}

{% for category in area.categories %}
  {% assign category_name = category.name | remove: " " %}
<section class="projects">
	<div class="container">
		<h1 class="cat-title projects">{{ category.title }}</h1>
		<div class="masonry2">
			{% for item in items %}
			{% assign parent  = item.url | split: "/" | pop | last %}
				{% if parent == category.name %}
				<div class="brick">
					<a href="{{ item.url | prepend: site.baseurl }}">
						<div class="img-wrapper">
						{% assign image = item.images | first %}
							<img src="{{ site.baseurl }}/assets/images/{{ image.name | split: '.' | first }}/medium.png" alt="{{ image.name }}" />
						</div>
						<span class="h2">{{ item.type }}</span>
						<h3>{{ item.title }}</h3>
					</a>
				</div>
				{% endif %}
			{% endfor %}
		</div>
	</div>
</section>

{% endfor %}

<script src="{{ '/assets/scripts/vendor/scrollreveal.min.js' | prepend: site.baseurl }}"></script>
<script src="{{ '/assets/scripts/home.js' | prepend: site.baseurl }}"></script>



