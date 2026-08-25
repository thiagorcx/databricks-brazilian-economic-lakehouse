CREATE TABLE IF NOT EXISTS workspace.brazilian_economic_bronze.bcb_sgs_selic
(
    reference_date_raw STRING
        COMMENT 'Reference date exactly as received from the BCB SGS API',

    value_raw STRING
        COMMENT 'Selic target rate value exactly as received from the BCB SGS API',

    source_system STRING
        COMMENT 'Source system identifier',

    source_series_code STRING
        COMMENT 'BCB SGS series code',

    ingestion_timestamp TIMESTAMP
        COMMENT 'Timestamp when the record was ingested',

    ingestion_date DATE
        COMMENT 'Date when the ingestion was executed',

    execution_id STRING
        COMMENT 'Unique identifier of the pipeline execution',

    record_hash STRING
    COMMENT 'SHA-256 hash used to identify identical source records'
)
USING DELTA
COMMENT 'Bronze table containing raw Selic target rate data from BCB SGS series 432';