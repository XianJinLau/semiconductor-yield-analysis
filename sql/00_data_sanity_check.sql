-- number of rows and columns inside
SELECT 
	(SELECT 
		count(*) 
	FROM semiconductor_yield_forecasting_data syfd) AS n_rows,
	(SELECT 
		count(*) 
	FROM information_schema.columns
	WHERE table_name = 'semiconductor_yield_forecasting_data') AS n_columns;

-- check if there is null data
SELECT
	-- identifiers
	count(*) FILTER (WHERE lot_id IS NULL) AS null_lot_id,
	count(*) FILTER (WHERE wafer_id IS NULL) AS null_wafer_id,
	count(*) FILTER (WHERE product_type IS NULL) AS null_product_type,
	count(*) FILTER (WHERE technology_node IS NULL) AS null_technology_node,
	-- tool columns
	count(*) FILTER (WHERE etch_tool IS NULL) AS null_etch_tool,
	count(*) FILTER (WHERE litho_tool IS NULL) AS null_litho_tool,
	count(*) FILTER (WHERE deposition_tool IS NULL) AS null_deposition_tool,
	count(*) FILTER (WHERE implant_tool IS NULL) AS null_implant_tool,
	-- key analysis columns
	count(*) FILTER (WHERE yield IS NULL) AS null_yield,
	count(*) FILTER (WHERE defect_count IS NULL) AS null_defect_count,
	count(*) FILTER (WHERE defect_density IS NULL) AS null_defect_density,
	count(*) FILTER (WHERE etch_rate IS NULL) AS null_etch_rate,
	count(*) FILTER (WHERE critical_dimension IS NULL) AS null_critical_dimension,
	count(*) FILTER (WHERE oxide_thickness IS NULL) AS null_oxide_thickness
FROM semiconductor_yield_forecasting_data;

-- check if there is duplicate data
SELECT  
	lot_id,
	wafer_id,
	count(*) AS record_count
FROM semiconductor_yield_forecasting_data
GROUP BY lot_id, wafer_id 
HAVING count(*) > 1;

-- check data date range
SELECT
	min(process_date) AS start_time,
	max(process_date) AS end_time
FROM semiconductor_yield_forecasting_data syfd; 

-- lot check
SELECT 	
	lot_id,
	count(wafer_id) AS wafer_count
FROM semiconductor_yield_forecasting_data syfd
GROUP BY lot_id
ORDER BY lot_id;

-- product category check
SELECT  
	product_type,
	count(*) AS row_count
FROM semiconductor_yield_forecasting_data syfd
GROUP BY product_type
ORDER BY row_count;

-- technology node check
SELECT  
	technology_node,
	count(*) AS row_count
FROM semiconductor_yield_forecasting_data syfd
GROUP BY technology_node
ORDER BY row_count;

-- numerical range/ outlier check
SELECT
    MIN(yield) AS min_yield,
    MAX(yield) AS max_yield,
    AVG(yield) AS avg_yield,

    MIN(defect_count) AS min_defect_count,
    MAX(defect_count) AS max_defect_count,
    AVG(defect_count) AS avg_defect_count,

    MIN(defect_density) AS min_defect_density,
    MAX(defect_density) AS max_defect_density,
    AVG(defect_density) AS avg_defect_density,

    MIN(critical_dimension) AS min_cd,
    MAX(critical_dimension) AS max_cd,
    AVG(critical_dimension) AS avg_cd
FROM semiconductor_yield_forecasting_data syfd;
	
-- how many lot run certain tech_node and product_type
SELECT 
	technology_node,
	product_type,
	count(DISTINCT lot_id) AS lot_count
FROM semiconductor_yield_forecasting_data syfd
GROUP BY 
	technology_node,
	product_type
ORDER BY
	replace(technology_node,'nm','')::int	
	
	
	
	