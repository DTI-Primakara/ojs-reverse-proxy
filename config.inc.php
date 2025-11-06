; <?php exit(); // DO NOT DELETE 
  ?>
; Environment-aware OJS config.inc.php
; Primakara E-Journal

<?php
function env($key, $default = null)
{
  $val = getenv($key);
  return ($val !== false && $val !== '') ? $val : $default;
}
?>

[general]
installed = Off
base_url = "<?php echo env('OJS_BASE_URL', 'http://localhost'); ?>"
time_zone = "<?php echo env('OJS_TIMEZONE', 'UTC'); ?>"
restful_urls = On
trust_x_forwarded_for = On
enable_minified = On
enable_beacon = On

[database]
driver = mysqli
host = "<?php echo env('OJS_DB_HOST', 'localhost'); ?>"
username = "<?php echo env('OJS_DB_USER', 'ojs'); ?>"
password = "<?php echo env('OJS_DB_PASSWORD', 'ojs'); ?>"
name = "<?php echo env('OJS_DB_NAME', 'ojs'); ?>"
debug = Off

[files]
files_dir = "<?php echo env('OJS_FILES_DIR', '/var/www/files'); ?>"
public_files_dir = public
umask = 0022

[security]
force_ssl = On
session_check_ip = On
salt = "<?php echo env('OJS_SALT', 'YouMustSetASecretKeyHere!!'); ?>"
api_key_secret = "<?php echo env('OJS_API_KEY_SECRET', ''); ?>"

[email]
smtp = Off
smtp_server = "<?php echo env('OJS_SMTP_SERVER', ''); ?>"
smtp_port = "<?php echo env('OJS_SMTP_PORT', '587'); ?>"
smtp_auth = "<?php echo env('OJS_SMTP_AUTH', 'tls'); ?>"
smtp_username = "<?php echo env('OJS_SMTP_USERNAME', ''); ?>"
smtp_password = "<?php echo env('OJS_SMTP_PASSWORD', ''); ?>"
default_envelope_sender = "<?php echo env('OJS_MAIL_FROM', 'admin@localhost'); ?>"

[oai]
oai = On
oai_max_records = 100
repository_id = "<?php echo env('OJS_REPOSITORY_ID', 'ojs.local'); ?>"
