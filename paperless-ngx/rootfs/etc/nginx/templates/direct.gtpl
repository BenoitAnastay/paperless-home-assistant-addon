server {
    {{ if not .ssl }}
    listen 80 default_server;
    {{ else }}
    listen 80 default_server ssl http2;
    {{ end }}

    include /etc/nginx/includes/server_params.conf;

    {{ if .ssl }}
    include /etc/nginx/includes/ssl_params.conf;

    ssl_certificate /ssl/{{ .certfile }};
    ssl_certificate_key /ssl/{{ .keyfile }};
    {{ end }}
}
