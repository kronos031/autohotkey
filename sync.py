#!/usr/bin/env python3
"""
Script para sincronizar proyectos específicos  a todos los otros bancos
Sincroniza: entity, mapper, model, repository, service
NO toca: constants (específicas por banco)
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path
from datetime import datetime

class MultiProjectSyncer:
    def __init__(self):
        # Ruta base donde están todos los proyectos
        self.base_path = Path(r'C:\Users\miguelrobles\Desktop\SPI\V3')
        
        # Banco fuente  
        self.source_bank =   input("Ingrese la entidad origen: ").lower().strip()
        
        # Bancos destino con sus códigos
        self.target_banks = {
            
             "BBOG": "bbog",
             "BOCC": "bocc",
             "BPOP": "bpop",
            "DALE": "dale" 
            
        }
        
        # Carpetas que SÍ se sincronizan (lógica de negocio)
        self.sync_folders = [
            'entity', 
            'mapper', 
            'model',
            'repository',
            'service',
            'util',
            'test'
        ]
        
        # Carpetas que NO se tocan (específicas por banco)
        self.exclude_folders = [
            'constants'
        ]
        
        # Archivos específicos a excluir
        self.exclude_files = [
            'application.properties',
            'application.yml',
            'application.yaml',
            'config.properties',
            'bootstrap.properties'
        ]
    
    def get_available_projects(self):
        """
        Obtiene la lista de proyectos disponibles 
        """
        source_path = self.base_path / self.source_bank
        
        if not source_path.exists():
            return []
        
        projects = []
        for item in source_path.iterdir():
            if item.is_dir() and not item.name.startswith('.'):
                # Verificar que el proyecto tenga la estructura Java esperada
                
                    projects.append(item.name)
        
        return sorted(projects)
    
    def has_java_structure(self, project_path):
        """
        Verifica si un proyecto tiene la estructura Java esperada
        """
        java_src = self.find_java_source(project_path)
        if not java_src:
            return False
        
        # Verificar que al menos una de las carpetas sync_folders existe
        for folder in self.sync_folders:
            if (java_src / folder).exists():
                return True
        
        return False
    
    def get_target_project_name(self, entity_project_name, target_bank_code):
        """
        Convierte el nombre del proyecto al nombre correspondiente en el banco destino
        """        
        # Si no termina con '-bavv', agregar el código del banco destino
        return entity_project_name[:-5] + f'-{target_bank_code}'
    
    def sync_specific_project(self, project_name):
        """
        Sincroniza un proyecto específico desde ORIGEN a todos los bancos
        """
        print(f"🎯 Sincronizando proyecto: {project_name}")
        print(f"📋 Carpetas a sincronizar: {', '.join(self.sync_folders)}")
        print(f"🚫 Carpetas excluidas: {', '.join(self.exclude_folders)}")
        print(f"🎯 Bancos destino: {', '.join(self.target_banks.keys())}")
        print("=" * 60)
        
        # Verificar que el proyecto existe 
        source_project_path = self.base_path / self.source_bank / project_name
        if not source_project_path.exists():
            print(f"❌ Error: El proyecto '{project_name}' no existe en {self.source_bank}")
            return False
        
        # Verificar bancos destino disponibles
        available_banks = []
        missing_banks = []
        
        for bank_name, bank_code in self.target_banks.items():
            bank_path = self.base_path / bank_name
            if bank_path.exists():
                # Generar el nombre del proyecto para este banco
                target_project_name = project_name[:-5] + f'-{bank_code}'
                
                target_project_path = bank_path / target_project_name
                
                if target_project_path.exists():
                    available_banks.append((bank_name, bank_code, target_project_name))
                    print(f"✅ Encontrado: {bank_name}/{target_project_name}")
                else:
                    print(f"⚠️  Proyecto '{target_project_name}' no encontrado en {bank_name}")
                    missing_banks.append(f"{bank_name} ({target_project_name})")
            else:
                print(f"⚠️  Banco '{bank_name}' no encontrado")
                missing_banks.append(bank_name)
        
        if not available_banks:
            print("❌ No hay bancos disponibles para sincronizar")
            return False
        
        if missing_banks:
            print(f"⚠️  Bancos/proyectos no encontrados: {', '.join(missing_banks)}")
            response = input("¿Continuar con los bancos disponibles? (s/n): ").lower().strip()
            if response not in ['s', 'y', 'yes', 'si']:
                print("❌ Operación cancelada")
                return False
        
        # Confirmar operación
        print(f"\n🔄 Se sincronizará el proyecto '{project_name}' en {len(available_banks)} bancos")
        print("📦 Mapeo de proyectos:")
        for bank_name, bank_code, target_project_name in available_banks:
            print(f"   {self.source_bank}/{project_name} → {bank_name}/{target_project_name}")
        
        if not self.confirm_operation(project_name):
            print("❌ Operación cancelada")
            return False
        
        # Realizar sincronización
        success_count = 0
        print("\n🚀 Iniciando sincronización...")
        print("-" * 60)
        
        for bank_name, bank_code, target_project_name in available_banks:
            target_project_path = self.base_path / bank_name / target_project_name
            
            print(f"📁 Sincronizando: {self.source_bank}/{project_name} → {bank_name}/{target_project_name}")
            
            try:
                self.sync_single_project(source_project_path, target_project_path)
                success_count += 1
                print(f"✅ Completado: {bank_name}/{target_project_name}")
            except Exception as e:
                print(f"❌ Error en {bank_name}/{target_project_name}: {str(e)}")
            
            print()
        
        # Resumen final
        print("-" * 60)
        print(f"✨ Sincronización completada: {success_count}/{len(available_banks)} proyectos actualizados")
        print(f"⏰ Completado: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        return success_count > 0
    
      
    
    def sync_specific_project_silent(self, project_name):
        """
        Sincroniza un proyecto específico sin confirmaciones (para uso interno)
        """
        source_project_path = self.base_path / self.source_bank / project_name
        
        if not source_project_path.exists():
            return False
        
        # Obtener bancos disponibles para este proyecto
        available_banks = []
        for bank_name, bank_code in self.target_banks.items():
            target_project_name = project_name[:-5] + f'-{bank_code}' 
            target_project_path = self.base_path / bank_name / target_project_name
            if target_project_path.exists():
                available_banks.append((bank_name, bank_code, target_project_name))
        
        if not available_banks:
            return False
        
        # Sincronizar con cada banco
        success_count = 0
        for bank_name, bank_code, target_project_name in available_banks:
            target_project_path = self.base_path / bank_name / target_project_name
            
            try:
                self.sync_single_project(source_project_path, target_project_path)
                success_count += 1
                print(f"  ✅ {bank_name}/{target_project_name}")
            except Exception as e:
                print(f"  ❌ {bank_name}/{target_project_name}: {str(e)}")
        
        return success_count > 0
    
    def sync_single_project(self, source_project_path, target_project_path):
   
        # Buscar carpeta src/main/java (o la raíz válida)
        java_src = self.find_java_source(source_project_path)
        target_java_src = self.find_java_source(target_project_path)

        if not java_src:
            raise Exception(f"No se encontró estructura Java válida en {source_project_path}")
        if not target_java_src:
            raise Exception(f"No se encontró estructura Java válida en {target_project_path}")
    
        print(f"🔍 Java source origen: {java_src}")
        print(f"🔍 Java source destino: {target_java_src}")
    
        synced_folders = 0
    
        for folder in self.sync_folders:
            # Para la carpeta 'test', buscar tanto en src/test/java como src/main/java/test
            if folder == 'test':
                # Buscar carpeta test en múltiples ubicaciones
                test_locations = []
                
                # Buscar src/test (estructura Maven estándar)
                src_test = source_project_path / 'src' / 'test'
                if src_test.exists():
                    test_locations.append(src_test)
                
                # Buscar test dentro de src/main/java (como en tu imagen)
                java_test = java_src / 'test'
                if java_test.exists():
                    test_locations.append(java_test)
                
                # Buscar recursivamente otras carpetas test
                other_tests = list(java_src.rglob('test'))
                for test_dir in other_tests:
                    if test_dir.is_dir() and test_dir not in test_locations:
                        test_locations.append(test_dir)
                
                # Sincronizar cada ubicación de test encontrada
                for source_test in test_locations:
                    # Determinar la ubicación correspondiente en el destino
                    if source_test == source_project_path / 'src' / 'test':
                        # Es src/test estándar
                        target_test = target_project_path / 'src' / 'test'
                    else:
                        # Es test dentro de java src, mantener estructura relativa
                        try:
                            rel_path = source_test.relative_to(java_src)
                            target_test = target_java_src / rel_path
                        except ValueError:
                            # Si no puede calcular ruta relativa, usar estructura similar
                            target_test = target_java_src / 'test'
                    
                    # Obtener archivos modificados con git  
                    modified_files = self.get_modified_files_from_git(source_project_path)
                    modified_relative_paths = [f.relative_to(source_project_path) for f in modified_files if f.is_file()]

                    self.sync_folder(source_test, target_test, modified_relative_paths, project_root=source_project_path)
                    synced_folders += 1
                    
            else:
                # Buscar todas las ocurrencias de esa carpeta en la estructura del proyecto
                source_subfolders = list(java_src.rglob(folder))
        
                if not source_subfolders:
                    print(f"    ⚠️  No encontrada: {folder}")
                    continue
                
                for source_subfolder in source_subfolders:
                    if source_subfolder.is_dir():
                        # Determinar ruta relativa para replicarla en el destino
                        rel_path = source_subfolder.relative_to(java_src)
                        target_folder = target_java_src / rel_path
        
                        # Obtener archivos modificados con git  
                        modified_files = self.get_modified_files_from_git(source_project_path)
                        modified_relative_paths = [f.relative_to(source_project_path) for f in modified_files if f.is_file()]

                        self.sync_folder(source_subfolder, target_folder, modified_relative_paths, project_root=source_project_path)

                        synced_folders += 1

        # NUEVO: Sincronizar archivos .java en la raíz del paquete principal
        # Buscar el paquete principal (co.com.ath en tu caso)
        main_package = None
        for item in java_src.iterdir():
            if item.is_dir() and item.name == "co":
                # Navegar hasta co/com/ath
                ath_package = item / "com" / "ath"
                if ath_package.exists():
                    main_package = ath_package
                    break
        
        if main_package:
            # Obtener archivos modificados
            modified_files = self.get_modified_files_from_git(source_project_path)
            modified_relative_paths = [f.relative_to(source_project_path) for f in modified_files if f.is_file()]
            
            # Sincronizar archivos .java en la raíz del paquete
            target_main_package = target_java_src / "co" / "com" / "ath"
            target_main_package.mkdir(parents=True, exist_ok=True)
            
            files_copied = 0
            for java_file in main_package.glob("*.java"):
                if modified_relative_paths:
                    try:
                        file_relative_path = java_file.relative_to(source_project_path)
                        if file_relative_path not in modified_relative_paths:
                            continue
                    except ValueError:
                        continue
                
                target_file = target_main_package / java_file.name
                shutil.copy2(java_file, target_file)
                files_copied += 1
                print(f"📄 Copiado (raíz): {java_file.name}")
            
            if files_copied > 0:
                
                synced_folders += 1
                
        if synced_folders == 0:
            raise Exception("No se sincronizó ninguna carpeta")

    
    def find_java_source(self, project_path):
    
        # Buscar src/main/java o src
        candidates = list(project_path.rglob("src/main/java")) or list(project_path.rglob("src"))

        for base in candidates:
            for folder in self.sync_folders:
                # Para 'test', también revisar ubicaciones estándar
                if folder == 'test':
                    # Revisar src/test (Maven estándar)
                    if (project_path / 'src' / 'test').exists():
                        return base
                    # Revisar test dentro de src/main/java
                    if (base / 'test').exists():
                        return base
                else:
                    # Buscar recursivamente si hay alguna de las carpetas relevantes
                    matches = list(base.rglob(folder))
                    if matches:
                        # Retorna el directorio padre común
                        return base
        
        return None
    
    def sync_folder(self, source_folder, target_folder, modified_relative_paths=None, project_root=None):
        target_folder.mkdir(parents=True, exist_ok=True)
        files_copied = 0
        
        modified_set = set(modified_relative_paths) if modified_relative_paths else None

        for source_file in source_folder.rglob("*"):
            if not source_file.is_file():
                continue

            if any(exclude in source_file.name for exclude in self.exclude_files):
                continue
            
            if project_root and modified_set is not None:
                try:
                    full_relative_path = source_file.relative_to(project_root)
                except ValueError:
                    continue  # archivo fuera del proyecto
                
                if full_relative_path not in modified_set:
                    continue
            
            relative_path = source_file.relative_to(source_folder)
            target_file = target_folder / relative_path
            target_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source_file, target_file)
            files_copied += 1
            print(f"📄 Copiado: {full_relative_path}")
       
       #LINEA PARA VER NUMERO DE ARCHIVOS COPIADOS 
      #  print(f"      📄 {files_copied} archivos copiados")


        
            
    def confirm_operation(self, project_name):
        """
        Confirma la operación con el usuario
        """
        print("\n" + "⚠️ " * 20)
        print(f"ATENCIÓN: Esta operación sobrescribirá archivos del proyecto '{project_name}'")
        print("Las carpetas 'constants' NO se tocarán (se mantendrán específicas por banco)")
        print("⚠️ " * 20)
        
        response = input(f"\n¿Continuar con la sincronización del proyecto '{project_name}'? (s/n): ").lower().strip()
        return response in ['s', 'y', 'yes', 'si']
    
    def interactive_project_selection(self):
        """
        Permite al usuario seleccionar un proyecto de forma interactiva
        """
        projects = self.get_available_projects()
        
        if not projects:
            print("❌ No se encontraron proyectos")
            return None
        
        print("\n📦 Proyectos disponibles:")
        print("-" * 40)
        
        for i, project in enumerate(projects, 1):
            print(f"{i:2d}. {project}")
         
        print(f"{len(projects) + 1:2d}. Salir")
        
        while True:
            try:
                choice = input(f"\nSelecciona un proyecto (1-{len(projects) + 1}): ").strip()
                
                if not choice:
                    continue
                
                choice = int(choice)
                
                if 1 <= choice <= len(projects):
                    return projects[choice - 1]
                elif choice == len(projects) + 1:
                    return "ALL"
                elif choice == len(projects) + 2:
                    return None
                else:
                    print(f"❌ Opción inválida. Selecciona entre 1 y {len(projects) + 1}")
                    
            except ValueError:
                print("❌ Por favor ingresa un número válido")
            except KeyboardInterrupt:
                print("\n❌ Operación cancelada")
                return None
    
    def list_projects_and_structure(self):
        """
        Lista todos los proyectos y su estructura para debugging
        """
        print("🔍 Analizando estructura de proyectos...")
        print("=" * 60)
        
        for bank_name in [self.source_bank] + list(self.target_banks.keys()):
            bank_path = self.base_path / bank_name
            print(f"\n🏦 Banco: {bank_name}")
            print(f"📁 Ruta: {bank_path}")
            
            if not bank_path.exists():
                print("❌ Carpeta no encontrada")
                continue
            
            projects = []
            for item in bank_path.iterdir():
                if item.is_dir() and not item.name.startswith('.'):
                    java_src = self.find_java_source(item)
                    if java_src:
                        sync_folders_found = [f for f in self.sync_folders if (java_src / f).exists()]
                        projects.append({
                            'name': item.name,
                            'java_src': java_src,
                            'sync_folders': sync_folders_found
                        })
            
            if projects:
                for project in projects:
                    print(f"  📦 {project['name']}")
                    print(f"    🗂️  Java src: {project['java_src']}")
                    print(f"    📂 Carpetas sync: {', '.join(project['sync_folders']) if project['sync_folders'] else 'Ninguna'}")
            else:
                print("  ❌ No se encontraron proyectos válidos")
                
    def get_modified_files_from_git(self, project_path):
        try:
            result = subprocess.run(
                ["git", "status", "--porcelain"],
                cwd=project_path,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=True
            )
            
            lines = result.stdout.splitlines()
            modified_files = []
            
            for line in lines:
                status_code = line[:2].strip()
                file_path = line[3:].strip()
                if status_code in {'M', 'A', 'AM', 'MM', 'R', 'C', 'RM', 'RC'}:
                    if status_code in {'M', 'A', 'AM', 'MM'}:
                        full_path = (project_path / file_path).resolve()
                        modified_files.append(full_path)
                # Para renombrados, tomar ambos archivos
                    if status_code.startswith('R'):
                        # Formato: "R old_file -> new_file"
                        if ' -> ' in file_path:
                            old_file, new_file = file_path.split(' -> ')
                            modified_files.append((project_path / old_file.strip()).resolve())
                            modified_files.append((project_path / new_file.strip()).resolve())
                else:
                    full_path = (project_path / file_path).resolve()
                    modified_files.append(full_path)
            
        
            
            return modified_files
        except Exception as e:
            print(f"⚠️ No se pudo obtener archivos modificados con git: {e}")
            return []


def main():
    syncer = MultiProjectSyncer()
    
    print("🏦  Multi-Project Syncer")
    print("=" * 40)
    print(f"📁 Ruta base: {syncer.base_path}")
    
    # Verificar que estamos en el directorio correcto
    if not syncer.base_path.exists():
        print(f"❌ Error: No se encontró la ruta base {syncer.base_path}")
        print("Verifica que la ruta sea correcta")
        return
    
    if not (syncer.base_path / "BAVV").exists():
        print("❌ Error: No se encontró la carpeta origen")
        print(f"Verifica que exista: {syncer.base_path / 'BAVV'}")
        return
     
    
    else:
        # Modo interactivo
        selected_project = syncer.interactive_project_selection()
        
        if selected_project is None:
            print("❌ Operación cancelada")
            return
        
        success = syncer.sync_specific_project(selected_project)
    
    # Resultado final
    if success:
        print("\n🎉 ¡Sincronización exitosa!")
        print("Los cambios se han propagado correctamente")
    else:
        print("\n💥 Hubo problemas en la sincronización")
        print("Revisa los errores anteriores")

if __name__ == "__main__":
    main()