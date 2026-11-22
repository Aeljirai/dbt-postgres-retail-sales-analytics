{% macro net_amount(quantity, unit_price, discount_pct) %}
    round({{ quantity }} * {{ unit_price }} * (1 - coalesce({{ discount_pct }}, 0) / 100.0), 2)
{% endmacro %}
