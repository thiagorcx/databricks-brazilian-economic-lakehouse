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
    FROM workspace.brazilian_economic_silver.bcb_sgs_selic
    WHERE reference_date IS NULL

    UNION ALL

    -- 2. Null Selic rate
    SELECT
        'NULL_SELIC_TARGET_RATE' AS check_name,
        COUNT(*) AS failed_records
    FROM workspace.brazilian_economic_silver.bcb_sgs_selic
    WHERE selic_target_rate IS NULL

    UNION ALL

    -- 3. Invalid Selic rate
    SELECT
        'INVALID_SELIC_TARGET_RATE' AS check_name,
        COUNT(*) AS failed_records
    FROM workspace.brazilian_economic_silver.bcb_sgs_selic
    WHERE
        selic_target_rate < 0
        OR selic_target_rate > 100

    UNION ALL

    -- 4. Duplicate business key
    SELECT
        'DUPLICATE_REFERENCE_DATE' AS check_name,
        COALESCE(SUM(record_count - 1), 0) AS failed_records
    FROM (
        SELECT
            source_series_code,
            reference_date,
            COUNT(*) AS record_count
        FROM workspace.brazilian_economic_silver.bcb_sgs_selic
        GROUP BY
            source_series_code,
            reference_date
        HAVING COUNT(*) > 1
    )

    UNION ALL

    -- 5. Empty dataset
    SELECT
        'EMPTY_DATASET' AS check_name,
        CASE
            WHEN COUNT(*) = 0 THEN 1
            ELSE 0
        END AS failed_records
    FROM workspace.brazilian_economic_silver.bcb_sgs_selic
)

INSERT INTO workspace.brazilian_economic_governance.data_quality_results

SELECT
    rc.check_timestamp,
    'BCB_SGS' AS source_system,
    'bcb_sgs_selic' AS dataset_name,
    'SILVER' AS layer,
    qc.check_name,
    CASE
        WHEN qc.failed_records = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status,
    qc.failed_records,
    rc.execution_id
FROM quality_checks qc
CROSS JOIN run_context rc;