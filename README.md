# Examen Final - Servicios Telemáticos
## Despliegue Seguro, Monitoreo y Visualización de una Aplicación Web en la Nube

**Universidad Autónoma de Occidente**  
**Estudiantes:** Juan Felipe Plata Barbosa y Maryori Lasso Diaz
**Fecha:** 18 de Noviembre de 2025

---

## Descripción del Proyecto

Este proyecto implementa el despliegue completo de una aplicación web Flask con MySQL, utilizando contenedorización con Docker, infraestructura en AWS EC2, monitoreo con Prometheus y Node Exporter, y visualización de métricas con Grafana.

**Topología del Sistema:**
- **Aplicación:** Flask (Python) servida a través de Apache como reverse proxy
- **Base de Datos:** MySQL 8.0
- **Contenedorización:** Docker + Docker Compose
- **Seguridad:** Certificados SSL autofirmados con OpenSSL
- **Monitoreo:** Prometheus + Node Exporter
- **Visualización:** Grafana
- **Infraestructura:** AWS EC2 t2.micro con Ubuntu 22.04

---

## Sección 1: Empaquetado y Despliegue Local con Docker (1.5 puntos)

Se creó un Dockerfile basado en Python 3.9 que incluye Apache HTTP Server con mod_ssl habilitado. Para gestionar múltiples procesos (Flask y Apache) en un mismo contenedor se utilizó Supervisord. Los certificados SSL se generaron con OpenSSL y se configuró redirección automática de HTTP a HTTPS.

El archivo docker-compose.yml orquesta dos servicios: la base de datos MySQL y la aplicación web. Se implementó un healthcheck para MySQL que verifica la disponibilidad del servicio antes de iniciar la aplicación.

La aplicación se desplegó localmente y fue accesible mediante HTTPS en localhost.

---

## Sección 2: Despliegue en AWS EC2 (1.0 punto)

Se creó una instancia EC2 tipo t2.micro con Ubuntu 22.04 en AWS Academy Learner Lab. El Security Group se configuró para permitir tráfico en los puertos 22 (SSH), 80 (HTTP), 443 (HTTPS), 3000 (Grafana), 9090 (Prometheus) y 9100 (Node Exporter).

Después de instalar Docker y Docker Compose en la instancia, se clonó el repositorio desde GitHub. Los certificados SSL se regeneraron incluyendo la IP pública de la instancia EC2 (44.220.163.23) para evitar advertencias de seguridad en el navegador.

La aplicación se desplegó exitosamente y quedó accesible públicamente a través de la IP de AWS.

---

## Sección 3: Monitoreo con Prometheus y Node Exporter (1.5 puntos)

### Instalación y Configuración

Se instalaron Prometheus 2.48.0 y Node Exporter 1.7.0 descargando los binarios desde los repositorios oficiales de GitHub. Prometheus se configuró para recolectar métricas cada 15 segundos tanto de sí mismo como del Node Exporter.

### Tres Métricas Documentadas

**1. node_cpu_seconds_total**  
Mide el tiempo acumulado que cada CPU ha pasado en diferentes modos de operación (user, system, idle, iowait). Esta métrica permite calcular el porcentaje de uso de CPU y detectar procesos que consumen recursos excesivamente. En producción, un uso sostenido superior al 80% indica la necesidad de escalar recursos.

**2. node_memory_MemAvailable_bytes**  
Indica la cantidad de memoria RAM disponible para asignar a procesos sin recurrir a swap. Es fundamental para prevenir situaciones de falta de memoria (OOM) que pueden causar caídas del sistema. Cuando la memoria disponible cae por debajo del 15%, el rendimiento se degrada significativamente.

**3. node_filesystem_avail_bytes**  
Muestra el espacio disponible en el sistema de archivos. Permite prevenir errores críticos causados por disco lleno, como la imposibilidad de escribir logs o el crecimiento de bases de datos. Una alerta cuando el uso supera el 80% permite tomar acciones preventivas.

### Configuración de Alertas

Se crearon tres alertas en el archivo alert_rules.yml:
- HighCPUUsage: Se activa cuando el CPU supera el 80% durante 2 minutos
- HighMemoryUsage: Se activa cuando la memoria supera el 85% durante 2 minutos
- HighDiskUsage: Se activa cuando el disco supera el 80% durante 2 minutos

Prometheus quedó accesible en el puerto 9090 y Node Exporter en el puerto 9100.

---

## Sección 4: Visualización con Grafana (1.0 punto)

Se instaló Grafana 10.2.2 descargando el tarball desde el sitio oficial. Después de iniciar el servidor, se configuró Prometheus como data source apuntando a localhost:9090.

Se creó un dashboard personalizado con tres paneles:
- Panel de uso de CPU (gráfico de series de tiempo)
- Panel de uso de memoria (gauge)
- Panel de uso de disco (stat panel)

Adicionalmente, se importó el dashboard oficial "Node Exporter Full" (ID: 1860) desde la biblioteca de Grafana, que proporciona visualizaciones completas de CPU, RAM, disco, red y procesos del sistema.

Grafana quedó accesible en el puerto 3000 con credenciales admin/admin.

---

## Evidencias del Despliegue

Video corto que incluye:
- Contenedores Docker en ejecución (db y webapp)
- Aplicación web funcionando con HTTPS
- Interfaz de Prometheus mostrando targets activos
- Alertas configuradas en Prometheus
- Dashboard personalizado en Grafana con métricas en tiempo real
- Dashboard importado Node Exporter Full
- Consola de AWS EC2 con la instancia activa
- Security Group con las reglas de firewall

