
  create or replace   view DEMO.ANALYTICS.stg_order_items
  
  
  
  
  as (
    with src as (
  select * from DEMO.analytics.raw_order_items
)
select
  cast(order_id as integer)          as order_id,
  sku,
  cast(qty as integer)               as qty,
  cast(unit_price as decimal(10,2))  as unit_price
from src
  );

