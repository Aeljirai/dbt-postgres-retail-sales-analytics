-- ephemeral: never materialized as its own object in the warehouse, just
-- injected as a CTE into whatever references it. Tradeoff: no extra object
-- to maintain, but it can't be queried directly when debugging.
--
-- Pricing uses the CURRENT promotion version (dbt_valid_to is null) -- the
-- standard way to consume a snapshot from a mart. The snapshot TABLE
-- itself still keeps every past version (query snapshots.promotions_snapshot
-- directly to see them) -- that history just isn't replayed against past
-- checkout timestamps here, the same way most dbt snapshot use looks
-- "what does this dimension look like today", not "what did it look like
-- when this exact row was born".

with checkout_items as (
    select * from {{ ref('stg_checkout_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

current_promotions as (
    select * from {{ ref('promotions_snapshot') }}
    where dbt_valid_to is null
)

select
    ci.order_id,
    ci.store_id,
    ci.product_id,
    ci.quantity,
    ci.checkout_at,
    ci.sale_date,
    p.unit_price,
    coalesce(promo.discount_pct, 0) as discount_pct,
    {{ net_amount('ci.quantity', 'p.unit_price', 'promo.discount_pct') }} as net_amount
from checkout_items ci
-- LEFT JOIN on purpose: a checkout_item referencing a product_id that
-- doesn't exist in dim_product should NOT be silently filtered out here --
-- it should reach fact_sales (with a null unit_price/net_amount) so the
-- relationships test on fact_sales.product_id is the thing that actually
-- catches it. dbt test IS the quality gate in this project, not a filter
-- hidden upstream in a join.
left join products p on p.product_id = ci.product_id
left join current_promotions promo
    on promo.product_id = ci.product_id
    and ci.sale_date between promo.start_date and promo.end_date
