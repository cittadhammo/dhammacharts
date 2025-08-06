{% assign pages = site[include.area] | where: "type", "page" %}

{% for page in pages %}

- <a href="{{ page.url | prepend: site.baseurl }}"> {{ page.title }} </a>

{% endfor %}
