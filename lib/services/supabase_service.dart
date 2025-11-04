import 'package:built_collection/built_collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://tradrpzmbypbnshjuxxj.supabase.co';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyYWRycHptYnlwYm5zaGp1eHhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NjA1NzgsImV4cCI6MjA3NzMzNjU3OH0.YLUvdSh_yTkAmmvwQdQ2Cj20vKrlv5MrFKXMYyS-Ek4';

  static final SupabaseClient _client = SupabaseClient(
    supabaseUrl,
    supabaseKey,
  );

  /// Getter para acceder al cliente de Supabase
  static SupabaseClient get client => _client;

  /// Lista de palabras personalizadas que se buscarán en Supabase
  static const List<String> customWords = [
    'darkrippers',
    'kirito',
    'eromechi',
    'pablini',
    'secuaz',
    'nino',
    'celismor',
    'wesuangelito',
  ];

  /// Palabras ALEATORIAS para modo OFFLINE (completamente diferentes)
  static const List<String> offlineWords = [
    // Animales
    'perro', 'gato', 'leon', 'tigre', 'elefante', 'jirafa', 'zebra', 'mono',
    'panda', 'koala', 'delfin', 'ballena', 'tiburon', 'aguila', 'halcon',
    'pinguino', 'oso', 'lobo', 'zorro', 'conejo', 'raton', 'caballo', 'vaca',
    // Frutas
    'manzana', 'pera', 'naranja', 'banana', 'uva', 'fresa', 'sandia', 'melon',
    'piña', 'mango', 'papaya', 'kiwi', 'cereza', 'durazno', 'ciruela', 'limon',
    // Colores
    'rojo', 'azul', 'verde', 'amarillo', 'morado', 'rosa', 'negro', 'blanco',
    'gris', 'cafe', 'turquesa', 'violeta', 'dorado', 'plateado', 'indigo',
    // Países
    'mexico', 'españa', 'francia', 'italia', 'japon', 'china', 'brasil',
    'argentina', 'peru', 'chile', 'colombia', 'ecuador', 'canada', 'alemania',
    // Objetos
    'mesa', 'silla', 'puerta', 'ventana', 'libro', 'lapiz', 'papel', 'telefono',
    'computadora', 'reloj', 'lampara', 'cama', 'sofa', 'espejo', 'television',
    // Naturaleza
    'arbol', 'flor', 'rio', 'mar', 'montaña', 'bosque', 'desierto', 'nube',
    'lluvia', 'sol', 'luna', 'estrella', 'viento', 'rayo', 'nieve', 'hielo',
    // Verbos
    'correr', 'saltar', 'nadar', 'volar', 'caminar', 'bailar', 'cantar', 'reir',
    'llorar',
    'dormir',
    'comer',
    'beber',
    'jugar',
    'trabajar',
    'estudiar',
    'leer',
    // Adjetivos
    'grande', 'pequeño', 'alto', 'bajo', 'rapido', 'lento', 'fuerte', 'debil',
    'feliz', 'triste', 'bonito', 'feo', 'nuevo', 'viejo', 'caliente', 'frio',
    // Profesiones
    'doctor', 'maestro', 'ingeniero', 'abogado', 'chef', 'artista', 'musico',
    'deportista', 'escritor', 'policia', 'bombero', 'piloto', 'enfermera',
    // Comidas
    'pizza', 'hamburguesa', 'pasta', 'arroz', 'pan', 'queso', 'leche', 'huevo',
    'carne', 'pollo', 'pescado', 'sopa', 'ensalada', 'postre', 'helado', 'taco',
    // Deportes
    'futbol',
    'basquetbol',
    'tenis',
    'natacion',
    'ciclismo',
    'atletismo',
    'boxeo',
    'yoga', 'karate', 'volleyball', 'beisbol', 'golf', 'hockey', 'surf',
    // Emociones
    'amor',
    'odio',
    'miedo',
    'alegria',
    'tristeza',
    'enojo',
    'sorpresa',
    'calma',
    // Tecnología
    'internet', 'software', 'hardware', 'codigo', 'programa', 'aplicacion',
    'sistema', 'red', 'servidor', 'datos', 'pantalla', 'teclado', 'mouse',
    // Música
    'guitarra', 'piano', 'bateria', 'violin', 'flauta', 'trompeta', 'saxofon',
    // Más palabras variadas
    'casa', 'edificio', 'calle', 'plaza', 'parque', 'escuela', 'hospital',
    'tienda', 'mercado', 'restaurante', 'cafe', 'biblioteca', 'museo', 'cine',
    'teatro', 'estadio', 'gimnasio', 'piscina', 'playa', 'ciudad', 'pueblo',
    'campo', 'granja', 'jardin', 'huerto', 'pradera', 'selva', 'isla', 'volcan',
    'cueva', 'cascada', 'lago', 'oceano', 'bahia', 'peninsula', 'continente',
    'planeta', 'galaxia', 'universo', 'espacio', 'cometa', 'satelite', 'cohete',
    'avion', 'barco', 'tren', 'autobus', 'carro', 'bicicleta', 'moto', 'camion',
    'primavera', 'verano', 'otoño', 'invierno', 'enero', 'febrero', 'marzo',
    'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre',
    'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo',
    'mañana',
    'tarde',
    'noche',
    'mediodia',
    'amanecer',
    'atardecer',
    'medianoche',
    'segundo',
    'minuto',
    'hora',
    'dia',
    'semana',
    'mes',
    'año',
    'siglo',
    'epoca',
    'historia', 'geografia', 'matematica', 'ciencia', 'fisica', 'quimica',
    'biologia', 'arte', 'musica', 'literatura', 'filosofia', 'politica',
    'economia', 'sociologia', 'psicologia', 'medicina', 'derecho', 'pedagogia',
  ];

  /// Inicializa Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  }

  /// Verifica si hay conexión a internet
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Obtiene palabras desde Supabase si hay internet, sino retorna null
  static Future<BuiltSet<String>?> fetchWordsFromSupabase() async {
    try {
      final hasInternet = await hasInternetConnection();
      if (!hasInternet) {
        debugPrint('No internet connection, using local words');
        return null;
      }

      debugPrint('Fetching words from Supabase...');

      // Intenta obtener las palabras de la tabla 'words'
      // Asume que tienes una tabla llamada 'words' con una columna 'word'
      final response = await _client
          .from('words')
          .select('word')
          .inFilter('word', customWords)
          .timeout(const Duration(seconds: 10));

      if (response.isEmpty) {
        debugPrint('No words found in Supabase');
        return null;
      }

      final words = <String>{};
      for (final row in response) {
        if (row['word'] != null) {
          words.add((row['word'] as String).toLowerCase().trim());
        }
      }

      if (words.isEmpty) {
        debugPrint('No valid words extracted from Supabase');
        return null;
      }

      debugPrint('Fetched ${words.length} words from Supabase');
      return words.build();
    } catch (e) {
      debugPrint('Error fetching from Supabase: $e');
      return null;
    }
  }

  /// Obtiene palabras: ONLINE = Supabase, OFFLINE = palabras aleatorias diferentes
  static Future<BuiltSet<String>> fetchWords() async {
    final hasInternet = await hasInternetConnection();

    if (!hasInternet) {
      debugPrint('🔴 OFFLINE MODE: Using ${offlineWords.length} random words');
      return offlineWords.toBuiltSet();
    }

    // Modo ONLINE: intentar obtener desde Supabase
    final supabaseWords = await fetchWordsFromSupabase();

    if (supabaseWords == null || supabaseWords.isEmpty) {
      debugPrint(
        '⚠️  Supabase failed: Fallback to ${offlineWords.length} random words',
      );
      return offlineWords.toBuiltSet();
    }

    debugPrint('🟢 ONLINE MODE: Using ${supabaseWords.length} Supabase words');
    return supabaseWords;
  }

  /// Obtiene palabras combinadas: Supabase + locales (DEPRECATED - usar fetchWords)
  static Future<BuiltSet<String>> fetchCombinedWords(
    BuiltSet<String> localWords,
  ) async {
    // Ahora simplemente usa fetchWords que maneja online/offline
    return fetchWords();
  }

  /// Crea la tabla 'words' en Supabase si no existe (solo para referencia)
  /// Ejecuta este SQL en tu dashboard de Supabase:
  ///
  /// CREATE TABLE IF NOT EXISTS words (
  ///   id SERIAL PRIMARY KEY,
  ///   word TEXT UNIQUE NOT NULL,
  ///   created_at TIMESTAMP DEFAULT NOW()
  /// );
  ///
  /// INSERT INTO words (word) VALUES
  /// ('darkrippers'),
  /// ('kirito'),
  /// ('eromechi'),
  /// ('pablini'),
  /// ('secuaz'),
  /// ('nino'),
  /// ('celismor'),
  /// ('wesuangelito')
  /// ON CONFLICT (word) DO NOTHING;
}
