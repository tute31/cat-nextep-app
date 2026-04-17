# cat-nextep-app

Aplicacion Flutter desarrollada como prueba tecnica frontend, consumiendo la API de https://catfact.ninja.

## Objetivo

Mostrar un directorio de razas de gatos con:

- Paginacion con infinite scroll
- Busqueda local
- Pull-to-refresh
- Pantalla de detalle con dato curioso aleatorio
- Manejo de errores sin romper la UI

## Arquitectura

Se uso una arquitectura simplificada, separando capas:

- presentation: UI y manejo reactivo de estado (Cubit)
- domain: entidades y contratos de repositorio
- data: modelos tipados, datasources remotos y repositorios concretos
- core: manejo de errores compartido

Estructura principal:

- lib/app
- lib/core
- lib/features/breeds
- lib/features/facts

## Stack

- Flutter
- flutter_bloc (Cubit)
- http
- equatable

## Endpoints usados

- GET /breeds
- GET /fact

Base URL: https://catfact.ninja

## Como correr el proyecto

1. Instalar dependencias:

```bash
flutter pub get
```

2. Ejecutar en simulador/emulador:

```bash
flutter run
```

3. Validar calidad:

```bash
flutter analyze
flutter test
```

## Notas de implementacion

- No se hacen llamadas HTTP desde widgets de UI.
- La paginacion agrega elementos a la lista sin sobreescribir datos existentes.
- Los errores se tipan en capa core y se convierten a mensajes amigables para UX.
- La busqueda es local sobre los elementos ya cargados.

## Autor TuteR (31) _3_1_ to Nextep