# 📝 Guía para Agregar Más Palabras

## Archivos de Palabras Disponibles

El proyecto actualmente incluye ~1000 palabras de ejemplo en `assets/words.txt`. Para una experiencia completa, puedes descargar listas más extensas.

## 🌐 Fuentes Recomendadas

### 1. SOWPODS (267,750 palabras) - Recomendado
**Fuente**: Peter Norvig's Natural Language Corpus Data
**URL**: http://norvig.com/ngrams/sowpods.txt

```powershell
# Descargar SOWPODS completo
Invoke-WebRequest -Uri "http://norvig.com/ngrams/sowpods.txt" -OutFile "assets/words.txt"
```

**Características**:
- ✅ Formato perfecto para este proyecto
- ✅ Solo palabras válidas en inglés
- ✅ Usado en competencias oficiales de Scrabble
- ✅ Tamaño: ~2.4 MB

### 2. TWL06 (178,691 palabras)
**Fuente**: Tournament Word List
**URL**: http://norvig.com/ngrams/twl06.txt

```powershell
# Descargar TWL06
Invoke-WebRequest -Uri "http://norvig.com/ngrams/twl06.txt" -OutFile "assets/words.txt"
```

**Características**:
- ✅ Lista oficial de Scrabble en Norteamérica
- ✅ Más conservadora que SOWPODS
- ✅ Tamaño: ~1.8 MB

### 3. Enable1 (172,820 palabras)
**Fuente**: Proyecto Enable
**URL**: http://norvig.com/ngrams/enable1.txt

```powershell
# Descargar Enable1
Invoke-WebRequest -Uri "http://norvig.com/ngrams/enable1.txt" -OutFile "assets/words.txt"
```

---

## 📋 Requisitos del Formato

El archivo `words.txt` debe cumplir:

1. **Una palabra por línea**
   ```
   palabra1
   palabra2
   palabra3
   ```

2. **Solo caracteres a-z** (el código convierte automáticamente mayúsculas a minúsculas)

3. **Mínimo 3 letras** (palabras más cortas son filtradas automáticamente)

---

## 🔧 Procesamiento Manual

Si tienes tu propia lista de palabras, puedes procesarla:

### Usando PowerShell

```powershell
# Convertir a minúsculas y filtrar
Get-Content "tu-lista.txt" | 
    ForEach-Object { $_.ToLower().Trim() } | 
    Where-Object { $_ -match '^[a-z]{3,}$' } | 
    Sort-Object -Unique | 
    Set-Content "assets/words.txt"
```

### Usando Python

```python
# script_procesar_palabras.py
import re

with open('tu-lista.txt', 'r', encoding='utf-8') as f:
    palabras = f.readlines()

# Filtrar y limpiar
palabras_validas = []
for palabra in palabras:
    palabra = palabra.strip().lower()
    # Solo letras a-z, mínimo 3 caracteres
    if re.match(r'^[a-z]{3,}$', palabra):
        palabras_validas.append(palabra)

# Eliminar duplicados y ordenar
palabras_validas = sorted(set(palabras_validas))

# Guardar
with open('assets/words.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(palabras_validas))

print(f"Procesadas {len(palabras_validas)} palabras válidas")
```

---

## 🌍 Listas en Otros Idiomas

### Español

Para crear un generador de crucigramas en español, necesitarías:

1. **Modificar el regex de validación** en `lib/providers.dart`:
```dart
// Agregar caracteres con acentos y ñ
final re = RegExp(r'^[a-záéíóúñü]+$');
```

2. **Usar una lista de palabras en español**:
   - [Listado de palabras en español](https://github.com/JorgeDuenasLerin/diccionario-espanol-txt)
   - Diccionario de la RAE

### Otros Idiomas

El código necesita modificación para soportar:
- Caracteres Unicode especiales
- Reglas de validación específicas del idioma
- Direcciones de escritura (RTL para árabe, hebreo)

---

## 📊 Comparación de Tamaños

| Lista | Palabras | Tamaño | Tiempo de Carga |
|-------|----------|--------|----------------|
| Ejemplo (actual) | ~1,000 | 10 KB | <1s |
| Enable1 | 172,820 | 1.8 MB | ~2s |
| TWL06 | 178,691 | 1.8 MB | ~2s |
| SOWPODS | 267,750 | 2.4 MB | ~3s |

---

## ⚙️ Configuración Avanzada

### Limitar por Longitud de Palabra

Si quieres solo palabras de cierta longitud, modifica `lib/providers.dart`:

```dart
return const LineSplitter()
    .convert(words)
    .toBuiltSet()
    .rebuild(
      (b) => b
        ..map((word) => word.toLowerCase().trim())
        ..where((word) => word.length >= 4 && word.length <= 10) // 4-10 letras
        ..where((word) => re.hasMatch(word)),
    );
```

### Palabras Temáticas

Para crucigramas temáticos (ej: animales, países):

1. Crea archivo `assets/animals.txt` con palabras de animales
2. Modifica `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/words.txt
    - assets/animals.txt
    - assets/countries.txt
```
3. Agrega selector de tema en la UI

---

## 🐛 Solución de Problemas

### "Error loading word list"
- ✅ Verifica que el archivo existe en `assets/words.txt`
- ✅ Asegúrate de que `pubspec.yaml` declara el asset
- ✅ Ejecuta `flutter clean` y luego `flutter pub get`

### "Not enough words to generate crossword"
- ✅ Lista de palabras muy pequeña
- ✅ Filtros muy restrictivos
- ✅ Descarga una lista más grande

### "App takes too long to start"
- ✅ Lista de palabras muy grande (>500,000)
- ✅ Considera pre-procesar o dividir la lista
- ✅ Implementa carga lazy o paginación

---

## 📚 Recursos Adicionales

### Páginas de Descarga
- **Peter Norvig's Page**: http://norvig.com/ngrams/
- **SCOWL Project**: http://wordlist.aspell.net/
- **Moby Word Lists**: https://en.wikipedia.org/wiki/Moby_Project

### Herramientas
- **Word List Validator**: Crea tu propio script de validación
- **Frequency Analysis**: Analiza qué palabras son más comunes
- **Word Statistics**: Obtén métricas de tu lista

---

## ✨ Próximos Pasos

1. **Descargar SOWPODS** para experiencia completa
2. **Experimentar** con diferentes tamaños
3. **Crear listas temáticas** para nichos específicos
4. **Implementar selector** de listas en la UI

---

**Nota**: Al cambiar la lista de palabras, reinicia la app para que los cambios surtan efecto.

**Hot Reload** no recarga assets, necesitas **Hot Restart** (Shift + F5).
