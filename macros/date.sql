{% macro day(ts) -%}
  date_trunc('day', {{ ts }})
{%- endmacro %}
