CREATE TABLE IF NOT EXISTS workspace.brazilian_economic_silver.bcb_sgs_selic
(
    reference_date DATE
        COMMENT 'Reference date of the Selic target rate',

    selic_target_rate DECIMAL(8,4)
        COMMENT 'Validated Selic target rate',

    source_system STRING
        COMMENT 'Source system identifier',

    source_series_code STRING
        COMMENT 'BCB SGS series code',

    source_ingestion_timestamp TIMESTAMP
        COMMENT 'Timestamp of the selected Bronze ingestion',

    source_execution_id STRING
        COMMENT 'Execution identifier of the selected Bronze record',

    processed_timestamp TIMESTAMP
        COMMENT 'Timestamp when the Silver transformation was executed'
)
USING DELTA
COMMENT 'Validated and deduplicated Selic target rate data from BCB SGS series 432';