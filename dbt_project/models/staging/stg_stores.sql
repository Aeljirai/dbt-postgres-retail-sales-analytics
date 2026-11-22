select
    store_id,
    store_name,
    city,
    address
from {{ source('raw', 'raw_stores') }}
