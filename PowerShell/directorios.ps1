param (
    [string]$Ruta = $null  # Parámetro opcional para la ruta del directorio
)

# Limpiar pantalla
Clear-Host

# Función para validar si la ruta ingresada es un directorio válido
function Validar-Directorio {
    param ([string]$ruta)

    if ([string]::IsNullOrWhiteSpace($ruta)) {
        Write-Host "Error: La ruta no puede estar vacía." -ForegroundColor Red
        return $false
    }

    if (-not (Test-Path -Path $ruta -PathType Container)) {
        Write-Host "Error: La ruta '$ruta' no es un directorio válido." -ForegroundColor Red
        return $false
    }
    return $true
}

# Si la ruta pasada como parámetro es inválida o vacía, pedirla manualmente
if (-not (Validar-Directorio $Ruta)) {
    do {
        $Ruta = Read-Host "Ingrese la ruta de un directorio válido"
    } while (-not (Validar-Directorio $Ruta))
}

# Arreglo de extensiones que se consideran ejecutables (en minúsculas y sin el punto)
$extensionesEjecutables = @(
    "exe", "bat", "cmd", "msi", "com", "vbs", "wsf", "scr", "dll", 
    "py", "pl", "jar", "sh", "apk", "run", "appimage"
)

# Función para contar archivos ejecutables basándose en su extensión
function Contar-Ejecutables {
    param ([string]$ruta)
    $count = 0
    $files = Get-ChildItem -Path $ruta -File -Recurse
    foreach ($file in $files) {
        # Se obtiene la extensión sin el punto y en minúsculas
        $ext = $file.Extension.TrimStart(".").ToLower()
        if ($extensionesEjecutables -contains $ext) {
            $count++
        }
    }
    return $count
}

# Función para contar archivos estándar (aquellos cuya extensión no se encuentra en la lista de ejecutables)
function Contar-Archivos {
    param ([string]$ruta)
    $count = 0
    $files = Get-ChildItem -Path $ruta -File -Recurse
    foreach ($file in $files) {
        $ext = $file.Extension.TrimStart(".").ToLower()
        if (-not ($extensionesEjecutables -contains $ext)) {
            $count++
        }
    }
    return $count
}

# Función para contar subdirectorios dentro del directorio
function Contar-Subdirectorios {
    param ([string]$ruta)
    return (Get-ChildItem -Path $ruta -Directory -Recurse).Count
}

# Cálculo de archivos y directorios
$ejecutables = Contar-Ejecutables -ruta $Ruta
$archivos    = Contar-Archivos -ruta $Ruta
$subdirectorios = Contar-Subdirectorios -ruta $Ruta

# Mostrar resultados
Write-Host "===== Análisis del Directorio =====" -ForegroundColor Cyan
Write-Host "Ruta analizada: $Ruta" -ForegroundColor Yellow
Write-Host "Número de archivos estándar: $archivos" -ForegroundColor Green
Write-Host "Número de subdirectorios: $subdirectorios" -ForegroundColor Red
Write-Host "Número de archivos ejecutables: $ejecutables" -ForegroundColor Magenta
