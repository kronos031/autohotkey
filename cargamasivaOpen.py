#!/usr/bin/env python3
"""
Script para cargar datos JSON a OpenSearch
Configurar las variables de conexión antes de ejecutar
Ejemplo de uso
python c:/Users/miguelrobles/Desktop/autohotkey/cargamasivaOpen.py "C:\Users\miguelrobles\Desktop\autohotkey\mi_archivo.json"
"""

import json
import requests
from requests.auth import HTTPBasicAuth
import sys
from typing import Dict, Any

# Configuración de OpenSearch
OPENSEARCH_CONFIG = {
    'host': 'https://localhost:9200/',  # Cambiar por tu dominio
    'username': 'admin',  # Opcional, si usas autenticación
    'password': 'admin',  # Opcional, si usas autenticación
    'verify_ssl': False
}

def load_json_file(file_path: str) -> Dict[str, Any]:
    """Carga el archivo JSON con los datos"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo {file_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error al parsear JSON: {e}")
        sys.exit(1)

def prepare_bulk_data(hits_data: list) -> str:
    """Prepara los datos en formato bulk para OpenSearch"""
    bulk_data = ""
    
    for hit in hits_data:
        doc_id = hit['_id']
        doc_source = hit['_source']
        index_name = hit['_index']
        
        # Línea de metadatos para el índice
        index_metadata = json.dumps({
            "index": {
                "_index": index_name,
                "_id": doc_id
            }
        })
        
        # Línea con el documento
        document_data = json.dumps(doc_source)
        
        bulk_data += index_metadata + "\n" + document_data + "\n"
    
    return bulk_data

def upload_to_opensearch_bulk(bulk_data: str) -> bool:
    """Sube los datos usando la API bulk de OpenSearch"""
    url = f"{OPENSEARCH_CONFIG['host']}/_bulk"
    
    headers = {
        'Content-Type': 'application/json'
    }
    
    # Configurar autenticación si es necesaria
    auth = None
    if OPENSEARCH_CONFIG.get('username') and OPENSEARCH_CONFIG.get('password'):
        auth = HTTPBasicAuth(OPENSEARCH_CONFIG['username'], OPENSEARCH_CONFIG['password'])
    
    try:
        response = requests.post(
            url,
            data=bulk_data,
            headers=headers,
            auth=auth,
            verify=OPENSEARCH_CONFIG['verify_ssl']
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('errors'):
                print("Algunos documentos tuvieron errores:")
                for item in result['items']:
                    if 'error' in item.get('index', {}):
                        print(f"Error en documento: {item['index']['error']}")
                return False
            else:
                print(f"✅ Todos los documentos se cargaron exitosamente")
                print(f"Documentos procesados: {len(result['items'])}")
                return True
        else:
            print(f"Error HTTP {response.status_code}: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"Error de conexión: {e}")
        return False

def upload_documents_individually(hits_data: list) -> bool:
    """Sube documentos uno por uno (alternativa al bulk)"""
    success_count = 0
    total_docs = len(hits_data)
    
    for i, hit in enumerate(hits_data, 1):
        doc_id = hit['_id']
        doc_source = hit['_source']
        index_name = hit['_index']
        
        url = f"{OPENSEARCH_CONFIG['host']}/{index_name}/_doc/{doc_id}"
        
        headers = {'Content-Type': 'application/json'}
        auth = None
        if OPENSEARCH_CONFIG.get('username') and OPENSEARCH_CONFIG.get('password'):
            auth = HTTPBasicAuth(OPENSEARCH_CONFIG['username'], OPENSEARCH_CONFIG['password'])
        
        try:
            response = requests.put(
                url,
                data=json.dumps(doc_source),
                headers=headers,
                auth=auth,
                verify=OPENSEARCH_CONFIG['verify_ssl']
            )
            
            if response.status_code in [200, 201]:
                success_count += 1
                print(f"✅ Documento {i}/{total_docs} cargado: {doc_id}")
            else:
                print(f"❌ Error en documento {doc_id}: {response.status_code} - {response.text}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Error de conexión para documento {doc_id}: {e}")
    
    print(f"\nResumen: {success_count}/{total_docs} documentos cargados exitosamente")
    return success_count == total_docs

def main():
    """Función principal"""
    if len(sys.argv) < 2:
        print("Uso: python opensearch_loader.py <archivo_json> [--individual]")
        print("  --individual: Cargar documentos uno por uno en lugar de usar bulk API")
        sys.exit(1)
    
    file_path = sys.argv[1]
    use_individual = '--individual' in sys.argv
    
    # Cargar datos
    print(f"📁 Cargando datos desde {file_path}...")
    data = load_json_file(file_path)
    
    if 'hits' not in data or 'hits' not in data['hits']:
        print("Error: El archivo no tiene la estructura esperada de Elasticsearch/OpenSearch")
        sys.exit(1)
    
    hits_data = data['hits']['hits']
    total_docs = len(hits_data)
    
    print(f"📊 Se encontraron {total_docs} documentos para cargar")
    
    # Verificar configuración
    if OPENSEARCH_CONFIG['host'] == 'https://localhost:9200':
        print("⚠️  ADVERTENCIA: Debes configurar el host de OpenSearch en el script")
        print("   Edita la variable OPENSEARCH_CONFIG en la parte superior del script")
        sys.exit(1)
    
    # Cargar documentos
    print(f"🚀 Iniciando carga a OpenSearch...")
    
    if use_individual:
        print("Método: Carga individual")
        success = upload_documents_individually(hits_data)
    else:
        print("Método: Bulk API")
        bulk_data = prepare_bulk_data(hits_data)
        success = upload_to_opensearch_bulk(bulk_data)
    
    if success:
        print("🎉 ¡Carga completada exitosamente!")
    else:
        print("❌ La carga falló o tuvo errores")
        sys.exit(1)

if __name__ == "__main__":
    main()