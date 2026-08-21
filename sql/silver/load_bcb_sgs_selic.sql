MERGE INTO workspace.brazilian_economic_silver.bcb_sgs_selic AS target

USING (

    SELECT
        TO_DATE(reference_date_raw, 'dd/MM/yyyy') AS reference_date,
        CAST(value_raw AS DECIMAL(8,4)) AS selic_target_rate,
        source_system,
        source_series_code,
        ingestion_timestamp AS source_ingestion_timestamp,
        execution_id AS source_execution_id,
        CURRENT_TIMESTAMP() AS processed_timestamp
    FROM workspace.brazilian_economic_bronze.bcb_sgs_selic
    WHERE
        reference_date_raw IS NOT NULL
        AND value_raw IS NOT NULL
        AND TRY_TO_DATE(reference_date_raw, 'dd/MM/yyyy') IS NOT NULL
        AND TRY_CAST(value_raw AS DECIMAL(8,4)) IS NOT NULL

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY source_series_code, reference_date_raw
        ORDER BY ingestion_timestamp DESC
    ) = 1

) AS source

ON
    target.source_series_code = source.source_series_code
    AND target.reference_date = source.reference_date

WHEN MATCHED THEN UPDATE SET
    target.selic_target_rate = source.selic_target_rate,
    target.source_system = source.source_system,
    target.source_ingestion_timestamp = source.source_ingestion_timestamp,
    target.source_execution_id = source.source_execution_id,
    target.processed_timestamp = source.processed_timestamp

WHEN NOT MATCHED THEN INSERT (
    reference_date,
    selic_target_rate,
    source_system,
    source_series_code,
    source_ingestion_timestamp,
    source_execution_id,
    processed_timestamp
)
VALUES (
    source.reference_date,
    source.selic_target_rate,
    source.source_system,
    source.source_series_code,
    source.source_ingestion_timestamp,
    source.source_execution_id,
    source.processed_timestamp
);