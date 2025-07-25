BEGIN TRANSACTION;

INSERT INTO
    "main"."monitor" (
        "name",
        "active",
        "user_id",
        "interval",
        "url",
        "type",
        "weight",
        "hostname",
        "port",
        "created_date",
        "keyword",
        "maxretries",
        "ignore_tls",
        "upside_down",
        "maxredirects",
        "accepted_statuscodes_json",
        "dns_resolve_type",
        "dns_resolve_server",
        "dns_last_result",
        "retry_interval",
        "push_token",
        "method",
        "body",
        "headers",
        "basic_auth_user",
        "basic_auth_pass",
        "docker_host",
        "docker_container",
        "proxy_id",
        "expiry_notification",
        "mqtt_topic",
        "mqtt_success_message",
        "mqtt_username",
        "mqtt_password",
        "database_connection_string",
        "database_query",
        "auth_method",
        "auth_domain",
        "auth_workstation",
        "grpc_url",
        "grpc_protobuf",
        "grpc_body",
        "grpc_metadata",
        "grpc_method",
        "grpc_service_name",
        "grpc_enable_tls",
        "radius_username",
        "radius_password",
        "radius_calling_station_id",
        "radius_called_station_id",
        "radius_secret",
        "resend_interval",
        "packet_size",
        "game",
        "http_body_encoding",
        "description",
        "tls_ca",
        "tls_cert",
        "tls_key",
        "parent",
        "invert_keyword",
        "json_path",
        "expected_value",
        "kafka_producer_topic",
        "kafka_producer_brokers",
        "kafka_producer_sasl_options",
        "kafka_producer_message",
        "oauth_client_id",
        "oauth_client_secret",
        "oauth_token_url",
        "oauth_scopes",
        "oauth_auth_method",
        "timeout",
        "gamedig_given_port_only",
        "kafka_producer_ssl",
        "kafka_producer_allow_auto_topic_creation"
    )
SELECT
    'onionbalance',
    '1',
    '1',
    '60',
    'https://',
    'docker',
    '2000',
    NULL,
    NULL,
    '2024-08-10 10:00:00',
    NULL,
    '0',
    '0',
    '0',
    '10',
    '["200-299"]',
    'A',
    '1.1.1.1',
    NULL,
    '60',
    NULL,
    'GET',
    NULL,
    NULL,
    NULL,
    NULL,
    '1',
    'tor-frontend',
    NULL,
    '0',
    '',
    '',
    '',
    '',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '0',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '0',
    '56',
    NULL,
    'utf-8',
    NULL,
    NULL,
    NULL,
    NULL,
    '2',
    '0',
    NULL,
    NULL,
    NULL,
    '[]',
    '{"mechanism":"None"}',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'client_secret_basic',
    '48.0',
    '1',
    '0',
    '0'
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            "main"."monitor"
        WHERE
            "name" = 'onionbalance'
    );

INSERT INTO
    "main"."monitor" (
        "name",
        "active",
        "user_id",
        "interval",
        "url",
        "type",
        "weight",
        "hostname",
        "port",
        "created_date",
        "keyword",
        "maxretries",
        "ignore_tls",
        "upside_down",
        "maxredirects",
        "accepted_statuscodes_json",
        "dns_resolve_type",
        "dns_resolve_server",
        "dns_last_result",
        "retry_interval",
        "push_token",
        "method",
        "body",
        "headers",
        "basic_auth_user",
        "basic_auth_pass",
        "docker_host",
        "docker_container",
        "proxy_id",
        "expiry_notification",
        "mqtt_topic",
        "mqtt_success_message",
        "mqtt_username",
        "mqtt_password",
        "database_connection_string",
        "database_query",
        "auth_method",
        "auth_domain",
        "auth_workstation",
        "grpc_url",
        "grpc_protobuf",
        "grpc_body",
        "grpc_metadata",
        "grpc_method",
        "grpc_service_name",
        "grpc_enable_tls",
        "radius_username",
        "radius_password",
        "radius_calling_station_id",
        "radius_called_station_id",
        "radius_secret",
        "resend_interval",
        "packet_size",
        "game",
        "http_body_encoding",
        "description",
        "tls_ca",
        "tls_cert",
        "tls_key",
        "parent",
        "invert_keyword",
        "json_path",
        "expected_value",
        "kafka_producer_topic",
        "kafka_producer_brokers",
        "kafka_producer_sasl_options",
        "kafka_producer_message",
        "oauth_client_id",
        "oauth_client_secret",
        "oauth_token_url",
        "oauth_scopes",
        "oauth_auth_method",
        "timeout",
        "gamedig_given_port_only",
        "kafka_producer_ssl",
        "kafka_producer_allow_auto_topic_creation"
    )
