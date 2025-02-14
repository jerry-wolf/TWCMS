<?php
$_ENV['_config'] = array(
	'plugin_disable' => 0,			// 禁止掉所有插件
	'zone' => 'Asia/Shanghai',		// 时区
	'gzip' => 1,	// 开启 GZIP 压缩
	'auth_key' => '',	// 加密KEY

	'twcms_parseurl' => 0,			// 是否开启前台伪静态

	'cookie_pre' => 'tw_',
	'cookie_path' => '/',
	'cookie_domain' => '',

	// 数据库配置，type 为默认的数据库类型，可以支持多种数据库: mysql|pdo_mysql|pdo_sqlite|postgresql|mongodb
	'db' => array(
		'type' => 'mysql',
		// 主数据库
		'master' => array(
			'host' => 'localhost',
			'user' => 'root',
			'password' => '',
			'name' => '2_0',
			'charset' => 'utf8mb4',
			'tablepre' => 'pre_',
			'engine'=>'MyISAM',
		),
		// 从数据库(可以是从数据库服务器群，如果不设置将使用主数据库)
		/*
		'slaves' => array(
			array(
				'host' => 'localhost',
				'user' => 'root',
				'password' => '',
				'name' => '2_0',
				'charset' => 'utf8mb4',
				'engine'=>'MyISAM',
			),
		),
		*/
	),

	// 缓存服务器配置 (开启apc缓存后，程序执行可达 0.00x 秒)
	'cache' => array(
		'enable'=>0, 			// 是否启用缓存
		'l2_cache'=>1, 			// 是否启用二级缓存
		'type'=>'memcache', 	// 支持: memcache|file|apc|redis
		'pre' => 'tw_',
		'memcache'=>array (
			'multi'=>1,
			'host'=>'127.0.0.1',
			'port'=>'11211',
		)
	),

	// 前台 (静态文件可以使用绝对路径做cdn加速)
	'front_static' => 'static/',

	// 后台
	'admin_static' => '../static/',

	'url_suffix' => '.html',
	'version' => '2.0.3',			// 版本号
	'release' => '20140505',		// 发布日期
);
