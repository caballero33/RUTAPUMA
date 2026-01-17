# 🚌 RUTAPUMA

**Sistema de Rastreo de Buses para Estudiantes de UNAH Campus Cortés**

![RUTAPUMA](https://img.shields.io/badge/Flutter-3.29.3-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)
![Status](https://img.shields.io/badge/Status-En%20Desarrollo-yellow)

## 📱 Descripción

RUTAPUMA es una aplicación móvil desarrollada en Flutter para el seguimiento en tiempo real de los buses del servicio de transporte UNAH PUMAS en Campus Cortés. La aplicación permite a estudiantes rastrear la ubicación de los buses y a conductores compartir su ubicación en tiempo real.

## ✨ Características

### Para Estudiantes (USER)
- 🗺️ Visualización de buses en tiempo real en el mapa
- 🚏 Selector de rutas (14 rutas disponibles)
- 📍 Ubicación actual del usuario
- 🔔 Notificaciones de llegada de buses
- 📊 Historial de viajes

### Para Conductores (DRIVER)
- 📡 Compartir ubicación en tiempo real
- ▶️ Controles de inicio/pausa/detención de ruta
- 🛣️ Información de ruta asignada
- 👥 Gestión de pasajeros

## 🎨 Diseño

La aplicación utiliza la colorimetría oficial de UNAH PUMAS:
- **Amarillo Vibrante** (#FDD835) - Color principal
- **Azul Cian** (#00B8D4) - Elementos interactivos
- **Púrpura** (#7B1FA2) - Encabezados y títulos
- **Rosa** (#FF4081) - Acentos y botones

## 🛠️ Tecnologías

- **Flutter** 3.29.3
- **Dart** 3.7.2
- **Google Maps Flutter** - Integración de mapas
- **Provider** - Gestión de estado
- **Geolocator** - Servicios de ubicación
- **Permission Handler** - Gestión de permisos

## 📦 Estructura del Proyecto

```
lib/
├── constants/
│   └── colors.dart          # Colores UNAH PUMAS
├── models/
│   └── user_role.dart       # Modelos de usuario
├── screens/
│   ├── login_screen.dart    # Pantalla de inicio de sesión
│   └── map_screen.dart      # Pantalla del mapa
├── widgets/
│   ├── custom_button.dart   # Botón personalizado
│   └── custom_text_field.dart # Campo de texto personalizado
└── main.dart                # Punto de entrada
```

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK 3.29.3 o superior
- Dart 3.7.2 o superior
- Android Studio / VS Code
- Dispositivo Android/iOS o emulador

### Pasos

1. **Instalar dependencias**
```bash
flutter pub get
```

2. **Ejecutar la aplicación**
```bash
flutter run
```

## 🗺️ Configuración de Google Maps

Para integrar Google Maps, necesitarás configurar las API keys:

### Android
Edita `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

### iOS
Edita `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("TU_API_KEY_AQUI")
```

## 📋 Requisitos UNAH

Según el servicio de transporte UNAH PUMAS:
- ✅ Forma 003 (formulario de inscripción)
- ✅ Carnet de estudiante activo
- 🚌 14 rutas disponibles en Campus Cortés
- 🆓 Servicio gratuito y exclusivo para estudiantes

## 🔜 Próximas Funcionalidades

- [ ] Integración completa de Google Maps
- [ ] Backend para autenticación
- [ ] Base de datos en tiempo real (Firebase)
- [ ] Sistema de notificaciones push
- [ ] Gestión de las 14 rutas
- [ ] Horarios y tiempos estimados de llegada
- [ ] Verificación de estudiante con Forma 003
- [ ] Historial de viajes
- [ ] Configuración de perfil de usuario

## 🎯 Roadmap

### Fase 1: Frontend ✅ (Completado)
- [x] Diseño de UI/UX
- [x] Pantalla de login
- [x] Pantalla de mapa
- [x] Navegación entre pantallas
- [x] Widgets personalizados

### Fase 2: Integración de Mapas (Próximo)
- [ ] Configurar Google Maps API
- [ ] Mostrar mapa de Campus Cortés
- [ ] Marcadores de buses
- [ ] Rutas en el mapa

### Fase 3: Backend
- [ ] API de autenticación
- [ ] Base de datos de usuarios
- [ ] Sistema de ubicación en tiempo real
- [ ] Gestión de rutas

### Fase 4: Publicación
- [ ] Iconos y splash screen
- [ ] Optimización de rendimiento
- [ ] Pruebas en dispositivos reales
- [ ] Publicación en Play Store

## 👥 Tipos de Usuario

### Estudiante
- Visualiza buses en tiempo real
- Selecciona rutas específicas
- Recibe notificaciones

### Conductor
- Comparte ubicación en tiempo real
- Controla el estado de la ruta
- Gestiona el servicio

---

**Desarrollado con 💜 para la comunidad UNAH** 🐾
