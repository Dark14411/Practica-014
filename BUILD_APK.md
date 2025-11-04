# 📱 Compilar APK para Android

## 🚀 Comando rápido

```bash
flutter build apk --release
```

El APK se generará en: `build\app\outputs\flutter-apk\app-release.apk`

## 📋 Pasos detallados

### 1. Verificar que Android esté configurado

```bash
flutter doctor
```

Debe mostrar ✓ en Android toolchain.

### 2. Limpiar build anterior (opcional pero recomendado)

```bash
flutter clean
flutter pub get
```

### 3. Compilar APK de producción

```bash
flutter build apk --release
```

### 4. Compilar APK más pequeño (split por ABI)

```bash
flutter build apk --split-per-abi --release
```

Esto genera 3 APKs optimizados:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM - más común)
- `app-x86_64-release.apk` (Emuladores x86)

## 🎯 Ubicación de los APKs

```
build/app/outputs/flutter-apk/
├── app-release.apk (universal - más grande)
├── app-armeabi-v7a-release.apk
├── app-arm64-v8a-release.apk
└── app-x86_64-release.apk
```

## 📱 Instalar en dispositivo

### Método 1: Desde computadora

```bash
# Conecta tu teléfono por USB con depuración USB activada
flutter install
```

### Método 2: Transferir APK

1. Copia el APK a tu teléfono
2. Abre el archivo APK en el teléfono
3. Permite "Instalar apps desconocidas" si es necesario
4. Instala la app

## 🔧 Configuración actual

- **Package Name**: `com.crossword.generator`
- **Version**: 1.0.0
- **Version Code**: 1
- **Min SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: Latest

## ⚙️ Características de la app

### 🟢 Modo ONLINE (con internet):
- Conecta a Supabase automáticamente
- Usa palabras personalizadas de tu base de datos:
  - darkrippers
  - kirito
  - eromechi
  - pablini
  - secuaz
  - nino
  - celismor
  - wesuangelito
  - + 42 palabras adicionales (anime, manga, etc.)

### 🔴 Modo OFFLINE (sin internet):
- Usa 200+ palabras aleatorias diferentes:
  - Animales, frutas, colores, países
  - Objetos, naturaleza, verbos, adjetivos
  - Profesiones, comidas, deportes, emociones
  - Tecnología, música, geografía, ciencias
- **NO** usa las palabras de Supabase

### 📊 Indicador visual:
- 🟢 **Online** = Conectado a Supabase (icono nube verde)
- 🔴 **Local** = Sin internet, palabras aleatorias (icono nube naranja)

## 🐛 Solución de problemas

### Error: "Android SDK not found"

Instala Android Studio y configura SDK:
```bash
flutter doctor --android-licenses
```

### Error de compilación

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### APK muy grande

Usa split por ABI:
```bash
flutter build apk --split-per-abi --release
```

## 📦 Tamaños aproximados

- **Universal APK**: ~30-40 MB
- **Split APK (arm64-v8a)**: ~18-25 MB (recomendado para mayoría de teléfonos)

## 🎮 Probar en modo debug

```bash
flutter run -d <device-id>
```

Ver dispositivos conectados:
```bash
flutter devices
```

## 📝 Notas importantes

1. **Primera instalación**: Puede tardar algunos minutos
2. **Permisos requeridos**: Internet, Estado de red
3. **Funcionamiento offline**: 100% funcional sin internet
4. **Tamaño del crucigrama**: Ajustable desde menú (20x11 hasta 500x500)
5. **Workers paralelos**: Configurable 1-128 (recomendado 4-8)

## 🚀 Publicar en Google Play Store (opcional)

Para publicar necesitas:
1. Crear keystore para firma
2. Configurar signing en build.gradle
3. Crear cuenta de desarrollador ($25 único pago)
4. Subir APK/AAB a Play Console

Consulta: https://docs.flutter.dev/deployment/android
