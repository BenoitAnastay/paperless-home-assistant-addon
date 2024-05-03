server {
    listen {{ .interface }}:8099 default_server;

    include /etc/nginx/includes/server_params.conf;

    location / {
        # Adjust host and port as required.
        proxy_pass http://localhost:8001/;

        # These configuration options are required for WebSockets to work.
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_set_header Origin "http://ingress.local";
        add_header Referrer-Policy "strict-origin-when-cross-origin";
    }

    allow   172.30.32.2;
    deny    all;
}
