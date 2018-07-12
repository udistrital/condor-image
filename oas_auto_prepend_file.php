<?php
  require 'aws.phar';
  use Aws\DynamoDb\DynamoDbClient;

  if (getenv('OAS_DYNAMODB_SESSION_TABLE')) {
    $dynamoDb = DynamoDbClient::factory();
    $sessionHandler = $dynamoDb->registerSessionHandler(array(
      'table_name' => getenv('OAS_DYNAMODB_SESSION_TABLE'),
      'automatic_gc' => false,
    ));
  }

  $memcache = new Memcache;

  if (getenv('OAS_MEMCACHED_SERVICE')) {
    $memcached_hosts = gethostbynamel(getenv('OAS_MEMCACHED_SERVICE'));
    sort($memcached_hosts);
    foreach($memcached_hosts as $memcached_host) {
      $memcache->addServer($memcached_host, 11211);
      mysqlnd_qc_set_storage_handler('memcache');
    }
  }
?>
