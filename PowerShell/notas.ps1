param (
    [AllowNull()]
    [string]$nota = $null  # Se recibe como string para validación
)

# Limpiar pantalla
Clear-Host

# Función para validar si la entrada es un número válido en el rango correcto
function Validar-Nota ($entrada) {
    if ($entrada -match '^\d+(\.\d+)?$') {  # Verifica que la entrada sea un número decimal válido
        $num = [double]$entrada
        if ($num -ge 0 -and $num -le 20) {
            return $num  # Devuelve el número convertido correctamente
        }
    }
    return $null  # Si no es un número válido, retorna null
}

# Mensaje inicial
Write-Host "===== Evaluación de Calificaciones =====" -ForegroundColor Cyan

# Validación del parámetro si se pasó por línea de comandos
$notaValidada = Validar-Nota $nota

# 🚨 Si el parámetro es incorrecto, mostrar error ANTES de solicitar la nota
if ($nota -ne $null -and $notaValidada -eq $null) {
    Write-Host "Error: El valor proporcionado en el parámetro '-nota' es inválido. Ingrese un número entre 0 y 20." -ForegroundColor Red
}

# Si el parámetro es inválido o no se pasó, pedir la nota manualmente
while ($notaValidada -eq $null) {
    $entrada = Read-Host "Ingrese su nota (0-20)"
    $notaValidada = Validar-Nota $entrada

    if ($notaValidada -eq $null) {
        Write-Host "Error: Ingrese un valor numérico entre 0 y 20." -ForegroundColor Red
    }
}

# Evaluación de la nota con switch
switch ($notaValidada) {
    { $_ -ge 16 -and $_ -le 20 } { $mensaje = "Muy bueno"; break }
    { $_ -ge 14 -and $_ -lt 16 } { $mensaje = "Bueno"; break }
    { $_ -ge 12 -and $_ -lt 14 } { $mensaje = "Lo suficientemente bueno"; break }
    { $_ -ge 10 -and $_ -lt 12 } { $mensaje = "Medio"; break }
    default { $mensaje = "Insuficiente" }
}

# Mostrar el resultado final
Write-Host "Su calificación es: $mensaje" -ForegroundColor Green
