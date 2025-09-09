-- back compat for old kwarg name
  
  begin;
    
        
            
	    
	    
            
        
    

    

    merge into DEMO.ANALYTICS.stg_orders as DBT_INTERNAL_DEST
        using DEMO.ANALYTICS.stg_orders__dbt_tmp as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.order_id = DBT_INTERNAL_DEST.order_id))

    
    when matched then update set
        "ORDER_ID" = DBT_INTERNAL_SOURCE."ORDER_ID","USER_ID" = DBT_INTERNAL_SOURCE."USER_ID","ORDER_TS" = DBT_INTERNAL_SOURCE."ORDER_TS","STATUS" = DBT_INTERNAL_SOURCE."STATUS"
    

    when not matched then insert
        ("ORDER_ID", "USER_ID", "ORDER_TS", "STATUS")
    values
        ("ORDER_ID", "USER_ID", "ORDER_TS", "STATUS")

;
    commit;