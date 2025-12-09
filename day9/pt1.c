#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct { long x, y; } Tile;

int read_input(char* input, int n) {
    int current_pos = 0;
    char current_char;
    do {
        if (current_pos >= n) return 0;
        current_char = fgetc(stdin);

        input[current_pos] = current_char;
        current_pos++;
    } while (current_char != EOF);
    input[current_pos--] = '\0';  // null terminate
    return current_pos;
}

int parse_delim(char* input, char delim, long* n) {
    int i;
    for (i = 0; input[i] != delim; i++);
    input[i] = '\0';
    char *tmp;
    *n = strtol(input, &tmp, 10);

    if (*tmp != '\0') return 0;
    return i;
}

// destroys input
int parse_tiles(char* input, int input_size, Tile* tiles, int n) {
    size_t current_pos = 0;
    int input_pos = 0;
    while (input_pos < input_size) {
        if (current_pos >= n) return 0;

        long n1;
        int i = parse_delim(input + input_pos, ',', &n1);
        input_pos += i + 1;

        long n2;
        i = parse_delim(input + input_pos, '\n', &n2);
        input_pos += i + 1;

        Tile tile = { .x = n1, .y = n2 };
        tiles[current_pos] = tile;
        current_pos++;
    }
    return current_pos;
}

long absl(long n) {
    if (n < 0) return -n;
    return n;
}

long find_max_area(Tile* tiles, int n) {
    long max_area = 0;
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            long area = (absl(tiles[i].x - tiles[j].x) + 1) *
                        (absl(tiles[i].y - tiles[j].y) + 1);
            if (area > max_area) {
                max_area = area;
            }
        }
    }
    return max_area;
}

int main(int argc, char** argv) {
    int input_capacity = 10420;
    char input[input_capacity];
    int input_size = read_input(input, input_capacity);
    if (!input_size) {
        printf("input overflow\n");
        return 1;
    }
    int tiles_capacity = 1000;
    Tile tiles[tiles_capacity];
    int tiles_size = parse_tiles(input, input_size, tiles, tiles_capacity);
    if (!tiles_size) {
        printf("tiles overflow\n");
        return 1;
    }
    long max_area = find_max_area(tiles, tiles_size);
    printf("max area %ld\n", max_area);
    return 0;
}
