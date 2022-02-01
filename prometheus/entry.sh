#!/bin/sh
sed -i "s/PROMETHEUS_TARGETS/$PROMETHEUS_TARGETS/g" /app.cfg/prometheus.yml
exec /bin/prometheus \
--config.file=/app.cfg/prometheus.yml \
--storage.tsdb.path=/prometheus \
--web.console.libraries=/usr/share/prometheus/console_libraries \
--web.console.templates=/usr/share/prometheus/consoles

