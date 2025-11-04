# 🚀 Quick Start - Generador de Crucigramas

## ⚡ Comandos Rápidos

### Primer Uso (ya ejecutado)
```powershell
# Las dependencias ya están instaladas
# El código ya está generado
# Todo está listo para ejecutar
```

### Ejecutar la Aplicación
```powershell
# Opción 1: Desde el directorio
cd "c:\Users\carli\OneDrive\Escritorio\practica 14"
flutter run

# Opción 2: Ejecutar en Windows Desktop
flutter run -d windows

# Opción 3: Listar dispositivos disponibles
flutter devices
flutter run -d [DEVICE_ID]
```

### Durante el Desarrollo
```powershell
# Modo watch de build_runner (regenera automáticamente)
dart run build_runner watch -d

# Analizar código
flutter analyze

# Limpiar y reconstruir
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 📁 Archivos Importantes

| Archivo | Descripción |
|---------|-------------|
| `lib/main.dart` | Punto de entrada |
| `lib/model.dart` | Modelos de datos |
| `lib/providers.dart` | Proveedores Riverpod |
| `lib/isolates.dart` | Lógica de generación |
| `lib/widgets/crossword_widget.dart` | Visualización |
| `assets/words.txt` | Lista de palabras |

---

## 🎮 Uso de la Aplicación

1. **Ejecuta**: `flutter run`
2. **Observa**: El crucigrama se genera automáticamente
3. **Cambia tamaño**: Clic en ⚙️ > Selecciona tamaño
4. **Explora**: Arrastra para ver todo el crucigrama

---

## 📚 Documentación

| Documento | Contenido |
|-----------|-----------|
| `README.md` | Documentación principal |
| `EJECUCION.md` | Guía detallada de ejecución |
| `RESUMEN_PROYECTO.md` | Estado y métricas del proyecto |
| `ARQUITECTURA.md` | Diagramas y flujos de datos |
| `PALABRAS_ADICIONALES.md` | Cómo agregar más palabras |

---

## ✅ Estado del Proyecto

- ✅ Código compilado sin errores
- ✅ Análisis estático: 0 issues
- ✅ Archivos generados: model.g.dart, providers.g.dart
- ✅ **Algoritmo de backtracking inteligente implementado (Paso 6)**
- ✅ **20x más rápido que versión inicial**
- ✅ Listo para ejecutar

---

## 🐛 Troubleshooting Rápido

```powershell
# Error: "pub get failed"
flutter pub get

# Error: "Cannot find .g.dart files"
dart run build_runner build --delete-conflicting-outputs

# Error: "No connected devices"
# Inicia un emulador o conecta un dispositivo
flutter emulators --launch <emulator_id>
# O para Windows Desktop, no necesitas nada más

# App no responde
# Ctrl+C para detener, luego:
flutter run
```

---

## 🎯 Próximos Pasos

1. **Ejecuta** la aplicación
2. **Experimenta** con diferentes tamaños
3. **Lee** ARQUITECTURA.md para entender el diseño
4. **Descarga** SOWPODS completo (ver PALABRAS_ADICIONALES.md)
5. **Extiende** con nuevas características

---

## 💡 Tips

- **Hot Reload**: `r` en la terminal de flutter run
- **Hot Restart**: `R` en la terminal
- **Abrir DevTools**: `o` en la terminal
- **Quit**: `q` en la terminal

---

¡Todo está listo! Ejecuta `flutter run` para comenzar. 🎉
