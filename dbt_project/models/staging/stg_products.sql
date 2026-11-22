-- staging: rename/type only, never a join
select
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    unit_price::numeric(10, 2) as unit_price
from {{ source('raw', 'raw_products') }}
