import 'dart:math';

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

  /// Palabras base (incluyen las personalizadas mezcladas con muchas otras)
  static const List<String> baseWords = [
    // Palabras personalizadas de Supabase MEZCLADAS con otras
    'darkrippers', 'kirito', 'eromechi', 'pablini', 'secuaz', 'nino',
    'celismor', 'wesuangelito',
    // Animales (200+ palabras)
    'perro', 'gato', 'leon', 'tigre', 'elefante', 'jirafa', 'zebra', 'mono',
    'panda', 'koala', 'delfin', 'ballena', 'tiburon', 'aguila', 'halcon',
    'pinguino', 'oso', 'lobo', 'zorro', 'conejo', 'raton', 'caballo', 'vaca',
    'oveja', 'cerdo', 'gallina', 'pato', 'ganso', 'pavo', 'burro', 'mula',
    'camello', 'llama', 'alpaca', 'rinoceronte', 'hipopotamo', 'cocodrilo',
    'serpiente', 'lagarto', 'tortuga', 'rana', 'sapo', 'pulpo', 'calamar',
    'medusa', 'estrellademar', 'cangrejo', 'langosta', 'camaron', 'almeja',
    'ostra', 'caracol', 'babosa', 'hormiga', 'abeja', 'avispa', 'mosca',
    'mosquito', 'mariposa', 'oruga', 'escarabajo', 'mariquita', 'libelula',
    'grillo', 'saltamontes', 'araña', 'escorpion', 'ciempies', 'lombriz',
    'murcielago', 'ardilla', 'castor', 'nutria', 'foca', 'morsa', 'lemur',
    'tarantula', 'cobra', 'piton', 'anaconda', 'boa', 'iguana', 'camaleon',
    'gecko', 'dragon', 'dinosaurio', 'mamut', 'smilodon', 'pterodactilo',
    // Frutas y vegetales (100+ palabras)
    'manzana', 'pera', 'naranja', 'banana', 'uva', 'fresa', 'sandia', 'melon',
    'piña', 'mango', 'papaya', 'kiwi', 'cereza', 'durazno', 'ciruela', 'limon',
    'lima', 'toronja', 'mandarina', 'granada', 'coco', 'datil', 'higo',
    'frambuesa', 'mora', 'arandano', 'grosella', 'guayaba', 'maracuya',
    'carambola', 'lichi', 'rambutan', 'pitahaya', 'nispero', 'membrillo',
    'chirimoya', 'guanabana', 'tamarindo', 'zapote', 'mamey', 'tomate',
    'pepino', 'zanahoria', 'lechuga', 'espinaca', 'brocoli', 'coliflor',
    'calabaza', 'zapallo', 'berenjena', 'pimiento', 'chile', 'cebolla', 'ajo',
    'puerro', 'apio', 'rabano', 'nabo', 'remolacha', 'papa', 'batata', 'yuca',
    'camote', 'jengibre', 'cúrcuma', 'albahaca', 'cilantro', 'perejil',
    'oregano', 'tomillo', 'romero', 'menta', 'hierba', 'rucula', 'acelga',
    // Colores (50+ palabras)
    'rojo', 'azul', 'verde', 'amarillo', 'morado', 'rosa', 'negro', 'blanco',
    'gris', 'cafe', 'turquesa', 'violeta', 'dorado', 'plateado', 'indigo',
    'naranja', 'purpura', 'cyan', 'magenta', 'beige', 'marron', 'ocre',
    'carmesi', 'escarlata', 'granate', 'borgoña', 'salmon', 'coral', 'fucsia',
    'lavanda', 'lila', 'amatista', 'jade', 'esmeralda', 'zafiro', 'rubi',
    'topacio', 'ambar', 'perla', 'marfil', 'crema', 'vainilla', 'caramelo',
    'chocolate', 'sepia', 'arena', 'tierra', 'oliva', 'musgo', 'bosque',
    // Países y ciudades (100+ palabras)
    'mexico', 'españa', 'francia', 'italia', 'japon', 'china', 'brasil',
    'argentina', 'peru', 'chile', 'colombia', 'ecuador', 'canada', 'alemania',
    'inglaterra', 'portugal', 'grecia', 'egipto', 'india', 'rusia', 'australia',
    'venezuela', 'bolivia', 'paraguay', 'uruguay', 'panama', 'costarica',
    'nicaragua', 'honduras', 'guatemala', 'salvador', 'cuba', 'jamaica',
    'haiti', 'republica', 'dominicana', 'suiza', 'austria', 'belgica',
    'holanda', 'dinamarca', 'noruega', 'suecia', 'finlandia', 'islandia',
    'irlanda', 'escocia', 'gales', 'polonia', 'hungria', 'rumania', 'bulgaria',
    'croacia', 'serbia', 'turquia', 'israel', 'arabia', 'iran', 'irak',
    'afganistan', 'pakistan', 'bangladesh', 'myanmar', 'tailandia', 'vietnam',
    'malasia', 'indonesia', 'filipinas', 'corea', 'taiwan', 'mongolia',
    'nepal', 'tibet', 'butan', 'srilanka', 'maldivas', 'seychelles',
    'madagascar', 'mauricio', 'sudafrica', 'kenia', 'tanzania', 'uganda',
    'etiopia', 'somalia', 'marruecos', 'argelia', 'tunez', 'libia', 'nigeria',
    'ghana', 'senegal', 'mali', 'niger', 'chad', 'sudan', 'congo', 'zimbabwe',
    // Objetos cotidianos (150+ palabras)
    'mesa', 'silla', 'puerta', 'ventana', 'libro', 'lapiz', 'papel', 'telefono',
    'computadora', 'reloj', 'lampara', 'cama', 'sofa', 'espejo', 'television',
    'radio', 'altavoz', 'auricular', 'microfono', 'camara', 'foto', 'album',
    'cuadro', 'pintura', 'escultura', 'florero', 'cortina', 'alfombra',
    'almohada', 'cobija', 'sabana', 'toalla', 'jabon', 'champu', 'cepillo',
    'peine', 'navaja', 'tijera', 'aguja', 'hilo', 'boton', 'cremallera',
    'cinturon', 'corbata', 'bufanda', 'guante', 'gorro', 'sombrero', 'gafas',
    'reloj', 'pulsera', 'collar', 'anillo', 'arete', 'pendiente', 'broche',
    'mochila', 'maleta', 'bolso', 'cartera', 'monedero', 'paraguas', 'baston',
    'llave', 'candado', 'cerradura', 'picaporte', 'manija', 'perilla', 'grifo',
    'llave', 'tuberia', 'ducha', 'bañera', 'inodoro', 'lavabo', 'fregadero',
    'estufa', 'horno', 'microondas', 'refrigerador', 'congelador', 'lavadora',
    'secadora', 'plancha', 'aspiradora', 'escoba', 'trapeador', 'cubo',
    'balde', 'cesta', 'canasta', 'caja', 'baul', 'armario', 'estante',
    'cajón', 'percha', 'gancho', 'clavo', 'tornillo', 'tuerca', 'martillo',
    'destornillador', 'alicate', 'llave', 'sierra', 'taladro', 'nivel',
    'regla', 'cinta', 'pegamento', 'cinta', 'adhesivo', 'pincel', 'brocha',
    'rodillo', 'paleta', 'espatula', 'cubo', 'bandeja', 'plato', 'vaso',
    'taza', 'jarra', 'botella', 'olla', 'sarten', 'cacerola', 'cazo',
    'cuchara', 'tenedor', 'cuchillo', 'cucharón', 'espumadera', 'colador',
    'rallador', 'pelador', 'abridor', 'sacacorchos', 'tabla', 'mortero',
    // Naturaleza (100+ palabras)
    'arbol', 'flor', 'rio', 'mar', 'montaña', 'bosque', 'desierto', 'nube',
    'lluvia', 'sol', 'luna', 'estrella', 'viento', 'rayo', 'nieve', 'hielo',
    'niebla', 'neblina', 'rocio', 'escarcha', 'granizo', 'tormenta', 'huracan',
    'tornado', 'ciclon', 'tifon', 'tsunami', 'terremoto', 'temblor', 'volcan',
    'erupcion', 'lava', 'magma', 'ceniza', 'crater', 'cumbre', 'pico', 'valle',
    'colina', 'loma', 'meseta', 'llanura', 'pradera', 'sabana', 'estepa',
    'tundra', 'taiga', 'selva', 'jungla', 'manglar', 'pantano', 'ciénaga',
    'marisma', 'delta', 'estuario', 'bahia', 'golfo', 'estrecho', 'canal',
    'peninsula', 'istmo', 'cabo', 'punta', 'isla', 'islote', 'archipielago',
    'atolon', 'arrecife', 'coral', 'alga', 'plancton', 'arena', 'grava',
    'piedra', 'roca', 'mineral', 'cristal', 'diamante', 'cuarzo', 'granito',
    'marmol', 'basalto', 'obsidiana', 'carbon', 'petroleo', 'gas', 'oro',
    'plata', 'cobre', 'hierro', 'acero', 'aluminio', 'bronce', 'laton',
    'plomo', 'zinc', 'estaño', 'mercurio', 'uranio', 'plutonio',
    // Verbos (100+ palabras)
    'correr', 'saltar', 'nadar', 'volar', 'caminar', 'bailar', 'cantar', 'reir',
    'llorar',
    'dormir',
    'comer',
    'beber',
    'jugar',
    'trabajar',
    'estudiar',
    'leer',
    'escribir', 'dibujar', 'pintar', 'cocinar', 'limpiar', 'lavar', 'secar',
    'planchar', 'coser', 'tejer', 'bordar', 'construir', 'destruir', 'crear',
    'inventar', 'diseñar', 'fabricar', 'producir', 'vender', 'comprar', 'pagar',
    'cobrar', 'gastar', 'ahorrar', 'invertir', 'ganar', 'perder', 'encontrar',
    'buscar', 'mirar', 'ver', 'observar', 'vigilar', 'espiar', 'escuchar',
    'oir',
    'sentir',
    'tocar',
    'oler',
    'probar',
    'saborear',
    'pensar',
    'recordar',
    'olvidar', 'imaginar', 'soñar', 'desear', 'querer', 'necesitar', 'deber',
    'poder', 'saber', 'conocer', 'aprender', 'enseñar', 'explicar', 'entender',
    'comprender',
    'hablar',
    'decir',
    'contar',
    'narrar',
    'preguntar',
    'responder',
    'contestar',
    'gritar',
    'susurrar',
    'murmurar',
    'llamar',
    'nombrar',
    'saludar',
    'despedir',
    'invitar',
    'aceptar',
    'rechazar',
    'negar',
    'afirmar',
    'asegurar',
    // Adjetivos (100+ palabras)
    'grande', 'pequeño', 'alto', 'bajo', 'rapido', 'lento', 'fuerte', 'debil',
    'feliz', 'triste', 'bonito', 'feo', 'nuevo', 'viejo', 'caliente', 'frio',
    'largo',
    'corto',
    'ancho',
    'estrecho',
    'grueso',
    'delgado',
    'gordo',
    'flaco',
    'pesado', 'ligero', 'duro', 'blando', 'suave', 'aspero', 'liso', 'rugoso',
    'seco', 'humedo', 'mojado', 'empapado', 'limpio', 'sucio', 'brillante',
    'opaco', 'transparente', 'translucido', 'oscuro', 'claro', 'luminoso',
    'tenebroso', 'alegre', 'melancolico', 'animado', 'aburrido', 'interesante',
    'emocionante', 'asombroso', 'increible', 'fantastico', 'maravilloso',
    'horrible', 'terrible', 'espantoso', 'asqueroso', 'delicioso', 'sabroso',
    'dulce',
    'salado',
    'amargo',
    'acido',
    'picante',
    'suave',
    'fuerte',
    'intenso',
    'leve', 'profundo', 'superficial', 'interno', 'externo', 'superior',
    'inferior', 'anterior', 'posterior', 'derecho', 'izquierdo', 'central',
    'lateral',
    'vertical',
    'horizontal',
    'diagonal',
    'paralelo',
    'perpendicular',
    'circular', 'cuadrado', 'rectangular', 'triangular', 'ovalado', 'esférico',
    // Profesiones (80+ palabras)
    'doctor', 'maestro', 'ingeniero', 'abogado', 'chef', 'artista', 'musico',
    'deportista', 'escritor', 'policia', 'bombero', 'piloto', 'enfermera',
    'dentista', 'veterinario', 'farmaceutico', 'psicologo', 'psiquiatra',
    'cirujano',
    'pediatra',
    'cardiologo',
    'dermatologo',
    'oculista',
    'oftalmologo',
    'arquitecto', 'diseñador', 'programador', 'desarrollador', 'analista',
    'contador',
    'economista',
    'administrador',
    'gerente',
    'director',
    'presidente',
    'secretario',
    'asistente',
    'recepcionista',
    'cajero',
    'vendedor',
    'comerciante',
    'empresario', 'emprendedor', 'inversor', 'banquero', 'corredor', 'agente',
    'periodista', 'reportero', 'presentador', 'locutor', 'actor', 'actriz',
    'cantante', 'bailarin', 'modelo', 'fotografo', 'camarografo', 'editor',
    'productor', 'director', 'guionista', 'compositor', 'poeta', 'novelista',
    'pintor',
    'escultor',
    'ceramista',
    'joyero',
    'relojero',
    'sastre',
    'modista',
    'carpintero', 'plomero', 'electricista', 'mecanico', 'soldador', 'herrero',
    // Comidas (100+ palabras)
    'pizza', 'hamburguesa', 'pasta', 'arroz', 'pan', 'queso', 'leche', 'huevo',
    'carne', 'pollo', 'pescado', 'sopa', 'ensalada', 'postre', 'helado', 'taco',
    'burrito',
    'quesadilla',
    'enchilada',
    'tamale',
    'tortilla',
    'arepa',
    'empanada',
    'croqueta', 'ceviche', 'sushi', 'ramen', 'curry', 'paella', 'gazpacho',
    'fabada', 'cocido', 'guiso', 'estofado', 'asado', 'parrilla', 'barbacoa',
    'filete', 'chuleta', 'costilla', 'salchicha', 'chorizo', 'jamon', 'tocino',
    'pate', 'salami', 'mortadela', 'atun', 'salmon', 'trucha', 'bacalao',
    'merluza', 'sardina', 'anchoa', 'mariscos', 'paella', 'risotto', 'lasagna',
    'ravioli', 'gnocchi', 'fettuccine', 'espagueti', 'macarrones', 'canelones',
    'crepe', 'waffle', 'pancake', 'muffin', 'donut', 'croissant', 'bagel',
    'pretzel',
    'galleta',
    'bizcocho',
    'pastel',
    'tarta',
    'pie',
    'flan',
    'gelatina',
    'mousse', 'tiramisu', 'brownie', 'cookie', 'churro', 'buñuelo', 'rosquilla',
    'merengue', 'alfajor', 'mazapan', 'turron', 'polvoron', 'mantecado',
    'yogurt', 'nata', 'mantequilla', 'margarina', 'miel', 'mermelada', 'jalea',
    // Deportes (50+ palabras)
    'futbol',
    'basquetbol',
    'tenis',
    'natacion',
    'ciclismo',
    'atletismo',
    'boxeo',
    'yoga', 'karate', 'volleyball', 'beisbol', 'golf', 'hockey', 'surf',
    'esqui', 'snowboard', 'patinaje', 'escalada', 'alpinismo', 'senderismo',
    'camping',
    'pesca',
    'caza',
    'tiro',
    'arqueria',
    'esgrima',
    'judo',
    'taekwondo',
    'kung', 'aikido', 'capoeira', 'lucha', 'wrestling', 'rugby', 'futbol',
    'americano',
    'cricket',
    'badminton',
    'squash',
    'raquetbol',
    'polo',
    'waterpolo',
    'buceo',
    'snorkel',
    'vela',
    'remo',
    'kayak',
    'canoa',
    'rafting',
    'parapente',
    // Emociones y sentimientos (50+ palabras)
    'amor',
    'odio',
    'miedo',
    'alegria',
    'tristeza',
    'enojo',
    'sorpresa',
    'calma',
    'ansiedad', 'estres', 'preocupacion', 'nerviosismo', 'panico', 'terror',
    'horror', 'angustia', 'desesperacion', 'frustracion', 'irritacion', 'rabia',
    'furia',
    'colera',
    'resentimiento',
    'rencor',
    'venganza',
    'celos',
    'envidia',
    'codicia', 'avaricia', 'orgullo', 'vanidad', 'soberbia', 'arrogancia',
    'humildad', 'modestia', 'verguenza', 'culpa', 'remordimiento', 'pena',
    'dolor', 'sufrimiento', 'tormento', 'agonia', 'placer', 'gozo', 'felicidad',
    'dicha', 'jubilo', 'euforia', 'extasis', 'esperanza', 'ilusion', 'deseo',
    // Tecnología (80+ palabras)
    'internet', 'software', 'hardware', 'codigo', 'programa', 'aplicacion',
    'sistema', 'red', 'servidor', 'datos', 'pantalla', 'teclado', 'mouse',
    'monitor', 'procesador', 'memoria', 'disco', 'usb', 'cable', 'wifi',
    'bluetooth', 'router', 'modem', 'antena', 'señal', 'frecuencia', 'banda',
    'navegador', 'buscador', 'correo', 'email', 'mensaje', 'chat', 'video',
    'audio', 'imagen', 'archivo', 'carpeta', 'documento', 'texto', 'fuente',
    'formato', 'extension', 'compresion', 'descompresion', 'encriptacion',
    'desencriptacion', 'contraseña', 'usuario', 'cuenta', 'perfil', 'sesion',
    'login', 'logout', 'registro', 'actualizacion', 'descarga', 'carga',
    'sincronizacion', 'respaldo', 'backup', 'restauracion', 'virus', 'malware',
    'antivirus', 'firewall', 'seguridad', 'privacidad', 'cookie', 'cache',
    'base', 'tabla', 'registro', 'campo', 'consulta', 'reporte',
    // Música (50+ palabras)
    'guitarra', 'piano', 'bateria', 'violin', 'flauta', 'trompeta', 'saxofon',
    'clarinete', 'oboe', 'fagot', 'tuba', 'trombon', 'corno', 'armonica',
    'acordeon', 'banjo', 'mandolina', 'ukelele', 'arpa', 'lira', 'clavecin',
    'organo', 'sintetizador', 'teclado', 'xilofon', 'marimba', 'vibrafono',
    'timpani', 'bongo', 'conga', 'tambor', 'pandero', 'castañuela', 'maracas',
    'guiro', 'claves', 'triangulo', 'campana', 'gong', 'platillos', 'bombo',
    'caja', 'redoblante', 'nota', 'acorde', 'melodia', 'armonia', 'ritmo',
    'tempo', 'compas', 'escala',
    // Más palabras variadas (300+ palabras)
    'casa', 'edificio', 'calle', 'plaza', 'parque', 'escuela', 'hospital',
    'tienda', 'mercado', 'restaurante', 'cafe', 'biblioteca', 'museo', 'cine',
    'teatro', 'estadio', 'gimnasio', 'piscina', 'playa', 'ciudad', 'pueblo',
    'campo', 'granja', 'jardin', 'huerto', 'pradera', 'selva', 'isla', 'volcan',
    'cueva', 'cascada', 'lago', 'oceano', 'bahia', 'peninsula', 'continente',
    'planeta', 'galaxia', 'universo', 'espacio', 'cometa', 'satelite', 'cohete',
    'avion', 'barco', 'tren', 'autobus', 'carro', 'bicicleta', 'moto', 'camion',
    'primavera', 'verano', 'otoño', 'invierno', 'enero', 'febrero', 'marzo',
    'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre',
    'noviembre',
    'diciembre',
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado', 'domingo', 'mañana', 'tarde', 'noche', 'mediodia', 'amanecer',
    'atardecer', 'medianoche', 'segundo', 'minuto', 'hora', 'dia', 'semana',
    'mes', 'año', 'siglo', 'decada', 'milenio', 'epoca', 'era', 'periodo',
    'fase',
    'etapa',
    'ciclo',
    'proceso',
    'inicio',
    'medio',
    'final',
    'principio',
    'conclusion', 'comienzo', 'termino', 'origen', 'destino', 'proposito',
    'objetivo', 'meta', 'logro', 'exito', 'fracaso', 'victoria', 'derrota',
    'triunfo',
    'conquista',
    'hazaña',
    'proeza',
    'aventura',
    'viaje',
    'expedicion',
    'excursion', 'paseo', 'recorrido', 'ruta', 'camino', 'sendero', 'vereda',
    'autopista', 'carretera', 'avenida', 'boulevard', 'callejon', 'pasaje',
    'historia', 'geografia', 'matematica', 'ciencia', 'fisica', 'quimica',
    'biologia', 'arte', 'musica', 'literatura', 'filosofia', 'politica',
    'economia', 'sociologia', 'psicologia', 'medicina', 'derecho', 'pedagogia',
    'astronomia',
    'geologia',
    'botanica',
    'zoologia',
    'ecologia',
    'antropologia',
    'arqueologia', 'paleontologia', 'lingüistica', 'semantica', 'sintaxis',
    'gramatica',
    'ortografia',
    'caligrafia',
    'tipografia',
    'imprenta',
    'editorial',
    'publicacion', 'revista', 'periodico', 'diario', 'boletin', 'gaceta',
    'catalogo',
    'folleto',
    'panfleto',
    'cartel',
    'poster',
    'pancarta',
    'letrero',
    'señal', 'simbolo', 'icono', 'emblema', 'insignia', 'escudo', 'bandera',
    'himno', 'cancion', 'poema', 'verso', 'estrofa', 'rima', 'prosa', 'cuento',
    'novela', 'relato', 'leyenda', 'mito', 'fabula', 'parabola', 'anecdota',
    'biografia', 'autobiografia', 'memoria', 'diario', 'cronica', 'ensayo',
    'tratado', 'manual', 'guia', 'tutorial', 'instructivo', 'receta', 'formula',
    'ecuacion', 'algoritmo', 'metodo', 'tecnica', 'estrategia', 'tactica',
    'plan', 'proyecto', 'propuesta', 'idea', 'concepto', 'nocion', 'teoria',
    'hipotesis', 'tesis', 'antitesis', 'sintesis', 'analisis', 'diagnostico',
    'pronostico', 'prediccion', 'profecia', 'augurio', 'presagio', 'señal',
    'indicio', 'pista', 'rastro', 'huella', 'marca', 'cicatriz', 'herida',
    'lesion', 'daño', 'perjuicio', 'perdida', 'carencia', 'falta', 'ausencia',
    'presencia', 'existencia', 'realidad', 'verdad', 'mentira', 'engaño',
    'trampa', 'ardid', 'astucia', 'inteligencia', 'sabiduria', 'conocimiento',
    'ignorancia', 'estupidez', 'tonteria', 'locura', 'cordura', 'sensatez',
    'razon',
    'logica',
    'coherencia',
    'consistencia',
    'contradiccion',
    'paradoja',
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

      // Obtiene TODAS las palabras de la tabla 'words'
      final response = await _client
          .from('words')
          .select('word')
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
      final builtWords = BuiltSet<String>.build((b) => b.addAll(words));
      return builtWords;
    } catch (e) {
      debugPrint('Error fetching from Supabase: $e');
      return null;
    }
  }

  /// Obtiene palabras: ONLINE y OFFLINE usan las mismas palabras base (más de 1000)
  static Future<BuiltSet<String>> fetchWords() async {
    final hasInternet = await hasInternetConnection();

    // Limitar a 300 palabras aleatorias para que el crucigrama se genere más rápido
    final random = Random();
    final selectedWords = <String>{};
    final baseWordsCopy = List<String>.from(baseWords);

    // Seleccionar 300 palabras aleatorias
    while (selectedWords.length < 300 && baseWordsCopy.isNotEmpty) {
      final index = random.nextInt(baseWordsCopy.length);
      selectedWords.add(baseWordsCopy[index]);
      baseWordsCopy.removeAt(index);
    }

    if (!hasInternet) {
      debugPrint('🔴 OFFLINE MODE: Using ${selectedWords.length} words');
      return BuiltSet<String>.build((b) => b.addAll(selectedWords));
    }

    // Modo ONLINE: intentar obtener desde Supabase
    final supabaseWords = await fetchWordsFromSupabase();

    if (supabaseWords == null || supabaseWords.isEmpty) {
      debugPrint(
        '⚠️  Supabase failed: Fallback to ${selectedWords.length} base words',
      );
      return BuiltSet<String>.build((b) => b.addAll(selectedWords));
    }

    // MODO ONLINE: Usar SOLO palabras de Supabase (sin mezclar con base)
    debugPrint(
      '🟢 ONLINE MODE: Using ONLY ${supabaseWords.length} words from Supabase',
    );
    return BuiltSet<String>.build((b) => b.addAll(supabaseWords));
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
  /// ('wesuangelito'),
  /// ('azuna'),
  /// ('carlos'),
  /// ('minecraft')
  /// ON CONFLICT (word) DO NOTHING;
  ///
  /// NOTA: Ahora se cargan TODAS las palabras de la tabla, no solo las de customWords
  ///

  /// Obtiene solo las palabras de la base de datos (para colorear)
  static Future<BuiltSet<String>> fetchDatabaseWords() async {
    final supabaseWords = await fetchWordsFromSupabase();
    return supabaseWords ?? BuiltSet<String>();
  }
}
