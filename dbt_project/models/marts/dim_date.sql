-- a plain generate_series date spine -- the more idiomatic way to build
-- this is the dbt_utils.date_spine macro, but that
-- needs `dbt deps` to pull the package first; this stays self-contained.
select
    d::date as date_key,
    extract(year from d)::int as year,
    extract(month from d)::int as month,
    to_char(d, 'Day') as day_of_week
from generate_series('2026-01-01'::date, '2026-12-31'::date, interval '1 day') as d
