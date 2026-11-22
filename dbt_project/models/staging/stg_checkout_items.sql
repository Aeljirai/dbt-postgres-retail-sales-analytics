-- var('start_date') is set in dbt_project.yml, and can be overridden per
-- run without touching this file: dbt run --vars '{"start_date": "2026-09-05"}'
select
    order_id,
    store_id,
    product_id,
    quantity,
    checkout_at,
    checkout_at::date as sale_date
from {{ source('raw', 'raw_checkout_items') }}
where checkout_at >= '{{ var("start_date") }}'
