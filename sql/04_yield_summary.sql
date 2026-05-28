-- yield distribution
SELECT 
	technology_node,	
	product_type,		
	round(avg(yield::numeric),2) AS avg_yield,
	round(max(yield::numeric),2) AS max_yield,
	round(min(yield::numeric),2) AS min_yield,
	round(stddev(yield::numeric),2) AS std_yield
FROM semiconductor_yield_forecasting_data 
GROUP BY 
	product_type, technology_node
ORDER BY
	REPLACE (technology_node, 'nm', '')::INT ASC, 
	avg_yield DESC

-- 