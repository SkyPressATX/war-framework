<!doctype html>
<html <?php language_attributes(); ?> >
<head>
  <meta charset="<?php bloginfo( 'charset' ); ?>" />
  <title><?php get_bloginfo( 'name' ); ?></title>
  <base href="/">

  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" type="image/x-icon" href="favicon.ico">
  <?php wp_head(); ?>
</head>
<body <?php body_class(); ?> >
    <app-root></app-root>
    <?php wp_footer(); ?>
</body>
</html>
