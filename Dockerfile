FROM python:3.9-slim

RUN apt-get update && \
    apt-get install -y \
    apache2 \
    apache2-dev \
    libapache2-mod-wsgi-py3 \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
    default-mysql-client \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY webapp/ /var/www/html/

RUN pip install --no-cache-dir Flask==2.3.3 \
    flask-cors \
    Flask-MySQLdb \
    Flask-SQLAlchemy

COPY localhost.crt /etc/ssl/certs/localhost.crt
COPY localhost.key /etc/ssl/private/localhost.key

RUN chmod 644 /etc/ssl/certs/localhost.crt && \
    chmod 600 /etc/ssl/private/localhost.key

COPY apache-ssl.conf /etc/apache2/sites-available/apache-ssl.conf

RUN a2enmod ssl && \
    a2enmod headers && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod rewrite && \
    a2dissite 000-default default-ssl && \
    a2ensite apache-ssl

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 443 5000

ENV FLASK_APP=run.py

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]