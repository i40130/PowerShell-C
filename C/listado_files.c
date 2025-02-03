#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <limits.h>

#define OUTPUT_FILE "listado.txt"

/* Prototipos de funciones - se necesita trabajar con punteros*/
void list_files(const char *dir_path, const char *output_file);
void process_file(const char *dir_path, const char *file_name, FILE *fp);


int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <ruta_del_directorio>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    const char *dir_path = argv[1];
    list_files(dir_path, OUTPUT_FILE);

    return EXIT_SUCCESS;
}

/**
 * Esta función hace:
 * Le pasamos el directorio y el archivo de texto de salida
 * Abre el directorio indicado, recorre sus entradas (omitiento "." y "..") y
 * para cada entrada llama a process_file para procesarla.
 */
void list_files(const char *dir_path, const char *output_file) {
    DIR *dir = opendir(dir_path);
    if (dir == NULL) {
        fprintf(stderr, "Error al abrir el directorio '%s': %s\n", dir_path, strerror(errno));
        exit(EXIT_FAILURE);
    }

    FILE *fp = fopen(output_file, "w");
    if (fp == NULL) {
        fprintf(stderr, "Error al crear el fichero '%s': %s\n", output_file, strerror(errno));
        closedir(dir);
        exit(EXIT_FAILURE);
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        /* Omitir entradas especiales */
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0)
            continue;

        process_file(dir_path, entry->d_name, fp);
    }

    fclose(fp);
    closedir(dir);

    printf("Listado generado en '%s'\n", output_file);
}

/**
 * Funcion que procesa el fichero de texto:
 * Construye la ruta completa del archivo, obtiene sus atributos mediante stat()
 * y, si se trata de un fichero regular, escribe en el fichero de salida la siguiente
 * información: nombre, tamaño (en bytes) y fecha de última modificación.
 */
void process_file(const char *dir_path, const char *file_name, FILE *fp) {
    char full_path[PATH_MAX];
    if (snprintf(full_path, sizeof(full_path), "%s/%s", dir_path, file_name) >= sizeof(full_path)) {
        fprintf(stderr, "Ruta demasiado larga: %s/%s\n", dir_path, file_name);
        return;
    }

    struct stat file_stat;
    if (stat(full_path, &file_stat) == -1) {
        fprintf(stderr, "Error al obtener información de '%s': %s\n", full_path, strerror(errno));
        return;
    }

    if (S_ISREG(file_stat.st_mode)) {
        char time_str[100];
        struct tm *tm_info = localtime(&file_stat.st_mtime);
        if (tm_info == NULL) {
            fprintf(stderr, "Error al convertir la fecha de modificación para '%s'\n", file_name);
            return;
        }
        strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", tm_info);

        fprintf(fp, "Nombre: %s\tTamaño: %ld bytes\tÚltima modificación: %s\n",
                file_name, file_stat.st_size, time_str);
    }
}
