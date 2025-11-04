# Guía de Ejecución - Generador de Crucigramas

## 🎯 Pasos Completados

✅ **Paso 1**: Proyecto Flutter creado con estructura base
✅ **Paso 2**: Lista de palabras agregada a assets/words.txt
✅ **Paso 3**: Modelo de datos implementado con built_value
✅ **Paso 4**: Proveedores Riverpod configurados
✅ **Paso 5**: Widgets de UI implementados
✅ **Paso 6**: Lógica de isolates para procesamiento en segundo plano

## 🚀 Cómo Ejecutar la Aplicación

### Opción 1: Desde Visual Studio Code

1. Abre el proyecto en VS Code
2. Presiona `F5` o usa el menú `Run > Start Debugging`
3. Selecciona el dispositivo/emulador donde deseas ejecutar la app

### Opción 2: Desde la Terminal

```powershell
# Navega al directorio del proyecto
cd "c:\Users\carli\OneDrive\Escritorio\practica 14"

# Ejecuta la aplicación
flutter run
```

### Opción 3: Para Windows Desktop

```powershell
flutter run -d windows
```

## 🔄 Si Necesitas Regenerar el Código

Si modificas archivos `model.dart` o `providers.dart`:

```powershell
# Regenerar código una vez
dart run build_runner build --delete-conflicting-outputs

# O mantener build_runner en modo watch
dart run build_runner watch -d
```

## 🎮 Funcionalidades de la Aplicación

### Al Iniciar
- La aplicación carga automáticamente la lista de palabras
- Comienza a generar un crucigrama de tamaño medio (40x22)
- Verás cómo las palabras se van entrelazando en tiempo real

### Menú de Configuración
1. Haz clic en el ícono de configuración ⚙️ en la esquina superior derecha
2. Selecciona un tamaño diferente:
   - **Small**: 20 x 11
   - **Medium**: 40 x 22 (por defecto)
   - **Large**: 80 x 44
   - **XLarge**: 160 x 88
   - **XXLarge**: 500 x 500

### Interacción con la Cuadrícula
- **Desplazamiento libre**: Arrastra en cualquier dirección para explorar el crucigrama
- **Zoom diagonal**: Compatible con gestos táctiles y mouse

## 📊 Observando el Progreso

### En la Consola de Debug
Verás mensajes como:
- `Added word: example` - Cuando una palabra se agrega exitosamente
- `Failed to add word: example` - Cuando una palabra no encaja

### En la UI
- **Celdas blancas**: Contienen caracteres de palabras
- **Celdas grises**: Espacios vacíos en la cuadrícula
- Las palabras se entrelazan en tiempo real

## 🐛 Solución de Problemas

### Error: "Target of URI doesn't exist"
```powershell
flutter pub get
```

### Error: "Cannot find model.g.dart"
```powershell
dart run build_runner build --delete-conflicting-outputs
```

### Error: "Invalid argument in isolate message"
- Este error ya está resuelto en la implementación actual
- El código está correctamente separado en isolates.dart

### La aplicación no genera palabras
- Verifica que `assets/words.txt` exista y tenga contenido
- Revisa la consola para mensajes de error

## 📈 Rendimiento

### Optimizaciones Implementadas

1. **Isolates**: El cálculo se realiza en segundo plano sin bloquear la UI
2. **Select de Riverpod**: Solo se recomputanlas celdas que cambian
3. **Consumer granular**: Cada celda de la cuadrícula tiene su propio límite de actualización
4. **TableView**: Renderizado eficiente de cuadrículas grandes

### Tiempos Esperados

- **Small (20x11)**: ~5-10 segundos
- **Medium (40x22)**: ~20-30 segundos
- **Large (80x44)**: ~1-2 minutos
- **XLarge y XXLarge**: Varios minutos (depende del hardware)

## 🎓 Conceptos Clave del Codelab

### 1. Procesamiento Asíncrono
```dart
// Uso de compute() para ejecutar en isolates
await compute((wordToAdd) {
  // Código que se ejecuta en segundo plano
}, (word, direction, location));
```

### 2. Estructuras Inmutables
```dart
// built_value permite crear objetos inmutables eficientemente
final newCrossword = crossword.addWord(...);
```

### 3. Gestión de Estado Reactiva
```dart
// Riverpod con select() para optimizar recompilaciones
ref.watch(crosswordProvider.select((crosswordAsync) => ...));
```

### 4. Visualización de Cuadrículas
```dart
// TableView para renderizado eficiente
TableView.builder(
  cellBuilder: _buildCell,
  columnCount: size.width,
  rowCount: size.height,
)
```

## 📝 Notas Importantes

- ⚠️ Los crucigramas XXLarge pueden tardar mucho tiempo en generar
- 💡 El algoritmo actual usa selección aleatoria; versiones futuras podrían usar heurísticas
- 🎯 Las restricciones aplicadas siguen la tradición de crucigramas en inglés
- 🔄 Puedes cambiar el tamaño en cualquier momento; esto reiniciará la generación

## 🔗 Referencias

- [Documentación de Flutter](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [built_value Package](https://pub.dev/packages/built_value)
- [two_dimensional_scrollables](https://pub.dev/packages/two_dimensional_scrollables)

## ✨ Próximos Pasos Sugeridos

1. Implementar algoritmos más inteligentes (búsqueda con heurísticas)
2. Agregar modo de juego para resolver crucigramas
3. Implementar guardado/carga de crucigramas generados
4. Añadir pistas para las palabras
5. Crear un sistema de dificultad basado en la oscuridad de las palabras

---

¡Disfruta generando crucigramas! 🎉
