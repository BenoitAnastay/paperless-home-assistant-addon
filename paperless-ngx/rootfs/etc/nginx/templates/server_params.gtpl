server_name     $hostname;

add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header X-Robots-Tag none;

client_max_body_size {{or .max_upload "30"}}M;
