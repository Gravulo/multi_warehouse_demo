-- back compat for old kwarg name
  
  begin;
    
        
            
	    
	    
            
        
    

    

    merge into DEMO.ANALYTICS.fct_orders_daily as DBT_INTERNAL_DEST
        using DEMO.ANALYTICS.fct_orders_daily__dbt_tmp as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.order_date = DBT_INTERNAL_DEST.order_date))

    
    when matched then update set
        "ORDER_DATE" = DBT_INTERNAL_SOURCE."ORDER_DATE","DAILY_REVENUE" = DBT_INTERNAL_SOURCE."DAILY_REVENUE","ORDERS" = DBT_INTERNAL_SOURCE."ORDERS"
    

    when not matched then insert
        ("ORDER_DATE", "DAILY_REVENUE", "ORDERS")
    values
        ("ORDER_DATE", "DAILY_REVENUE", "ORDERS")

;
    commit;