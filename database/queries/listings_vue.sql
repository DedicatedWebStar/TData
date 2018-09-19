--CREATE VIEW listings_view AS


SELECT  evt.tm_id,
        evt."fromBoxOfficeFox",
        evt.name,
        att.name AS attraction_name,
        att.upcoming_events,
        ven.name AS venue_name,
        evt.type,
        evt.url,
        evt.locale,
        evt.public_sale_datetime,
        min(evt_psl.start_datetime) AS presale_datetime,
        CASE
            WHEN evt.public_sale_datetime < min(evt_psl.start_datetime) OR min(evt_psl.start_datetime) IS NULL
            THEN
                evt.public_sale_datetime
            ELSE
                min(evt_psl.start_datetime)
        END AS first_onsale_datetime,        
        evt_psl.name AS presale_name,
        evt.sales_start_tbd,
        evt.event_local_date,
        evt.event_local_time,
        evt.event_time_zone,
        evt.event_datetime,
        evt.event_status_code,
        seg.name AS segment_name,
        gen.name AS genre_name,
        sub_gen.name AS sub_genre_name,
        evt.ticket_limit,
        evt.ticket_max_number,
        evt.created_at AS event_created_at,
        evt.updated_at AS event_updated_at,
        evt.currency,
        min(evt_prc.total) AS min_price,
        array_min
        (
            ARRAY ( 
                   SELECT total FROM event_prices 
                   WHERE event_id = evt.id ORDER BY total DESC LIMIT 2 )
        ) AS second_highest_price,
        max(evt_prc.total) AS max_price,
        round(avg(evt_prc.total)) AS average_price,
        CASE
            WHEN dm.weighted_avg IS NOT NULL AND min(evt_prc.total) > 0
            THEN
                ceil((((dm.weighted_avg * .94 * (SELECT adjustment FROM weekday_adjustment WHERE weekday = EXTRACT(dow FROM evt.event_local_date))) -  min(evt_prc.total))  / min(evt_prc.total)) * 100)
            ELSE
                0
        END AS roi_low,  
        CASE
            WHEN dm.weighted_avg IS NOT NULL AND max(evt_prc.total) > 0
            THEN
                ceil((((dm.weighted_avg * .94 * (SELECT adjustment FROM weekday_adjustment WHERE weekday = EXTRACT(dow FROM evt.event_local_date))) - array_min(ARRAY (SELECT total FROM event_prices WHERE event_id = evt.id ORDER BY total DESC LIMIT 2 )))  / array_min(ARRAY (SELECT total FROM event_prices WHERE event_id = evt.id ORDER BY total DESC LIMIT 2 ))) * 100)
            ELSE
                0
        END AS roi_second_highest,  
        CASE
            WHEN dm.weighted_avg IS NOT NULL AND max(evt_prc.total) > 0
            THEN
                ceil((((dm.weighted_avg * .94 * (SELECT adjustment FROM weekday_adjustment WHERE weekday = EXTRACT(dow FROM evt.event_local_date))) -  max(evt_prc.total))  / max(evt_prc.total)) * 100)
            ELSE
                0
        END AS roi_high,  
        evt.data_master_id,
        dm.total_events,
        dm.total_sold,
        dm.total_vol,
        dm.weighted_avg,
        dm.tot_per_event,
        dm.td_events,
        dm.td_tix_sold,
        dm.td_vol,
        dm.tn_events,
        dm.tn_tix_sold,
        dm.tn_vol,
        dm.tn_avg_sale,
        dm.levi_events,
        dm.levi_tix_sold,
        dm.levi_vol,
        dm.si_events,
        dm.si_tix_sold,
        dm.si_vol,
        dm.sfc_roi,
        dm.sfc_roi_dollar,
        dm.sfc_cogs
FROM events evt
    LEFT JOIN segments seg
        ON evt.segment_Id = seg.id
    LEFT JOIN genres gen
        ON evt.genre_id = gen.id
    LEFT JOIN sub_genres sub_gen
        ON evt.sub_genre_id = sub_gen.id
    LEFT JOIN event_attraction evt_att
        ON evt.id = evt_att.event_id
    LEFT JOIN attractions att
        ON evt_att.attraction_id = att.id
    LEFT JOIN event_venue evt_ven
        ON evt.id = evt_ven.event_id
    LEFT JOIN venues ven
        ON evt_ven.venue_id = ven.id    
    LEFT JOIN event_prices evt_prc
        ON evt.id = evt_prc.event_id    
    LEFT JOIN event_presales evt_psl
        ON evt.id = evt_psl.event_id        
    LEFT JOIN data_master dm
        ON evt.data_master_id = dm.id    
WHERE evt_att.primary = TRUE    
AND evt_ven.primary = TRUE    
GROUP BY
        evt.id,
        evt.tm_id,
        evt."fromBoxOfficeFox",
        evt.name,
        ven.name,
        att.name,
        att.upcoming_events,
        evt.type,
        evt.url,
        evt.locale,
        evt.currency,
        evt.public_sale_datetime,
        evt.sales_start_tbd,
        evt.event_local_date,
        evt.event_local_time,
        evt.event_time_zone,
        evt.event_datetime,
        evt.event_status_code,
        seg.name,
        gen.name,
        sub_gen.name,
        evt.ticket_limit,
        evt.ticket_max_number,
        evt.created_at,
        evt.updated_at,
        evt_psl.name,
        evt.data_master_id, 
        dm.total_events,
        dm.total_sold,
        dm.total_vol,
        dm.weighted_avg,
        dm.tot_per_event,
        dm.td_events,
        dm.td_tix_sold,
        dm.td_vol,
        dm.tn_events,
        dm.tn_tix_sold,
        dm.tn_vol,
        dm.tn_avg_sale,
        dm.levi_events,
        dm.levi_tix_sold,
        dm.levi_vol,
        dm.si_events,
        dm.si_tix_sold,
        dm.si_vol,
        dm.sfc_roi,
        dm.sfc_roi_dollar,
        dm.sfc_cogs
   
/*   
    create or replace function array_min(anyarray) returns anyelement
as
$$
select min(unnested) from( select unnest($1) unnested ) as x
$$ language sql;
*/