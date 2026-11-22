-- grain: one row = one product line item within one checkout.
{{
    config(
        materialized='incremental',
        unique_key='sale_id',
        incremental_strategy='merge',
    )
}}

select
    order_id || '_' || product_id as sale_id,
    order_id,
    sale_date,
    checkout_at,
    store_id,
    product_id,
    quantity,
    unit_price,
    discount_pct,
    net_amount
from {{ ref('int_checkout_items_priced') }}

{% if is_incremental() %}
where checkout_at > (select max(checkout_at) from {{ this }})
{% endif %}
