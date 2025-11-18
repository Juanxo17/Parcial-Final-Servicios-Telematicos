# Use official Python image with Apache support
FROM python:3.9-slim

# Install system dependencies
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

# Create application directory
WORKDIR /var/www/html

# Copy application files
COPY webapp/ /var/www/html/

# Install Python dependencies
RUN pip install --no-cache-dir Flask==2.3.3 \
    flask-cors \
    Flask-MySQLdb \
    Flask-SQLAlchemy

# Copy SSL certificates
COPY localhost.crt /etc/ssl/certs/localhost.crt
COPY localhost.key /etc/ssl/private/localhost.key

# Set proper permissions for SSL certificates
RUN chmod 644 /etc/ssl/certs/localhost.crt && \
    chmod 600 /etc/ssl/private/localhost.key

# Copy Apache configuration
COPY apache-ssl.conf /etc/apache2/sites-available/apache-ssl.conf

# Enable Apache modules
RUN a2enmod ssl && \
    a2enmod headers && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod rewrite && \
    a2dissite 000-default default-ssl && \
    a2ensite apache-ssl

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 80 443 5000

# Set environment variable
ENV FLASK_APP=run.py

# Start supervisor to manage Apache and Flask
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]