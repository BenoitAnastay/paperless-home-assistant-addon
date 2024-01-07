server {
    listen {{ .interface }}:8099 default_server;

    location / {
        return 200 'Ingress is disabled because you opended a port';
        default_type text/plain;
    }

    allow   172.30.32.2;
    deny    all;
}