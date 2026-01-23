# Estructura de Base de Datos - RUTAPUMA

Esta es la estructura de datos en Firebase Realtime Database para la aplicación RUTAPUMA.

## Estructura General

\`\`\`
rutapuma-database/
├── users/
│   └── {uid}/
│       ├── uid: string
│       ├── email: string
│       ├── displayName: string
│       ├── role: "USER" | "DRIVER"
│       └── createdAt: ISO8601 timestamp
│
├── buses/
│   └── {busId}/
│       ├── busId: string
│       ├── driverId: string (uid del conductor)
│       ├── routeName: string
│       ├── location/
│       │   ├── latitude: number
│       │   └── longitude: number
│       ├── timestamp: ISO8601 timestamp
│       ├── isActive: boolean
│       ├── speed: number (km/h)
│       └── heading: number (0-360 degrees)
│
└── routes/
    └── {routeId}/
        ├── name: string
        ├── description: string
        ├── stops: array of objects
        └── updatedAt: ISO8601 timestamp
\`\`\`

## Detalles de Cada Nodo

### `/users/{uid}`

Almacena información de los usuarios registrados.

**Ejemplo:**
\`\`\`json
{
  "users": {
    "abc123xyz": {
      "uid": "abc123xyz",
      "email": "estudiante@unah.edu.hn",
      "displayName": "Juan Pérez",
      "role": "USER",
      "createdAt": "2026-01-18T16:00:00.000Z"
    },
    "def456uvw": {
      "uid": "def456uvw",
      "email": "conductor@unah.edu.hn",
      "displayName": "María García",
      "role": "DRIVER",
      "createdAt": "2026-01-18T16:05:00.000Z"
    }
  }
}
\`\`\`

**Campos:**
- `uid`: ID único del usuario (generado por Firebase Auth)
- `email`: Correo electrónico del usuario
- `displayName`: Nombre completo del usuario
- `role`: Rol del usuario (`USER` para estudiantes, `DRIVER` para conductores)
- `createdAt`: Fecha y hora de creación de la cuenta

### `/buses/{busId}`

Almacena la ubicación en tiempo real de los buses activos.

**Ejemplo:**
\`\`\`json
{
  "buses": {
    "bus_001": {
      "busId": "bus_001",
      "driverId": "def456uvw",
      "routeName": "Ruta Ciudad Universitaria",
      "location": {
        "latitude": 14.0818,
        "longitude": -87.1926
      },
      "timestamp": "2026-01-18T16:30:00.000Z",
      "isActive": true,
      "speed": 35.5,
      "heading": 180.0
    }
  }
}
\`\`\`

**Campos:**
- `busId`: ID único del bus (ej: `bus_001`, `bus_002`)
- `driverId`: UID del conductor que está manejando el bus
- `routeName`: Nombre de la ruta que está siguiendo
- `location`: Objeto con coordenadas GPS
  - `latitude`: Latitud en grados decimales
  - `longitude`: Longitud en grados decimales
- `timestamp`: Última actualización de ubicación
- `isActive`: Indica si el bus está actualmente en servicio
- `speed`: Velocidad actual en km/h
- `heading`: Dirección en grados (0° = Norte, 90° = Este, 180° = Sur, 270° = Oeste)

**Notas:**
- Los buses inactivos por más de 5 minutos no se muestran en el mapa
- Solo los conductores pueden actualizar la ubicación de los buses
- La ubicación se actualiza automáticamente cada pocos segundos mientras el conductor está activo

### `/routes/{routeId}`

Almacena información sobre las rutas de buses.

**Ejemplo:**
\`\`\`json
{
  "routes": {
    "route_cu": {
      "name": "Ruta Ciudad Universitaria",
      "description": "Ruta principal desde el centro hasta Ciudad Universitaria",
      "stops": [
        {
          "name": "Parque Central",
          "latitude": 14.0650,
          "longitude": -87.1720
        },
        {
          "name": "Mall Multiplaza",
          "latitude": 14.0723,
          "longitude": -87.1850
        },
        {
          "name": "UNAH - Entrada Principal",
          "latitude": 14.0818,
          "longitude": -87.1926
        }
      ],
      "updatedAt": "2026-01-18T15:00:00.000Z"
    }
  }
}
\`\`\`

**Campos:**
- `name`: Nombre de la ruta
- `description`: Descripción de la ruta
- `stops`: Array de paradas con nombre y coordenadas
- `updatedAt`: Última actualización de la ruta

## Reglas de Seguridad

Las reglas de seguridad están configuradas para:

1. **Users**: Solo el propio usuario puede leer/escribir sus datos
2. **Buses**: Todos los usuarios autenticados pueden leer, solo DRIVERS pueden escribir
3. **Routes**: Todos pueden leer, solo DRIVERS pueden crear/editar

Ver `FIREBASE_SETUP.md` para más detalles sobre las reglas de seguridad.

## Consultas Comunes

### Obtener todos los buses activos
\`\`\`dart
DatabaseService().getActiveBuses()
\`\`\`

### Obtener buses de una ruta específica
\`\`\`dart
DatabaseService().getBusesByRoute('Ruta Ciudad Universitaria')
\`\`\`

### Actualizar ubicación del bus (solo DRIVER)
\`\`\`dart
DatabaseService().updateBusLocation(
  busId: 'bus_001',
  driverId: currentUser.uid,
  routeName: 'Ruta Ciudad Universitaria',
  location: LatLng(14.0818, -87.1926),
  speed: 35.5,
  heading: 180.0,
)
\`\`\`

## Índices Recomendados

Para mejorar el rendimiento de las consultas, considera agregar estos índices en Firebase Console:

1. **Buses por ruta**: Índice en `buses` ordenado por `routeName`
2. **Buses activos**: Índice en `buses` ordenado por `isActive` y `timestamp`

Estos índices se pueden agregar en Firebase Console > Realtime Database > Rules > Indexes.
