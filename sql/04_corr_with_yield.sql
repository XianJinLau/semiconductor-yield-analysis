-- Yield driver correlation summary

SELECT 'etch_rate' AS parameter_name, ROUND(CORR(etch_rate::numeric, yield::numeric)::numeric, 3) AS corr_with_yield
FROM semiconductor_yield_forecasting_data

UNION ALL
SELECT 'deposition_rate', ROUND(CORR(deposition_rate::numeric, yield::numeric)::numeric, 3)
FROM semiconductor_yield_forecasting_data

UNION ALL
SELECT 'critical_dimension', ROUND(CORR(critical_dimension::numeric, yield::numeric)::numeric, 3)
FROM semiconductor_yield_forecasting_data

UNION ALL
SELECT 'oxide_thickness', ROUND(CORR(oxide_thickness::numeric, yield::numeric)::numeric, 3)
FROM semiconductor_yield_forecasting_data

UNION ALL
SELECT 'defect_count', ROUND(CORR(defect_count::numeric, yield::numeric)::numeric, 3)
FROM semiconductor_yield_forecasting_data

UNION ALL
SELECT 'defect_density', ROUND(CORR(defect_density::numeric, yield::numeric)::numeric, 3)
FROM semiconductor_yield_forecasting_data

UNION ALL
SELECT 'vth', ROUND(CORR(vth::numeric, yield::numeric)::numeric, 3)
FROM semiconductor_yield_forecasting_data

UNION ALL
SELECT 'leakage_current', ROUND(CORR(leakage_current::numeric, yield::numeric)::numeric, 3)
FROM semiconductor_yield_forecasting_data

UNION ALL
SELECT 'resistance', ROUND(CORR(resistance::numeric, yield::numeric)::numeric, 3)
FROM semiconductor_yield_forecasting_data

ORDER BY corr_with_yield ASC;