#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t* state, unsigned int snum);
static char next_square(game_state_t* state, unsigned int snum);
static void update_tail(game_state_t* state, unsigned int snum);
static void update_head(game_state_t* state, unsigned int snum);

/* Task 1 */
game_state_t* create_default_state() {
  // TODO: Implement this function.
  game_state_t* state = malloc(sizeof(game_state_t));
  // initialize the empty board
  state->num_rows = 18;
  char upper_row[] = "####################\n";
  char inner_row[] = "#                  #\n";
  char** board = malloc(sizeof(char*) * state->num_rows);
  state->board = board;
  for (int i = 0; i < state->num_rows; i++) {
    board[i] = malloc(sizeof(char) * 22);
    if (i == 0 || i == state->num_rows - 1) {
      strcpy(board[i], upper_row);
    } else {
      strcpy(board[i], inner_row);
    }
  }
  // initialize the snake on the board
  state->num_snakes = 1;
  state->snakes = malloc(sizeof(snake_t) * state->num_snakes);
  snake_t* snake = state->snakes;
  snake->head_col = 4;
  snake->head_row = 2;
  snake->tail_col = 2;
  snake->tail_row = 2;
  snake->live = true;
  board[snake->tail_row][snake->tail_col] = 'd';
  board[snake->tail_row][snake->tail_col + 1] = '>';
  board[snake->head_row][snake->head_col] = 'D';
  // initialize the fruit on the board;
  board[2][9] = '*';
  return state;
}

/* Task 2 */
void free_state(game_state_t* state) {
  // TODO: Implement this function.
  for (int i = 0; i < state->num_rows; i++) {
    free(state->board[i]);
  }
  free(state->board);
  free(state->snakes);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  // TODO: Implement this function.
  for (int i = 0; i < state->num_rows; i++) {
    fprintf(fp, "%s", state->board[i]);
  }
  return;
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t* state, unsigned int row, unsigned int col) {
  return state->board[row][col];
}

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  return (c == 'w' || c == 'a' ||
          c == 's' || c == 'd');
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  return (c == 'W' || c == 'A' ||
          c == 'S' || c == 'D' || c == 'x');
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  return (is_head(c) || is_tail(c) || 
          c == '^' || c == '<' || c == 'v' || c == '>');
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  switch(c) {
    case '^' : return 'w';
    case '<' : return 'a';
    case 'v' : return 's';
    case '>' : return 'd';
  }
  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
    switch(c) {
    case 'W' : return '^';
    case 'A' : return '<';
    case 'S' : return 'v';
    case 'D' : return '>';
  }
  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  if (c == 'v' || c == 's' || c == 'S') {
    return cur_row + 1;
  } else if (c == '^' || c == 'w' || c == 'W') {
    return cur_row - 1;
  }
  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  if (c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  } else if (c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  }
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t snake = state->snakes[snum];
  char c = get_board_at(state, snake.head_row, snake.head_col);
  unsigned int next_row = get_next_row(snake.head_row, c);
  unsigned int next_col = get_next_col(snake.head_col, c);
  return get_board_at(state, next_row, next_col);
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t* snake = state->snakes + snum;
  char c = get_board_at(state, snake->head_row, snake->head_col);
  set_board_at(state, snake->head_row, snake->head_col, head_to_body(c));
  snake->head_row = get_next_row(snake->head_row, c);
  snake->head_col = get_next_col(snake->head_col, c);
  set_board_at(state, snake->head_row, snake->head_col, c);
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t* snake = state->snakes + snum;
  char c = get_board_at(state, snake->tail_row, snake->tail_col);
  set_board_at(state, snake->tail_row, snake->tail_col, ' ');
  snake->tail_row = get_next_row(snake->tail_row, c);
  snake->tail_col = get_next_col(snake->tail_col, c);
  c = get_board_at(state, snake->tail_row, snake->tail_col);
  set_board_at(state, snake->tail_row, snake->tail_col, body_to_tail(c));
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  // TODO: Implement this function.
  for (unsigned int i = 0; i < state->num_snakes; i++) {
    char c = next_square(state, i);
    if (c == ' ') {
      update_head(state, i);
      update_tail(state, i);
    } else if (c == '*') {
      update_head(state, i);
      add_food(state);
    } else {
      snake_t* snake = state->snakes + i;
      snake->live = false;
      set_board_at(state, snake->head_row, snake->head_col, 'x');
    }
  }
}

/* Task 5 */
game_state_t* load_board(FILE* fp) {
  // TODO: Implement this function.
  unsigned int num_rows = 32;
  char** board = malloc(sizeof(char*) * num_rows);

  char line[1000000];
  unsigned int num_lines = 0;
  while (fgets(line, sizeof(line), fp) != NULL) {
    size_t len = strlen(line) + 1;
    board[num_lines] = malloc(sizeof(char) * len);
    strcpy(board[num_lines++], line);
    if (num_lines >= num_rows) {
      num_rows *= 2;
      board = realloc(board, sizeof(char*) * num_rows);
    }
  }

  // malloc the state object in the end
  game_state_t* state = malloc(sizeof(game_state_t));
  state->num_rows = num_lines;
  state->board = realloc(board, sizeof(char*) * state->num_rows);
  //printf("number of rows %d allocated board size %d actual size is %d\n", state->num_rows, sizeof(char*) * (state->num_rows), sizeof(state->board));
  state->num_snakes = 0;
  state->snakes = NULL;
  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t* snake = state->snakes + snum;
  unsigned int curr_row = snake->tail_row;
  unsigned int curr_col = snake->tail_col;
  char c = get_board_at(state, curr_row, curr_col);
  while (!is_head(c)) {
    curr_row = get_next_row(curr_row, c);
    curr_col = get_next_col(curr_col, c);
    c = get_board_at(state, curr_row, curr_col);
  }
  snake->head_row = curr_row;
  snake->head_col = curr_col;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
  // TODO: Implement this function.
  state->num_snakes = 0;
  for (unsigned int i = 0; i < state->num_rows; i++) {
    char c;
    unsigned int j = 0;
    while (c = get_board_at(state, i, j)) {
      if (is_tail(c)) {
        size_t size = sizeof(snake_t) * ++(state->num_snakes);
        state->snakes = realloc(state->snakes, size);
        state->snakes[state->num_snakes - 1].tail_row = i;
        state->snakes[state->num_snakes - 1].tail_col = j;
        state->snakes[state->num_snakes - 1].live = true;
        find_head(state, state->num_snakes - 1);
      }
      j++;
    }
  }
  return state;
}
