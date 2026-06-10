# Integration Plan

## Estructura Final de Directorios en Godot

La integración de los assets se realizará siguiendo la siguiente estructura dentro de la carpeta `Assets/` del proyecto:

```
Assets/
├── Weapons/    (Modelos 3D de armas, prefabs, tscn correspondientes)
├── Targets/    (Modelos 3D de objetivos, siluetas, dianas)
├── Textures/   (Imágenes 2D para texturizado)
├── Materials/  (Archivos .tres o .material de Godot)
├── Audio/      (Efectos de sonido: disparos, impactos, recargas)
├── UI/         (Imágenes para crosshairs, barras de vida, iconos)
├── Models/     (Otros modelos 3D misceláneos)
└── Shared/     (Recursos compartidos o globales)
```

## Criterios de Selección (Etapa 2)
Sólo se importarán recursos de la carpeta `workspace/catalog/` que cumplan con los siguientes requisitos:
- **Modelos**: GLB, GLTF, FBX, OBJ con un tamaño mayor a 0 bytes.
- **Texturas**: PNG, JPG, JPEG, WEBP válidas.
- **Audio**: WAV, OGG, MP3.
- Los archivos duplicados (con sufijos "_1", "_2" por extracción doble) serán ignorados a menos que representen variantes distintas.

## Proceso de Integración
El proceso moverá (copiará) estos archivos a la estructura definitiva en `Assets/`. No se modificarán las escenas de gameplay existentes.

- Las armas irán a `Assets/Weapons/`.
- Los targets a `Assets/Targets/`.
- Texturas a `Assets/Textures/`.
- Audio a `Assets/Audio/`.
- El reporte de log, uso y los ignorados se crearán en `reports/`.
