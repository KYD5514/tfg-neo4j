# 📄 Guía de Instalación y Despliegue del Proyecto

Esta guía explica cómo desplegar y probar el entorno Docker que integra Neo4j y HAProxy. Está pensada para ser fácilmente reutilizable para futuros proyectos.

---

## ✅ Requisitos previos

- Docker instalado --> https://www.docker.com/products/docker-desktop/
- Git instalado --> https://git-scm.com/downloads
- Conexión a internet

---

## 🚀 Despliegue del entorno

1. **Clonar el repositorio:**

   ```bash
   git clone https://github.com/KYD5514/tfg-neo4j.git
   cd tfg-neo4j
   ```

2. **Generación de certificados y keystore:**

   ```bash
   scripts/fogX/gen-certs-clusterX.sh
   ```

   ```docker run --rm -v "${PWD}/certs/composite:/tmp/certs" eclipse-temurin:17-jre keytool -genseckey -keyalg AES -keysize 256 -storetype pkcs12 -keystore /tmp/certs/keystore.jks -alias neo4j -storepass password -keypass password

   ```

3. **Arrancar el entorno:**

   ```bash
   docker-compose up -d
   ```

4. **Creación de las bases de datos:**

   ```docker exec -it neo4j-setup python ./scripts/setup/setup_dbs.py

   ```

5. **Poblar las bases de datos de cada nodo Fog desde el contenedor neo4j-dev-iomt:**

   ```docker exec -it neo4j-dev-iomt bash

   ```

   ```cypher-shell -a neo4j://ha-proxy-X:7687 -u neo4j -p password -d fogX -f ./scripts/fogX/poblar_fogX.cypher

   ```

---

## 📂 Estructura de carpetas

```
.
├── docker-compose.yml
├── guia-instalacion.md
├── certs
│   ├── bolt
│   │   └── fog1-a
│   |   |   ├── private.key
│   |   |   └── public.crt
│   │   └── fog1-b
│   |   |   ├── private.key
│   |   |   └── public.crt
│   │   └── fog1-c
│   |   |   ├── private.key
│   |   |   └── public.crt
│   │   └── fog2-a
│   |   |   ├── private.key
│   |   |   └── public.crt
│   │   └── ...
│   ├── composite
│   │   └── keystore.jks
├── datasets
│   ├── synthea_sample_data_csv_latest_original.zip
│   └── synthea_sample_data_csv_latest_usado.zip
├── import
│   ├── allergies.csv
│   └── careplans.csv
│   ├── conditions.csv
│   └── devices.csv
│   ├── encounters.csv
│   └── immunizations.csv
│   ├── medications.csv
│   └── observations.csv
│   ├── organizations.csv
│   └── patients.csv
│   ├── procedures.csv
│   └── providers.csv
├── scripts
│   ├── fog1
│   │   └── gen-certs-cluster1.sh
│   │   └── haproxy1.cfg
│   │   └── poblar_fog1.cypher
│   ├── fog2
│   │   └── gen-certs-cluster2.sh
│   │   └── haproxy2.cfg
│   │   └── poblar_fog2.cypher
│   ├── fog3
│   │   └── gen-certs-cluster3.sh
│   │   └── haproxy3.cfg
│   │   └── poblar_fog3.cypher
│   ├── setup
│   │   └── modelo_bbdd.cypher
│   │   └── setup_bds.py
├── plugins
    └── graph-data-science.jar

```

---
