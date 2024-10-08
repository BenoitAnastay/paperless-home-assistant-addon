[supervisord]
nodaemon=true               ; start in foreground if true; default false
logfile=/var/log/supervisord/supervisord.log ; main log file; default $CWD/supervisord.log
pidfile=/var/run/supervisord/supervisord.pid ; supervisord pidfile; default supervisord.pid
logfile_maxbytes=50MB        ; max main logfile bytes b4 rotation; default 50MB
logfile_backups=10           ; # of main logfile backups; 0 means none, default 10
loglevel=info                ; log level; default info; others: debug,warn,trace
user=root

[program:gunicorn]
command=gunicorn -c /usr/src/paperless/gunicorn.conf.py paperless.asgi:application
user=paperless
priority = 1
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment = HOME="/usr/src/paperless",USER="paperless"

[program:gunicorn-ingress]
command=gunicorn -c /usr/src/paperless/gunicorn-ingress.conf.py paperless.asgi:application
user=paperless
priority = 1
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment = HOME="/usr/src/paperless",USER="paperless",PAPERLESS_FORCE_SCRIPT_NAME="{{ .ingress_entry }}",PAPERLESS_ENABLE_HTTP_REMOTE_USER_API="{{ .ingress_auth }}",PAPERLESS_ENABLE_HTTP_REMOTE_USER="{{ .ingress_auth }}"

[program:consumer]
command=python3 manage.py document_consumer
user=paperless
stopsignal=INT
priority = 20
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment = HOME="/usr/src/paperless",USER="paperless"

[program:celery]

command = celery --app paperless worker --loglevel INFO --without-mingle --without-gossip
user=paperless
stopasgroup = true
stopwaitsecs = 60
priority = 5
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment = HOME="/usr/src/paperless",USER="paperless"

[program:celery-beat]

command = celery --app paperless beat --loglevel INFO
user=paperless
stopasgroup = true
priority = 10
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment = HOME="/usr/src/paperless",USER="paperless"

[program:celery-flower]
command = /usr/local/bin/flower-conditional.sh
user = paperless
startsecs = 0
priority = 40
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment = HOME="/usr/src/paperless",USER="paperless"