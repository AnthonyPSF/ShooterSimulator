# ShooterSimulator

Proyecto de simulación de tiro hecho en Godot 4.

---

## Requisitos

- **Godot 4.x** → [godotengine.org/download](https://godotengine.org/download/)
- **Git LFS 3.x** → [git-lfs.com](https://git-lfs.com/)

---

# ⚠️ LEE ESTO PRIMERO — Git LFS es obligatorio

Este proyecto usa **Git LFS** para los modelos 3D, texturas e imágenes. Son archivos muy pesados que Git solo no maneja bien.

**Si clonas el repo sin instalar Git LFS, el proyecto NO va a funcionar.** Godot no encontrará las texturas ni los modelos 3D. Todo se verá vacío o con errores.

La instalación de Git LFS se hace **una sola vez en tu vida**. Toma 2 minutos.

---

# Guía para Windows

Cada vez que alguien nuevo se una al proyecto, solo tiene que seguir estos 3 pasos. El Paso 1 se hace una sola vez. Los Pasos 2 y 3 cada vez que quieran clonar un repo con LFS.

---

## Paso 1 — Instalar Git LFS (solo la primera vez)

### Opción A: Con el instalador (la más fácil)

1. Abre tu navegador y ve a: **https://git-lfs.com/**
2. Haz click en el botón grande que dice **"Download"**
3. Se descarga un archivo llamado `git-lfs-windows-...exe`
4. **Doble click** en ese archivo para ejecutarlo
5. Dale **Siguiente > Siguiente > Instalar** (no cambies nada, las opciones por defecto están bien)
6. Click en **Finalizar**

Listo. Git LFS ya está instalado en tu PC.

### Opción B: Con Chocolatey (si ya usas Chocolatey)

Abre **PowerShell como administrador** y ejecuta:

```powershell
choco install git-lfs
```

### Opción C: Con Scoop (si ya usas Scoop)

Abre **PowerShell** y ejecuta:

```powershell
scoop install git-lfs
```

---

## Paso 2 — Activar Git LFS (solo la primera vez)

Después de instalar, abre una terminal cualquiera (**PowerShell**, **CMD** o **Git Bash**) y escribe:

```bash
git lfs install
```

Tiene que aparecer algo como esto:

```
Git LFS initialized.
```

Si ves ese mensaje, ya está. Nunca más tendrás que volver a hacer esto.

---

## Paso 3 — Clonar el repositorio

Abre una terminal en la carpeta donde quieras descargar el proyecto y ejecuta:

```bash
git clone https://github.com/AnthonyPSF/ShooterSimulator.git
```

Luego entra a la carpeta:

```bash
cd ShooterSimulator
```

Git LFS descargará automáticamente todos los assets pesados. La primera vez puede tardar un par de minutos porque son ~200 MB en modelos 3D y texturas. Es normal.

---

## Cómo saber si LFS funcionó bien

Después de clonar, revisa que los assets sean archivos de verdad y no punteros vacíos:

```bash
dir Assets\Models\gravel_ground_patch.glb
```

El archivo debe pesar unos **42 MB**. Si ves algo de 132 bytes, LFS no descargó los assets.

Si eso pasa, ejecuta esto dentro de la carpeta del proyecto:

```bash
git lfs pull
```

Eso fuerza la descarga de todos los assets que falten.

---

## Ya cloné sin LFS, ¿qué hago?

Si ya clonaste el repo antes de instalar Git LFS, tranquilo. No necesitas borrar nada ni volver a clonar.

Solo asegúrate de haber completado los Pasos 1 y 2, y luego ejecuta esto dentro de la carpeta del proyecto:

```bash
git lfs pull
```

Eso descarga todos los assets que faltan y el proyecto queda listo.

---

# Guía para macOS y Linux

### Instalar Git LFS

**macOS (Homebrew):**
```bash
brew install git-lfs
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install git-lfs
```

**Linux (Fedora):**
```bash
sudo dnf install git-lfs
```

### Activar y clonar

```bash
git lfs install
git clone https://github.com/AnthonyPSF/ShooterSimulator.git
```

---

# Abrir el proyecto en Godot

1. Abre **Godot 4.x**
2. Click en **Importar**
3. Busca la carpeta `ShooterSimulator`
4. Selecciona el archivo `project.godot`
5. Click en **Importar y editar**

---

# ¿Qué archivos van con LFS?

| Tipo | Extensiones |
|------|-------------|
| Modelos 3D | `.glb` |
| Texturas e imágenes | `.png`, `.jpg`, `.jpeg` |
| Archivos comprimidos | `.zip` |

No tienes que hacer nada especial al editar el proyecto. Cuando hagas `git add` de cualquier `.glb`, `.png`, `.jpg` o `.zip`, Git LFS lo maneja solo.

---

# Problemas comunes

| Problema | Causa | Solución |
|----------|-------|----------|
| Godot muestra assets rotos o vacíos | Clonaste sin LFS | `git lfs pull` |
| Error `GH008` al hacer push | LFS no está activado | `git lfs install` |
| `git-lfs: command not found` | No instalaste LFS | Vuelve al Paso 1 |
| `git push` se queda pegado | Los assets LFS son pesados y tu internet es lento | Espera. Con mala conexión puede tardar varios minutos |
