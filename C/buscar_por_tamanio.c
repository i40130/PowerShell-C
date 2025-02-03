#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <limits.h>

/* Prototipo de la función que realiza la búsqueda */
void search_files(const char *dir_path, off_t min_size, off_t max_size);

/**
 * El main se va a encargar de la siguiente lógica:
 *   - Valida el número de argumentos.
 *   - Convierte los argumentos de tamaño a números.
 *   - Verifica que el tamaño mínimo no sea mayor que el máximo.
 *   - Llama a la función search_files para procesar el directorio.
 */
int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Uso: %s <directorio> <tam_min> <tam_max>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    const char *dir_path = argv[1];
    char *endptr;

    /* Conversión del tamaño mínimo */
    errno = 0;
    off_t min_size = strtoll(argv[2], &endptr, 10);
    if (errno != 0 || *endptr != '\0') {
        fprintf(stderr, "Error: Tamaño mínimo '%s' no válido.\n", argv[2]);
        exit(EXIT_FAILURE);
    }

    /* Conversión del tamaño máximo */
    errno = 0;
    off_t max_size = strtoll(argv[3], &endptr, 10);
    if (errno != 0 || *endptr != '\0') {
        fprintf(stderr, "Error: Tamaño máximo '%s' no válido.\n", argv[3]);
        exit(EXIT_FAILURE);
    }

    if (min_size > max_size) {
        fprintf(stderr, "Error: El tamaño mínimo no puede ser mayor que el tamaño máximo.\n");
        exit(EXIT_FAILURE);
    }

    search_files(dir_path, min_size, max_size);

    return EXIT_SUCCESS;
}

/**
 * En la funcion de busqueda la logica es la siguiente:
 *   - Abre el directorio especificado.
 *   - Recorre sus entradas (sin entrar en subdirectorios).
 *   - Para cada fichero regular, obtiene la información mediante stat() y, si su
 *     tamaño se encuentra en el rango indicado, lo muestra por salida estándar.
 */
void search_files(const char *dir_path, off_t min_size, off_t max_size) {
    DIR *dir = opendir(dir_path);
    if (dir == NULL) {
        fprintf(stderr, "Error al abrir el directorio '%s': %s\n", dir_path, strerror(errno));
        exit(EXIT_FAILURE);
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        /* Omitir entradas especiales "." y ".." */
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0)
            continue;

        /* Construir la ruta completa del fichero */
        char full_path[PATH_MAX];
        if (snprintf(full_path, sizeof(full_path), "%s/%s", dir_path, entry->d_name) >= sizeof(full_path)) {
            fprintf(stderr, "Ruta demasiado larga: %s/%s\n", dir_path, entry->d_name);
            continue;
        }

        struct stat file_stat;
        if (stat(full_path, &file_stat) == -1) {
            fprintf(stderr, "Error al obtener información de '%s': %s\n", full_path, strerror(errno));
            continue;
        }

        /* Procesar solo ficheros regulares */
        if (S_ISREG(file_stat.st_mode)) {
            if (file_stat.st_size >= min_size && file_stat.st_size <= max_size) {
                printf("Archivo: %s\tTamaño: %lld bytes\n", full_path, (long long)file_stat.st_size);
            }
        }
    }

    closedir(dir);
}
