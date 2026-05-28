-- which litho tool perform the best
WITH tool_performance AS (
	SELECT 
		litho_tool,
		technology_node,
		round(avg(yield::numeric),2) AS avg_yield,
		avg(yield::NUMERIC) AS avg_yield_raw,
		round(stddev(yield::numeric),2) AS std_yield,
		stddev(yield::numeric) AS std_yield_raw,
		count(wafer_id) AS wafer_count
	FROM semiconductor_yield_forecasting_data syfd
	GROUP BY 
		litho_tool,
		technology_node
	) 
	,
	fleet AS (
	SELECT
		technology_node,
		round(avg(yield::numeric),2) AS fleet_mean,
		avg(yield::numeric) AS fleet_mean_raw,		
		round(stddev(yield::numeric),2) AS fleet_std,
		stddev(yield::NUMERIC) AS fleet_std_raw
	FROM semiconductor_yield_forecasting_data syfd
	GROUP BY 
		technology_node
	)
SELECT 
	t.litho_tool,
	t.technology_node,
	t.avg_yield,
	t.std_yield,
	t.wafer_count,
	f.fleet_mean,
	f.fleet_std,
	round((t.avg_yield_raw - f.fleet_mean_raw)::NUMERIC,2) AS gap_vs_fleet,
	rank() OVER (
		PARTITION BY t.technology_node 
		ORDER BY t.avg_yield_raw DESC
	) AS yield_rank,
	CASE 
        WHEN t.avg_yield_raw >= f.fleet_mean_raw
             AND t.std_yield_raw <= f.fleet_std_raw
            THEN 'Best Performer — high yield & stable'
        WHEN t.avg_yield_raw < (f.fleet_mean_raw - 0.5 * f.fleet_std_raw)
             AND t.std_yield_raw > f.fleet_std_raw
            THEN 'Critical — low yield & unstable'
        WHEN t.avg_yield_raw < (f.fleet_mean_raw - 0.5 * f.fleet_std_raw)
             AND t.std_yield_raw <= f.fleet_std_raw
            THEN 'Underperforming — low yield'
        WHEN t.avg_yield_raw >= (f.fleet_mean_raw - 0.5 * f.fleet_std_raw)
             AND t.std_yield_raw > f.fleet_std_raw
            THEN 'Watch — unstable yield'
        ELSE 'Stable'
    END AS tool_status	
	FROM tool_performance t 
	JOIN fleet f
	ON t.technology_node = f.technology_node
	ORDER BY 
		REPLACE(t.technology_node,'nm','')::NUMERIC,
		t.avg_yield_raw DESC;
		
-- detect single tool
SELECT 
	technology_node,
	product_type,
	count(DISTINCT lot_id) AS lot_quantity,
	count(wafer_id) AS wafer_quantity,
	min(litho_tool) AS only_litho_tool
FROM semiconductor_yield_forecasting_data syfd
GROUP BY 
	technology_node,
	product_type
HAVING count(DISTINCT litho_tool) = 1
ORDER BY 
	REPLACE(technology_node,'nm',''):: int,
	product_type;