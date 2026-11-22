-- singular test: returns the rows that BREAK the rule (0 rows = pass).
-- A discount can only lower the price: net_amount <= quantity * unit_price.
select sale_id, quantity, unit_price, net_amount
from {{ ref('fact_sales') }}
where net_amount > quantity * unit_price
