-- window functions on top of fact_sales -- GROUP BY collapses to one row
-- per store/day first, then the window functions add columns WITHOUT
-- collapsing further: every store/day row survives.
with daily as (
    select
        store_id,
        sale_date,
        sum(net_amount) as daily_revenue
    from {{ ref('fact_sales') }}
    group by store_id, sale_date
)

select
    store_id,
    sale_date,
    daily_revenue,
    sum(daily_revenue) over (
        partition by store_id
        order by sale_date
        rows between unbounded preceding and current row
    ) as running_total,
    rank() over (
        partition by sale_date
        order by daily_revenue desc
    ) as store_rank_that_day
from daily
order by store_id, sale_date
