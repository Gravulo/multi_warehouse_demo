with src as (
  select * from DEMO.analytics.raw_users
)
select
  cast(user_id as integer)           as user_id,
  lower(email)                       as email,
  country,
  cast(created_at as timestamp)      as created_at
from src