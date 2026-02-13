with src as (
  select * from {{ source('analytics','raw_users') }}
)
select
  cast(user_id as integer)           as user_id,
  lower(email)                       as email,
  country,
  cast(created_at as timestamp)      as created_at
from src
