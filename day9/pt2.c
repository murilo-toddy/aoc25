#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

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

void fill_min_max(long v1, long v2, long* min, long* max) {
    if (v1 < v2) {
        *min = v1; *max = v2;
    } else {
        *min = v2; *max = v1;
    }
}

// assumes start and end are valid
bool is_valid_conn(Tile* tiles, int tiles_size, int start, int end) {
    Tile t1 = tiles[start], t2 = tiles[end];
    long min_x, max_x;
    long min_y, max_y;
    fill_min_max(t1.x, t2.x, &min_x, &max_x);
    fill_min_max(t1.y, t2.y, &min_y, &max_y);

    if (min_x == max_x || min_y == max_y) return true;

    bool left_lower_hit = false, right_lower_hit = false;
    bool left_upper_hit = false, right_upper_hit = false;
    for (int i = 0; i < tiles_size; i++) {
        Tile p1 = tiles[i];

        // 1. must hit all 4 extremes
        if (p1.x <= min_x && p1.y >= max_y)      left_lower_hit  = true;
        else if (p1.x >= max_x && p1.y <= min_y) right_lower_hit = true;
        else if (p1.x >= max_x && p1.y >= max_y) left_upper_hit  = true;
        else if (p1.x <= min_x && p1.y <= min_y) right_upper_hit = true;

        // 2. must have no points inside the rectangle
        // note: they may if they come straight back, but it's not covered in
        // the problem input
        //
        // # X X X X X o
        // X           X
        // # X X #     X
        // # X X #     X
        // X           X
        // o X X X X X #
        // is a valid rectangle though it would fail here.
        if (min_x < p1.x && p1.x < max_x && min_y < p1.y && p1.y < max_y) {
            return false;
        }

        // 3. no lines must cut though the rectange's edges
        // same as previous comment.
        Tile p2 = tiles[(i+1) % tiles_size];
        long l_min_x, l_max_x;
        long l_min_y, l_max_y;
        fill_min_max(p1.x, p2.x, &l_min_x, &l_max_x);
        fill_min_max(p1.y, p2.y, &l_min_y, &l_max_y);
        if (l_min_x == l_max_x && l_min_x > min_x && l_min_x < max_x) {
            if (l_min_y <= min_y && l_max_y > min_y ||
                    l_min_y < max_y && l_max_y >= max_y) {
                return false;
            }
        }
        if (l_min_y == l_max_y && l_min_y > min_y && l_min_y < max_y) {
            if (l_min_x <= min_x && l_max_x > min_x ||
                    l_min_x < max_x && l_max_x >= max_x) {
                return false;
            }
        }
    }
    return left_lower_hit && right_lower_hit && left_upper_hit && right_upper_hit;
}

long find_max_area(Tile* tiles, int tiles_size) {
    long max_area = 0;
    for (int i = 0; i < tiles_size; i++) {
        for (int j = i + 1; j < tiles_size; j++) {
            long t1x = tiles[i].x, t1y = tiles[i].y;
            long t2x = tiles[j].x, t2y = tiles[j].y;
            if (!is_valid_conn(tiles, tiles_size, i, j)) continue;

            long area = (absl(t1x - t2x) + 1) * (absl(t1y - t2y) + 1);
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

    printf("max area: %ld\n", find_max_area(tiles, tiles_size));
    return 0;
}
