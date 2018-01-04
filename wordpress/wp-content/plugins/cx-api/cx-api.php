<?php
/**
 * Plugin Name:     CX API
 * Description:     Customer Experience API
 * Author:          BMO
 * Version:         0.1.0
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
