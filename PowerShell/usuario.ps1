# Limpiar pantalla al inicio
Clear-Host

# Función para solicitar el nombre de usuario al usuario
function Solicitar-Usuario {
    param ([string]$mensaje)
    while ($true) {
        $usuario = Read-Host "$mensaje (introduzca el nombre de usuario)"
        if ($usuario -match "^[a-zA-Z0-9._-]+$" -and $usuario.Length -gt 0) {
            return $usuario
        }
        Write-Host "Error: Nombre de usuario inválido. Solo se permiten letras, números, '.' '_' y '-'." -ForegroundColor Red
    }
}

# Función para verificar si un usuario existe en el sistema
function Usuario-Existe {
    param ([string]$usuario)

    $usuarioObj = Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue
    return $usuarioObj -ne $null  # Devuelve $true si el usuario existe, $false si no
}

# Función para obtener el UID (SID en Windows) de un usuario
function Obtener-UID {
    param ([string]$usuario)

    $usuarioObj = Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue
    if ($usuarioObj) {
        return $usuarioObj.SID
    }
    return $null
}

# Función principal del menú
function Menu-Usuarios {
    while ($true) {
        Write-Host "`n===== Menú de Usuarios =====" -ForegroundColor Cyan
        Write-Host "1. Verificar la existencia de un usuario"
        Write-Host "2. Conocer el UID (SID) de un usuario"
        Write-Host "3. Salir"

        $opcion = Read-Host "Seleccione una opción (1-3)"

        switch ($opcion) {
            "1" {
                $usuario = Solicitar-Usuario "Ingrese el usuario a verificar"
                if (Usuario-Existe $usuario) {
                    Write-Host "✔ El usuario '$usuario' existe en el sistema." -ForegroundColor Green
                } else {
                    Write-Host "✖ El usuario '$usuario' NO existe en el sistema." -ForegroundColor Red
                }
            }
            "2" {
                $usuario = Solicitar-Usuario "Ingrese el usuario para obtener su UID"
                $uid = Obtener-UID $usuario
                if ($uid) {
                    Write-Host "✔ El UID (SID) del usuario '$usuario' es: $uid" -ForegroundColor Green
                } else {
                    Write-Host "✖ No se pudo obtener el UID. Es posible que el usuario no exista." -ForegroundColor Red
                }
            }
            "3" {
                Write-Host "Saliendo del programa..." -ForegroundColor Yellow
                exit
            }
            default {
                Write-Host "Error: Opción inválida. Introduzca un número entre 1 y 3." -ForegroundColor Red
            }
        }
    }
}

# Ejecutar el menú
Menu-Usuarios
