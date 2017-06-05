<?php
/**
 * A small script to update the environment file such that it uses redis, included in this releases, as both the cache
 * and the session storage.
 */

const APP_DIR = "/var/www";

$sHelmRelease = getenv('HELM_RELEASE');
$sEnvPath     = APP_DIR . "/app/etc/env.php";

// This populates the variable aEnvironmentConfiguration with the environment configuration from the file, after
// which we can manpulate it.
$aEnvironmentConfiguration = require_once($sEnvPath);

// Update the session configuration such that it will query the redis host
// See http://devdocs.magento.com/guides/v2.0/config-guide/redis/redis-session.html
$aEnvironmentConfiguration['session'] = [
    'save'  => 'redis',
    'redis' => [
        'host'                  => "$sHelmRelease-redis",
        'port'                  => '6379',
        'password'              => '',
        'timeout'               => '1',
        'persistent_identifier' => '',
        'database'              => '2',
        'compression_threshold' => '2048',
        'compression_library'   => 'gzip',
        'log_level'             => '1',
        'max_concurrency'       => '6',
        'break_after_frontend'  => '5',
        'break_after_adminhtml' => '30',
        'first_lifetime'        => '600',
        'bot_first_lifetime'    => '60',
        'bot_lifetime'          => '7200',
        'disable_locking'       => '0',
        'min_lifetime'          => '60',
        'max_lifetime'          => '2592000'
    ]
];

$aEnvironmentConfiguration['cache'] = array(
    'frontend' =>
        [
            'default'    =>
                [
                    'backend'         => 'Cm_Cache_Backend_Redis',
                    'backend_options' =>
                        [
                            'server'   => "$sHelmRelease-redis",
                            'database' => '0',
                            'port'     => '6379'
                        ],
                ],
            'page_cache' =>
                [
                    'backend'         => 'Cm_Cache_Backend_Redis',
                    'backend_options' =>
                        [
                            'server'        => "$sHelmRelease-redis",
                            'port'          => '6379',
                            'database'      => '1',
                            'compress_data' => '0'
                        ]
                ]
        ]
);

$sExportedConfiguration = var_export($aEnvironmentConfiguration, true);

file_put_contents($sEnvPath, "return $sExportedConfiguration");
