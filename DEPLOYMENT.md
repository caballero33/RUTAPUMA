# Guía de Deployment para Play Store - RUTAPUMA

Esta guía te ayudará a preparar y subir tu aplicación RUTAPUMA a Google Play Store.

## Requisitos Previos

- Cuenta de Google Play Console ($25 USD pago único)
- Aplicación completamente funcional y probada
- Firebase configurado y funcionando
- Íconos y assets de la aplicación

## Paso 1: Generar Signing Key

La signing key es necesaria para firmar tu aplicación para release.

### 1.1 Crear el Keystore

Ejecuta este comando en la terminal (reemplaza los valores):

\`\`\`bash
keytool -genkey -v -keystore c:/Users/Dell\ 3535/Desktop/RUTAPHUMA/android/app/rutapuma-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias rutapuma
\`\`\`

Te pedirá:
- **Password**: Crea una contraseña segura y guárdala
- **Nombre y apellido**: Tu nombre o el de tu organización
- **Unidad organizativa**: UNAH o tu departamento
- **Organización**: Universidad Nacional Autónoma de Honduras
- **Ciudad**: Tegucigalpa
- **Estado**: Francisco Morazán
- **Código de país**: HN

> ⚠️ **MUY IMPORTANTE**: Guarda el archivo `.jks` y la contraseña en un lugar seguro. Si los pierdes, no podrás actualizar tu app en Play Store.

### 1.2 Crear archivo key.properties

Crea el archivo `android/key.properties` con este contenido:

\`\`\`properties
storePassword=TU_PASSWORD_AQUI
keyPassword=TU_PASSWORD_AQUI
keyAlias=rutapuma
storeFile=rutapuma-key.jks
\`\`\`

> ⚠️ **SEGURIDAD**: Agrega `key.properties` a `.gitignore` para no subir tus credenciales a Git.

### 1.3 Configurar build.gradle.kts

El archivo `android/app/build.gradle.kts` ya debe tener la configuración de signing. Si no, agrega esto antes del bloque `android`:

\`\`\`kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
\`\`\`

Y dentro del bloque `android`, agrega:

\`\`\`kotlin
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
\`\`\`

## Paso 2: Configurar Metadatos de la App

### 2.1 Actualizar pubspec.yaml

Asegúrate de tener la versión correcta:

\`\`\`yaml
version: 1.0.0+1
\`\`\`

- `1.0.0` es el número de versión (versionName)
- `+1` es el código de versión (versionCode)

### 2.2 Actualizar AndroidManifest.xml

Verifica que `android/app/src/main/AndroidManifest.xml` tenga:

\`\`\`xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    
    <application
        android:label="RUTAPUMA"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... resto de la configuración ... -->
    </application>
</manifest>
\`\`\`

## Paso 3: Crear Íconos de la App

### 3.1 Generar íconos

Necesitas un ícono de 1024x1024 px. Puedes usar herramientas como:
- [App Icon Generator](https://appicon.co/)
- [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/)

### 3.2 Reemplazar íconos

Coloca los íconos generados en:
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

## Paso 4: Generar el APK/AAB de Release

### 4.1 Limpiar el proyecto

\`\`\`bash
flutter clean
flutter pub get
\`\`\`

### 4.2 Generar AAB (recomendado para Play Store)

\`\`\`bash
flutter build appbundle --release
\`\`\`

El archivo se generará en: `build/app/outputs/bundle/release/app-release.aab`

### 4.3 (Opcional) Generar APK

\`\`\`bash
flutter build apk --release
\`\`\`

El archivo se generará en: `build/app/outputs/flutter-apk/app-release.apk`

## Paso 5: Probar el Build de Release

Antes de subir a Play Store, prueba el APK en un dispositivo real:

\`\`\`bash
flutter install --release
\`\`\`

Verifica que:
- La app se instala correctamente
- Firebase funciona (login, registro, base de datos)
- El mapa se carga correctamente
- Las notificaciones funcionan
- No hay crashes

## Paso 6: Crear Cuenta en Play Console

1. Ve a [Google Play Console](https://play.google.com/console/)
2. Crea una cuenta de desarrollador ($25 USD pago único)
3. Completa tu perfil de desarrollador

## Paso 7: Crear la App en Play Console

1. En Play Console, haz clic en "Crear app"
2. Completa la información:
   - **Nombre de la app**: RUTAPUMA
   - **Idioma predeterminado**: Español (Latinoamérica)
   - **Tipo de app**: Aplicación
   - **Gratis o de pago**: Gratis
3. Acepta las políticas y haz clic en "Crear app"

## Paso 8: Completar el Listing de la App

### 8.1 Información de la tienda

- **Título**: RUTAPUMA - Rastreo de Buses UNAH
- **Descripción corta**: Rastrea en tiempo real los buses de la UNAH
- **Descripción completa**:
  ```
  RUTAPUMA es la aplicación oficial para rastrear en tiempo real los buses de la Universidad Nacional Autónoma de Honduras (UNAH).

  Características:
  • Ubicación en tiempo real de todos los buses activos
  • Rutas y paradas de buses
  • Notificaciones cuando un bus está cerca
  • Interfaz intuitiva y fácil de usar
  • Modo oscuro

  Ideal para estudiantes y personal de la UNAH que necesitan planificar sus viajes.
  ```

### 8.2 Assets gráficos

Necesitas crear:
- **Ícono de la app**: 512x512 px
- **Gráfico de funciones**: 1024x500 px
- **Capturas de pantalla**: Mínimo 2, máximo 8 (16:9 o 9:16)
  - Tamaño recomendado: 1080x1920 px

### 8.3 Categorización

- **Categoría**: Mapas y navegación
- **Etiquetas**: buses, transporte, UNAH, Honduras

### 8.4 Información de contacto

- **Correo electrónico**: tu_correo@unah.edu.hn
- **Sitio web**: (opcional)
- **Política de privacidad**: (requerido si recopilas datos de usuarios)

## Paso 9: Configurar el Release

1. Ve a "Producción" en el menú lateral
2. Haz clic en "Crear nueva versión"
3. Sube el archivo AAB que generaste
4. Completa las notas de la versión:
   ```
   Versión 1.0.0
   - Lanzamiento inicial
   - Rastreo en tiempo real de buses
   - Autenticación de usuarios
   - Notificaciones push
   ```
5. Haz clic en "Guardar" y luego "Revisar versión"

## Paso 10: Completar el Cuestionario de Contenido

Play Console te pedirá completar varios cuestionarios:
- Clasificación de contenido
- Público objetivo
- Privacidad y seguridad de datos
- Permisos de la app

Responde honestamente según las características de tu app.

## Paso 11: Enviar para Revisión

1. Revisa toda la información
2. Haz clic en "Enviar para revisión"
3. Google revisará tu app (puede tardar de 1 a 7 días)

## Paso 12: Publicación

Una vez aprobada:
1. Recibirás un correo de Google
2. La app estará disponible en Play Store
3. Los usuarios podrán buscarla como "RUTAPUMA"

## Actualizaciones Futuras

Para actualizar la app:

1. Incrementa la versión en `pubspec.yaml`:
   \`\`\`yaml
   version: 1.0.1+2  # Incrementa el número después del +
   \`\`\`

2. Genera nuevo AAB:
   \`\`\`bash
   flutter build appbundle --release
   \`\`\`

3. En Play Console, crea una nueva versión y sube el AAB
4. Agrega notas de la versión
5. Envía para revisión

## Solución de Problemas

### Error: "App not signed"
- Verifica que `key.properties` esté configurado correctamente
- Asegúrate de que el archivo `.jks` exista

### Error: "Version code already used"
- Incrementa el número después del `+` en `pubspec.yaml`

### App rechazada
- Lee el correo de Google cuidadosamente
- Corrige los problemas mencionados
- Vuelve a enviar

## Recursos Adicionales

- [Documentación oficial de Flutter](https://docs.flutter.dev/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Console](https://console.firebase.google.com/)

## Checklist Final

Antes de subir a Play Store, verifica:

- [ ] Signing key generado y guardado de forma segura
- [ ] `key.properties` configurado
- [ ] Versión actualizada en `pubspec.yaml`
- [ ] Íconos de la app creados
- [ ] AAB generado sin errores
- [ ] App probada en dispositivo real
- [ ] Firebase funcionando correctamente
- [ ] Información de la tienda completa
- [ ] Assets gráficos listos
- [ ] Política de privacidad (si aplica)
- [ ] Cuestionarios completados
