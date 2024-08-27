server {
    {{ if not .ssl }}
    listen 80 default_server;
    {{ else }}
    listen 80 default_server ssl http2;
    {{ end }}

    include /etc/nginx/includes/server_params.conf;

    location / {
        # Adjust host and port as required.
        proxy_pass http://localhost:8000/;

        # These configuration options are required for WebSockets to work.
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host:{{ .port }};
        proxy_hide_header X-Remote-User-Display-Name;
        proxy_hide_header X-Remote-User-Name;
        proxy_hide_header X-Remote-User-Id;
        add_header Referrer-Policy "strict-origin-when-cross-origin";
    }

    {{ if .ssl }}
    include /etc/nginx/includes/ssl_params.conf;

    ssl_certificate /ssl/{{ .certfile }};
    ssl_certificate_key /ssl/{{ .keyfile }};
    {{ end }}
}
