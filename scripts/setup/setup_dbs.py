# COMANDO PARA EJECUTAR: "docker exec -it neo4j-setup python /scripts/setup/setup_dbs.py"

import time
from neo4j import GraphDatabase
from neo4j.exceptions import ServiceUnavailable, ClientError

USER = "neo4j"
PASSWORD = "password"

NODES_CONFIG = [
    {"name": "fog1", "uri": "neo4j://neo4j-fog1-a:7687", "queries": ["CREATE DATABASE fog1 TOPOLOGY 3 PRIMARY"]},
    {"name": "fog2", "uri": "neo4j://neo4j-fog2-a:7687", "queries": ["CREATE DATABASE fog2 TOPOLOGY 3 PRIMARY"]},
    {"name": "fog3", "uri": "neo4j://neo4j-fog3-a:7687", "queries": ["CREATE DATABASE fog3 TOPOLOGY 3 PRIMARY"]},
    {
        "name": "composite", 
        "uri": "bolt://neo4j-composite:7687", 
        "queries": [
            "CREATE COMPOSITE DATABASE composite",
            "CREATE ALIAS composite.fog1 FOR DATABASE fog1 AT 'neo4j+ssc://neo4j-cluster-1:7687' USER neo4j PASSWORD 'password'",
            "CREATE ALIAS composite.fog2 FOR DATABASE fog2 AT 'neo4j+ssc://neo4j-cluster-2:7687' USER neo4j PASSWORD 'password'",
            "CREATE ALIAS composite.fog3 FOR DATABASE fog3 AT 'neo4j+ssc://neo4j-cluster-3:7687' USER neo4j PASSWORD 'password'"
        ]
    }
]

def execute_config():
    for node in NODES_CONFIG:
        print(f"\n--- Configurando Nodo: {node['name']} ---")
        try:
            driver = GraphDatabase.driver(node["uri"], auth=(USER, PASSWORD))
            with driver.session(database="system") as session:
                for q in node["queries"]:
                    try:
                        session.run(q)
                        print(f"OK: {q}")
                    except ClientError as e:
                        if "already exists" in str(e).lower():
                            print(f"INFO: Ya existe.")
                        else:
                            print(f"ERROR: {e}")
            driver.close()
        except Exception as e:
            print(f"No se pudo conectar a {node['name']}: {e}")

if __name__ == "__main__":
    print("Iniciando configuración de Neo4j...")
    execute_config()
    print("\nProceso finalizado.")