# Generador de Crucigramas (Crossword Generator)

Una aplicación Flutter que genera crucigramas utilizando técnicas de inteligencia artificial tradicional (GOFAI) basadas en búsqueda en profundidad y backtracking.

## 📋 Características

- **Generación automática de crucigramas**: Algoritmo que entrelaza palabras horizontal y verticalmente
- **Múltiples tamaños**: Desde pequeño (20x11) hasta extra extra grande (500x500)
- **Procesamiento en segundo plano**: Utiliza isolates para mantener la UI fluida
- **Estructuras de datos inmutables**: Implementadas con built_value y built_collection
- **Gestión de estado eficiente**: Usando Riverpod con optimizaciones de rendimiento
- **Visualización de cuadrícula**: Con two_dimensional_scrollables para alto rendimiento

## 🏗️ Arquitectura

### Componentes Clave

1. **Modelo de Datos (model.dart)**
   - `Location`: Coordenadas en el crucigrama
   - `CrosswordWord`: Una palabra con su ubicación y dirección
   - `CrosswordCharacter`: Un carácter individual en la cuadrícula
   - `Crossword`: El crucigrama completo con validación

2. **Proveedores Riverpod (providers.dart)**
   - `wordListProvider`: Carga la lista de palabras desde assets
   - `sizeProvider`: Mantiene el tamaño seleccionado del crucigrama
   - `crosswordProvider`: Stream que genera el crucigrama

3. **Procesamiento en Segundo Plano (isolates.dart)**
   - `exploreCrosswordSolutions`: Función que genera soluciones usando compute()

4. **Widgets de UI**
   - `CrosswordGeneratorApp`: Aplicación principal con menú de configuración
   - `CrosswordWidget`: Visualización de la cuadrícula del crucigrama

## 🚀 Instalación

### Prerequisitos

- Flutter SDK (^3.9.0)
- Dart SDK
- Visual Studio Code con extensiones de Flutter y Dart

### Pasos

1. Clona o descarga este proyecto

2. Instala las dependencias:
```bash
flutter pub get
```

3. Genera el código necesario con build_runner:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Ejecuta la aplicación:
```bash
flutter run
```

## 📦 Dependencias Principales

- **flutter_riverpod**: Gestión de estado reactiva
- **built_value & built_collection**: Estructuras de datos inmutables
- **two_dimensional_scrollables**: Visualización de cuadrículas eficiente
- **characters**: Manejo correcto de cadenas Unicode
- **build_runner**: Generación de código

## 🎮 Uso

1. Al iniciar la aplicación, se cargará automáticamente la lista de palabras
2. El generador comenzará a crear un crucigrama del tamaño medio por defecto
3. Usa el ícono de configuración (⚙️) en la esquina superior derecha para cambiar el tamaño
4. Las palabras se entrelazan automáticamente siguiendo las reglas de crucigramas en inglés

## 🔧 Desarrollo

### Para modificar y regenerar código:

```bash
# En modo watch (regenera automáticamente al detectar cambios)
dart run build_runner watch -d

# Una sola vez
dart run build_runner build --delete-conflicting-outputs
```

### Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── model.dart                   # Modelos de datos inmutables
├── providers.dart               # Proveedores Riverpod
├── isolates.dart                # Lógica de procesamiento en segundo plano
├── utils.dart                   # Utilidades y extensiones
└── widgets/
    ├── crossword_generator_app.dart  # Widget principal
    └── crossword_widget.dart         # Widget de visualización

assets/
└── words.txt                    # Lista de palabras
```

## 🧠 Conceptos Aprendidos

1. **Rendimiento**: Uso de isolates con `compute()` para mantener la UI responsiva
2. **Gestión de Datos**: Estructuras inmutables para algoritmos eficientes de búsqueda
3. **Optimización de UI**: Builds selectivos con `select()` de Riverpod
4. **Visualización**: Cuadrículas de alto rendimiento con two_dimensional_scrollables

## 📝 Validaciones del Crucigrama

El algoritmo aplica las siguientes restricciones:

- No puede haber palabras duplicadas
- Todos los caracteres deben ser parte de una palabra horizontal o vertical
- Los caracteres adyacentes deben estar relacionados por la misma palabra
- Las palabras deben entrelazarse correctamente (compartir caracteres)
- Las nuevas palabras deben superponerse con palabras existentes

## 🔮 Próximos Pasos

Este proyecto se puede extender con:

- Algoritmos de generación más inteligentes (heurísticas)
- Modo de juego interactivo para resolver crucigramas
- Soporte para diferentes idiomas y conjuntos de caracteres
- Exportación de crucigramas generados
- Niveles de dificultad configurables

## 📄 Licencia

Este proyecto es parte de un codelab educativo de Flutter.

## 🙏 Créditos

- Lista de palabras: SOWPODS de Peter Norvig's Natural Language Corpus Data
- Basado en el codelab oficial de Flutter para generación de crucigramas
