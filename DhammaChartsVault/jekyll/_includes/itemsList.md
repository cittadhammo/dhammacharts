{% assign area = site.data.areas | where: "name", include.area | first %}

{% for category in area.categories %}
    
### {{ category.name }} 
    
{% assign items = site[include.area] | where: "category", category.name %}

    {% for item in items %}

- <a href="{{ item.url }}"> {{ item.title }} </a>
        
    {% endfor %}

{% endfor %}


