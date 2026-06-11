# ShooterSimulator

Proyecto de simulación de tiro hecho en Godot 4.

---

## Requisitos

| Herramienta | Versión | Descarga |
|------------|---------|----------|
| **Godot** | 4.x | [godotengine.org](https://godotengine.org/download/) |
| **Git LFS** | 3.x o superior | [git-lfs.com](https://git-lfs.com/) |

---

## ⚠️ Git LFS es obligatorio

Este proyecto usa **Git LFS (Large File Storage)** para manejar modelos 3D, texturas y otros archivos pesados. Si clonas el repo sin tener Git LFS instalado, **Godot no va a cargar los assets** (texturas, modelos, materiales) y el proyecto se verá roto.

### Paso 1: Instalar Git LFS

Elige tu sistema operativo:

**Windows**
```powershell
# Opción A — Descargar el instalador (recomendado)
# Abre https://git-lfs.com/ en tu navegador, descarga y ejecuta el .exe

# Opción B — Chocolatey
choco install git-lfs

# Opción C — Scoop
scoop install git-lfs
```

**macOS**
```bash
# Homebrew
brew install git-lfs

# MacPorts
port install git-lfs
```

**Linux (Debian/Ubuntu)**
```bash
sudo apt install git-lfs
```

**Linux (Fedora)**
```bash
sudo dnf install git-lfs
```

### Paso 2: Activar Git LFS (solo una vez)

Después de instalar, ejecuta esto **una sola vez** en tu terminal:

```bash
git lfs install
```

Verás algo como: `Git LFS initialized`. Con esto queda activado para siempre en tu PC.

### Paso 3: Clonar el repositorio

```bash
git clone https://github.com/AnthonyPSF/ShooterSimulator.git
cd ShooterSimulator
```

Git LFS se encarga automáticamente de descargar todos los assets. Puede tardar un poco la primera vez porque son archivos pesados (~200 MB en modelos y texturas).

---

## Verificar que LFS funciona

Después de clonar, revisa que los assets se hayan descargado correctamente:

```bash
# Deberías ver los archivos reales, no punteros
ls -lh Assets/Models/gravel_ground_patch.glb
# Debe pesar ~42 MB, NO ~132 bytes
```

Si ves archivos de 130-140 bytes en lugar de megabytes, ejecuta:

```bash
git lfs pull
```

---

## Si ya clonaste sin LFS

Si clonaste el repo antes de instalar Git LFS, no pasa nada. Solo ejecuta:

```bash
git lfs pull
```

Esto descarga todos los assets que faltan. No necesitas re-clonar.

---

## ¿Qué archivos van con LFS?

| Tipo | Extensión | Ejemplos |
|------|-----------|----------|
| Modelos 3D | `.glb` | Personajes, escenarios, props |
| Texturas | `.png`, `.jpg`, `.jpeg` | Materiales, skins, UI |
| Comprimidos | `.zip` | Kits de assets |

Esto está configurado en el archivo `.gitattributes`. No necesitas hacer nada manual — al hacer `git add` de estos archivos, LFS los maneja automático.

---

## Abrir el proyecto en Godot

1. Abre **Godot 4.x**
2. Click en **Importar** (o **Import**)
3. Navega hasta la carpeta del proyecto
4. Selecciona el archivo `project.godot`
5. Click en **Importar y editar**

---

## Problemas comunes

| Problema | Solución |
|----------|----------|
| Godot muestra assets como "missing" o recursos rotos | `git lfs pull` |
| Error "GH008: unknown Git LFS objects" al hacer push | Instala Git LFS: `git lfs install` |
| `git-lfs: command not found` | No tienes LFS instalado. Ve al Paso 1 |
| El push se queda pegado / es muy lento | Normal con archivos grandes. Usa buena conexión a internet |
