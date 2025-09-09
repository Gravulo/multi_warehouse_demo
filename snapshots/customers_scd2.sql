{% snapshot customers_scd2 %}
{{ config(
    target_schema='analytics_snapshots',
    unique_key='user_id',
    strategy='timestamp',
    updated_at='change_ts'
) }}

select
  cast(user_id as integer)      as user_id,
  lower(email)                  as email,
  country,
  cast(change_ts as timestamp)  as change_ts
from {{ source('analytics','raw_users_changes') }}

{% endsnapshot %}