SELECT
    'Docker',
    '1',
    '1',
    '60',
    'https://',
    'group',
    '2000',
    NULL,
    NULL,
    '2024-08-10 10:00:00',
    NULL,
    '0',
    '0',
    '0',
    '10',
    '["200-299"]',
    'A',
    '1.1.1.1',
    NULL,
    '60',
    NULL,
    'GET',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '',
    NULL,
    '0',
    '',
    '',
    '',
    '',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '0',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '0',
    '56',
    NULL,
    'json',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '0',
    NULL,
    NULL,
    NULL,
    '[]',
    '{"mechanism":"None"}',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'client_secret_basic',
    '48.0',
    '1',
    '0',
    '0'
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            "main"."monitor"
        WHERE
            "name" = 'Docker'
    );

INSERT INTO
    "main"."monitor" (
        "name",
        "active",
        "user_id",
        "interval",
        "url",
        "type",
        "weight",
        "hostname",
        "port",
        "created_date",
        "keyword",
        "maxretries",
        "ignore_tls",
        "upside_down",
        "maxredirects",
        "accepted_statuscodes_json",
        "dns_resolve_type",
        "dns_resolve_server",
        "dns_last_result",
        "retry_interval",
        "push_token",
        "method",
        "body",
        "headers",
        "basic_auth_user",
        "basic_auth_pass",
        "docker_host",
        "docker_container",
        "proxy_id",
        "expiry_notification",
        "mqtt_topic",
        "mqtt_success_message",
        "mqtt_username",
        "mqtt_password",
        "database_connection_string",
        "database_query",
        "auth_method",
        "auth_domain",
        "auth_workstation",
        "grpc_url",
        "grpc_protobuf",
        "grpc_body",
        "grpc_metadata",
        "grpc_method",
        "grpc_service_name",
        "grpc_enable_tls",
        "radius_username",
        "radius_password",
        "radius_calling_station_id",
        "radius_called_station_id",
        "radius_secret",
        "resend_interval",
        "packet_size",
        "game",
        "http_body_encoding",
        "description",
        "tls_ca",
        "tls_cert",
        "tls_key",
        "parent",
        "invert_keyword",
        "json_path",
        "expected_value",
        "kafka_producer_topic",
        "kafka_producer_brokers",
        "kafka_producer_sasl_options",
        "kafka_producer_message",
        "oauth_client_id",
        "oauth_client_secret",
        "oauth_token_url",
        "oauth_scopes",
        "oauth_auth_method",
        "timeout",
        "gamedig_given_port_only",
        "kafka_producer_ssl",
        "kafka_producer_allow_auto_topic_creation"
    )
SELECT
    'octo',
    '1',
    '1',
    '60',
    'https://dummy.onion',
    'http',
    '2000',
    NULL,
    NULL,
    '2024-08-10 10:00:00',
    NULL,
    '3',
    '0',
    '0',
    '10',
    '["200-299"]',
    'A',
    '1.1.1.1',
    NULL,
    '60',
    NULL,
    'GET',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '',
    '1',
    '0',
    '',
    '',
    '',
    '',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '0',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '0',
    '56',
    NULL,
    'json',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '0',
    NULL,
    NULL,
    NULL,
    '[]',
    '{"mechanism":"None"}',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'client_secret_basic',
    '48.0',
    '1',
    '0',
    '0'
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            "main"."monitor"
        WHERE
            "name" = 'octo'
    );

COMMIT;
