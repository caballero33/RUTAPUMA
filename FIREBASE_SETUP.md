# Configuración de Firebase para RUTAPUMA

Esta guía te ayudará a configurar Firebase Console para tu aplicación RUTAPUMA.

## Paso 1: Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Nombre del proyecto: **RUTAPUMA** (o el nombre que prefieras)
4. Acepta los términos y haz clic en "Continuar"
5. Puedes desactivar Google Analytics si no lo necesitas por ahora
6. Haz clic en "Crear proyecto"

## Paso 2: Agregar App Android

1. En la página principal del proyecto, haz clic en el ícono de Android
2. **Nombre del paquete de Android**: `com.unah.rutapuma.rutapuma`
3. **Sobrenombre de la app** (opcional): `RUTAPUMA`
4. Haz clic en "Registrar app"
5. **Descarga el archivo `google-services.json`**
6. Coloca el archivo en: `android/app/google-services.json`

> ⚠️ **IMPORTANTE**: El archivo `google-services.json` ya debe estar en tu proyecto. Si descargaste uno nuevo, reemplázalo.

## Paso 3: Configurar Authentication

1. En el menú lateral, ve a **Build** > **Authentication**
2. Haz clic en "Get started"
3. En la pestaña "Sign-in method", haz clic en "Email/Password"
4. Activa el interruptor "Email/Password"
5. Haz clic en "Save"

## Paso 4: Configurar Realtime Database

1. En el menú lateral, ve a **Build** > **Realtime Database**
2. Haz clic en "Create Database"
3. Selecciona la ubicación más cercana (ej: `us-central1`)
4. Selecciona "Start in **test mode**" por ahora
5. Haz clic en "Enable"

### Configurar Reglas de Seguridad

Una vez creada la base de datos, ve a la pestaña "Rules" y reemplaza las reglas con:

\`\`\`json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "buses": {
      ".read": "auth != null",
      "$busId": {
        ".write": "auth != null && (
          root.child('users').child(auth.uid).child('role').val() === 'DRIVER' ||
          data.child('driverId').val() === auth.uid
        )"
      }
    },
    "routes": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() === 'DRIVER'"
    }
  }
}
\`\`\`

**Explicación de las reglas:**
- **users**: Los usuarios solo pueden leer/escribir sus propios datos
- **buses**: Todos pueden leer, pero solo los DRIVERS pueden escribir
- **routes**: Todos pueden leer, pero solo los DRIVERS pueden crear/editar rutas

Haz clic en "Publish" para guardar las reglas.

## Paso 5: Configurar Cloud Messaging (Notificaciones)

1. En el menú lateral, ve a **Build** > **Cloud Messaging**
2. Si te pide configurar, sigue los pasos (generalmente ya está configurado)
3. No necesitas hacer nada más aquí por ahora

## Paso 6: Verificar Configuración

1. Ve a **Project settings** (ícono de engranaje en el menú lateral)
2. En la pestaña "General", verifica que tu app Android esté listada
3. En la pestaña "Cloud Messaging", verifica que tengas un "Server key"

## Paso 7: (Opcional) Configurar Storage

Si quieres permitir que los usuarios suban fotos de perfil:

1. En el menú lateral, ve a **Build** > **Storage**
2. Haz clic en "Get started"
3. Selecciona "Start in test mode"
4. Haz clic en "Next" y luego "Done"

## Notas Importantes

> ⚠️ **SEGURIDAD**: Las reglas en "test mode" permiten acceso completo. Asegúrate de actualizar las reglas de seguridad antes de lanzar la app en producción.

> 💡 **PLAN GRATUITO**: Firebase tiene un plan gratuito (Spark) que es suficiente para desarrollo y pruebas. Para producción con muchos usuarios, considera el plan Blaze (pago por uso).

## Próximos Pasos

Una vez completada la configuración:
1. Verifica que el archivo `google-services.json` esté en `android/app/`
2. Ejecuta `flutter pub get`
3. Ejecuta `flutter run` para probar la app
4. Intenta registrarte con un correo y contraseña
5. Verifica en Firebase Console > Authentication que el usuario se creó correctamente
