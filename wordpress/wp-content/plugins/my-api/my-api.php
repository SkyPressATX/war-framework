<?php
/**
 * Plugin Name:     My Api
 * Plugin URI:      PLUGIN SITE HERE
 * Description:     PLUGIN DESCRIPTION HERE
 * Author:          YOUR NAME HERE
 * Author URI:      YOUR SITE HERE
 * Text Domain:     my-api
 * Domain Path:     /languages
 * Version:         0.1.0
 *
 * @package         My_Api
 */

 require_once __DIR__ . '/vendor/autoload.php';

 use WAR\Api as WAR_Api;

 function my_init(){
 	// Init the WAR Api
 	$war_api = new WAR_Api;
 	$war_api->init();
 }

 // Extend the War API
 add_action( 'plugins_loaded', 'my_init' );
