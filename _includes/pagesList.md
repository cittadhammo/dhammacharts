{% assign pages = site[include.area] | where: "type", "page" %}

{% for page in pages %}

- <a href="{{ page.url }}"> {{ page.title }} </a>

{% endfor %}
