CREATE TABLE IF NOT EXISTS workspace.brazilian_economic_governance.data_quality_results
(
    check_timestamp TIMESTAMP
        COMMENT 'Timestamp when the data quality check was executed',

    source_system STRING
        COMMENT 'Source system being validated',

    dataset_name STRING
        COMMENT 'Dataset being validated',

    layer STRING
        COMMENT 'Lakehouse layer being validated',

    check_name STRING
        COMMENT 'Name of the data quality rule',

    check_status STRING
        COMMENT 'Result of the check: PASS or FAIL',

    failed_records BIGINT
        COMMENT 'Number of records that failed the validation',

    execution_id STRING
        COMMENT 'Unique identifier of the data quality execution'
)
USING DELTA
COMMENT 'Historical results of automated data quality checks';