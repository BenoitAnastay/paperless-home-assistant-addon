server {
    listen {{ .interface }}:8099 default_server;

    include /etc/nginx/includes/server_params.conf;

    allow   172.30.32.2;
    deny    all;
}
