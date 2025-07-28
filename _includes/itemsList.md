{% assign area_name = include.area %}

{% assign area = site.data.areas | where: "name", area_name | first %}

---

{% for category in area.categories %}
   
## {{ category.title }} 

{% assign items = site[area_name] %}

    {% for item in items %}
    {% assign parents = item.url | split: "/" %}
    {% assign parent  = parents[-2] %}

        {% if parent == category.name %} 

- <a href="{{ item.url }}"> {{ item.title }} </a>

        {% endif %}

    {% endfor %}

{% endfor %}



