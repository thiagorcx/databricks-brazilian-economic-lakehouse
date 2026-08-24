WITH run_context AS (
    SELECT
        CURRENT_TIMESTAMP() AS check_timestamp,
        UUID() AS execution_id
),

quality_checks AS (

    -- 1. Null reference date
    SELECT
        'NULL_REFERENCE_DATE' AS check_name,
        COUNT(*) AS failed_records
    FROM workspace.brazilian_economic_bronze.bcb_sgs_selic
    WHERE reference_date_raw IS NULL

    UNION ALL

    -- 2. Null Selic value
    SELECT
        'NULL_VALUE' AS check_name,
        COUNT(*) AS failed_records
    FROM workspace.brazilian_economic_bronze.bcb_sgs_selic
    WHERE value_raw IS NULL

    UNION ALL

    -- 3. Invalid reference date
    SELECT
        'INVALID_REFERENCE_DATE' AS check_name,
        COUNT(*) AS failed_records
    FROM workspace.brazilian_economic_bronze.bcb_sgs_selic
    WHERE
        reference_date_raw IS NOT NULL
        AND TRY_TO_DATE(reference_date_raw, 'dd/MM/yyyy') IS NULL

    UNION ALL

    -- 4. Invalid numeric value
    SELECT
        'INVALID_VALUE' AS check_name,
        COUNT(*) AS failed_records
    FROM workspace.brazilian_economic_bronze.bcb_sgs_selic
    WHERE
        value_raw IS NOT NULL
        AND TRY_CAST(value_raw AS DECIMAL(8,4)) IS NULL

    UNION ALL

    -- 5. Duplicates inside the same ingestion execution
    SELECT
        'DUPLICATE_WITHIN_EXECUTION' AS check_name,
        COALESCE(SUM(record_count - 1), 0) AS failed_records
    FROM (
        SELECT
            execution_id,
            source_series_code,
            reference_date_raw,
            COUNT(*) AS record_count
        FROM workspace.brazilian_economic_bronze.bcb_sgs_selic
        GROUP BY
            execution_id,
            source_series_code,
            reference_date_raw
        HAVING COUNT(*) > 1
    )
)

INSERT INTO workspace.brazilian_economic_governance.data_quality_results

SELECT
    rc.check_timestamp,
    'BCB_SGS' AS source_system,
    'bcb_sgs_selic' AS dataset_name,
    'BRONZE' AS layer,
    qc.check_name,
    CASE
        WHEN qc.failed_records = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status,
    qc.failed_records,
    rc.execution_id
FROM quality_checks qc
CROSS JOIN run_context rc;