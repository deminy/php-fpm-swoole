#!/usr/bin/env php
<?php

use Swoole\Http\Server;
use Swoole\Http\Request;
use Swoole\Http\Response;

$http = new Server('0.0.0.0', 9501);
$http->on('request', function (Request $request, Response $response) {
    $response->end('Powered by Swoole.');
});
$http->start();
