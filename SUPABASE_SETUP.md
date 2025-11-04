# Configuración de Supabase para Crossword Generator

## 📋 Instrucciones para configurar tu base de datos

### 1. Crear la tabla en Supabase

Ve al **SQL Editor** de tu proyecto en Supabase y ejecuta este comando:

```sql
-- Crear tabla de palabras
CREATE TABLE IF NOT EXISTS words (
  id SERIAL PRIMARY KEY,
  word TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insertar las palabras personalizadas
INSERT INTO words (word) VALUES 
  ('darkrippers'),
  ('kirito'),
  ('eromechi'),
  ('pablini'),
  ('secuaz'),
  ('nino'),
  ('celismor'),
  ('wesuangelito')
ON CONFLICT (word) DO NOTHING;

-- Verificar que se insertaron correctamente
SELECT * FROM words;
```

### 2. Configurar políticas de acceso (Row Level Security)

Para permitir el acceso público de lectura:

```sql
-- Habilitar RLS en la tabla
ALTER TABLE words ENABLE ROW LEVEL SECURITY;

-- Crear política para permitir lectura pública
CREATE POLICY "Allow public read access"
  ON words
  FOR SELECT
  USING (true);
```

### 3. Verificar la configuración

Tu aplicación Flutter ahora:

✅ **Con Internet**: 
- Se conecta automáticamente a Supabase
- Carga las 8 palabras personalizadas
- Las combina con el diccionario local (~340 palabras)
- Muestra indicador verde "Online" en el AppBar

❌ **Sin Internet**:
- Usa solo las palabras del archivo local `assets/words.txt`
- Muestra indicador naranja "Local" en el AppBar
- Funciona completamente offline

### 4. Agregar más palabras

Puedes agregar más palabras ejecutando:

```sql
INSERT INTO words (word) VALUES 
  ('tu nueva palabra'),
  ('otra palabra')
ON CONFLICT (word) DO NOTHING;
```

### 5. Ver todas las palabras

```sql
SELECT * FROM words ORDER BY word;
```

## 🔧 Notas técnicas

- **URL de Supabase**: https://tradrpzmbypbnshjuxxj.supabase.co
- **Anon Key**: Ya configurada en `lib/services/supabase_service.dart`
- **Tabla**: `words` con columna `word` (TEXT)
- **Timeout**: 10 segundos para la conexión
- **Detección de conectividad**: Automática con `connectivity_plus`

## 📱 Uso en la app

1. La app verifica automáticamente la conexión al iniciar
2. Intenta cargar palabras desde Supabase
3. Si falla o no hay internet, usa solo palabras locales
4. El indicador en el AppBar muestra el estado actual

## 🎮 Palabras personalizadas incluidas

1. **darkrippers** (dark rippers)
2. **kirito**
3. **eromechi** (erome chi)
4. **pablini**
5. **secuaz**
6. **nino** (niño)
7. **celismor** (celis mor)
8. **wesuangelito** (wesu angelito)

Estas palabras se priorizan en el generador de crucigramas cuando hay conexión a internet.
