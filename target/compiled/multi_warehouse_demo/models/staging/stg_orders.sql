

with src as (
  select * from DEMO.analytics.raw_orders
)

select
  cast(order_id as integer)          as order_id,
  cast(user_id as integer)           as user_id,
  cast(order_ts as timestamp)        as order_ts,
  status
from src

  where order_ts > (select coalesce(max(order_ts), '1900-01-01') from DEMO.ANALYTICS.stg_orders)


-- Optional bounded window using vars
