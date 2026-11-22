{% snapshot promotions_snapshot %}
{{
    config(
      target_schema='snapshots',
      unique_key='promo_id',
      strategy='check',
      check_cols=['discount_pct', 'start_date', 'end_date'],
    )
}}
select * from {{ source('raw', 'raw_promotions') }}
{% endsnapshot %}