enlace al video en Youtube: https://youtu.be/J1ae6yJQe78

---

## Conclusión Técnica

### ¿Qué aprendí al integrar Docker, AWS y Prometheus?

La integración de estas tecnologías permitió comprender el flujo completo de despliegue de aplicaciones modernas. Docker garantiza que la aplicación funcione de manera consistente en cualquier entorno, eliminando el problema de "funciona en mi máquina". La configuración mediante archivos (docker-compose.yml, prometheus.yml) facilita la replicación y automatización de infraestructura.

El despliegue en AWS expuso la realidad de trabajar con infraestructura en la nube, incluyendo la configuración de seguridad mediante Security Groups y la gestión de acceso remoto. La implementación de SSL/TLS demostró la importancia de la seguridad en comunicaciones, aunque en producción se utilizarían certificados de autoridades certificadoras reconocidas.

Prometheus proporcionó visibilidad sobre el estado del sistema mediante métricas. La diferencia entre tener monitoreo básico y observabilidad completa es significativa: no solo saber que algo falló, sino entender qué, cuándo y por qué ocurrió el problema.

### ¿Qué fue lo más desafiante y cómo lo resolvería en un entorno real?

El principal desafío fue la limitación de espacio en disco de la instancia t2.micro (8GB). Durante la instalación de Grafana, el disco se llenó completamente, causando que la extracción de archivos fallara. Fue necesario eliminar archivos tar.gz descargados y ejecutar limpieza de recursos de Docker para liberar espacio. En producción, esto se resolvería utilizando volúmenes EBS adicionales y configurando retención limitada de métricas en Prometheus.

Otro problema significativo fue el cambio de IP pública cada vez que se reiniciaba el laboratorio de AWS Academy. Esto requería regenerar los certificados SSL con la nueva IP. En un entorno real, se utilizaría una Elastic IP estática junto con un dominio registrado, y los certificados SSL estarían vinculados al nombre de dominio en lugar de la IP.

La gestión de múltiples procesos en Docker mediante Supervisord funcionó pero va contra las mejores prácticas. En producción se implementaría una arquitectura de microservicios donde cada componente (Nginx, Flask, MySQL) estaría en contenedores separados, orquestados con Kubernetes para alta disponibilidad y escalabilidad.

La pérdida de configuración al reinstalar Grafana evidenció la falta de persistencia de datos. En producción se utilizaría Grafana provisioning para definir dashboards como código, backups automatizados de la base de datos, y volúmenes persistentes para todos los servicios críticos.

Finalmente, todo el proceso fue manual vía SSH. En un entorno real se implementaría CI/CD con GitHub Actions o Jenkins para automatizar el build, testing y despliegue. La infraestructura se definiría con Terraform, y la configuración de servidores se manejaría con Ansible.

### ¿Qué beneficio aporta la observabilidad en el ciclo DevOps?

La observabilidad transforma la forma en que se operan los sistemas. Sin métricas, los problemas se descubren cuando los usuarios reportan fallas, lo cual es reactivo y causa mala experiencia. Con observabilidad, las alertas detectan anomalías antes de que impacten a los usuarios.

La capacidad de correlacionar métricas acelera la resolución de problemas. Por ejemplo, si el tiempo de respuesta aumenta, se puede verificar si coincide con alto uso de CPU, memoria limitada o queries lentas a la base de datos. Esto reduce el tiempo de diagnóstico de horas a minutos.

Las decisiones técnicas se basan en datos reales en lugar de suposiciones. La pregunta "¿necesitamos más recursos?" se responde observando tendencias de uso. Si la memoria crece linealmente, se puede predecir cuándo se agotará y planificar el escalado proactivamente.

La observabilidad también permite optimización continua. Las métricas exponen ineficiencias que no son evidentes sin medición, como endpoints que tardan mucho más que otros, o recursos que se desperdician. Esto facilita la mejora constante del sistema.

En pipelines CI/CD avanzados, las métricas pueden validar automáticamente la salud del sistema después de un despliegue. Si se detecta un aumento en la tasa de errores, se puede ejecutar un rollback automático antes de que afecte a muchos usuarios.

Finalmente, para cumplir con acuerdos de nivel de servicio (SLAs), se necesitan métricas precisas y verificables. La observabilidad proporciona evidencia objetiva del rendimiento y disponibilidad del sistema.

---

## Instrucciones de Replicación

### Despliegue Local
1. Clonar el repositorio desde GitHub
2. Ejecutar `docker-compose up -d --build`
3. Acceder a https://localhost

### Despliegue en AWS EC2
1. Crear instancia EC2 Ubuntu 22.04 t2.micro
2. Configurar Security Group con puertos 22, 80, 443, 3000, 9090, 9100
3. Instalar Docker y Docker Compose
4. Clonar repositorio y regenerar certificados SSL con la IP pública
5. Desplegar con `docker-compose up -d --build`
6. Instalar y ejecutar Prometheus, Node Exporter y Grafana
7. Configurar Grafana con Prometheus como data source

---

## Estructura del Repositorio

```
Parcial-Final-Servicios-Telematicos/
├── Dockerfile
├── docker-compose.yml
├── apache-ssl.conf
├── supervisord.conf
├── localhost.crt
├── localhost.key
├── init.sql
├── prometheus.yml
├── alert_rules.yml
├── README.md
└── webapp/
    ├── config.py
    ├── run.py
    └── ...
```

---

## Autores

**Juan Plata y Maryori Lasso**  
Universidad Autónoma de Occidente  
Ingeniería Informática  
Noviembre 2025
