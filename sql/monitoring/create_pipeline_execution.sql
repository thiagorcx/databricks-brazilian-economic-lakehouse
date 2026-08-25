CREATE TABLE IF NOT EXISTS workspace.brazilian_economic_monitoring.pipeline_execution
(
    execution_id STRING
        COMMENT 'Unique identifier of the pipeline execution',

    pipeline_name STRING
        COMMENT 'Name of the executed pipeline',

    source_system STRING
        COMMENT 'Source system processed by the pipeline',

    dataset_name STRING
        COMMENT 'Dataset processed by the pipeline',

    start_timestamp TIMESTAMP
        COMMENT 'Timestamp when pipeline execution started',

    end_timestamp TIMESTAMP
        COMMENT 'Timestamp when pipeline execution finished',

    duration_seconds BIGINT
        COMMENT 'Total pipeline execution duration in seconds',

    status STRING
        COMMENT 'Pipeline status: RUNNING, SUCCESS or FAILED',

    error_message STRING
        COMMENT 'Pipeline-level error message when execution fails'
)
USING DELTA
COMMENT 'Historical monitoring of data pipeline executions';