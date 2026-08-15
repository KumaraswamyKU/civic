#!/bin/sh
set -e

echo "Waiting for Postgres at ${POSTGRES_HOST:-db}:${POSTGRES_PORT:-5432}..."
while ! python -c "
import socket, os, sys
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(1)
try:
    s.connect((os.environ.get('POSTGRES_HOST', 'db'), int(os.environ.get('POSTGRES_PORT', 5432))))
except Exception:
    sys.exit(1)
"; do
  sleep 1
done
echo "Postgres is up."

python manage.py migrate --noinput
python manage.py collectstatic --noinput
python manage.py seed_departments

exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 3
