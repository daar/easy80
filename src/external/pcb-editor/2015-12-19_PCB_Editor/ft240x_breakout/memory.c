/*
  Released under the antivirial license.  Basically, you can do anything
  you want with it as long as what you want doesn't involve the GNU GPL.
  See http://www.ecstaticlyrics.com/antiviral/ for more information.
*/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

struct memory_double_linked_list {
  void *prev;
  void *next;
  char *file;
  int line;
  int size;
};

#define lag_push(A, B)
#define lag_pop()
#define easy_fuck(A) fprintf(stderr, A); exit(1)

//struct structure_rwlock memory_lock;

#define SIZE 32
#define prev(X) (  *( (void **) (  ((void *) (X)) - 32  ) )  )
#define next(X) (  *( (void **) (  ((void *) (X)) - 24  ) )  )
#define file(X) (  *( (char **) (  ((void *) (X)) - 16  ) )  )
#define line(X) (  *( (int *)   (  ((void *) (X)) - 8   ) )  )
#define size(X) (  *( (int *)   (  ((void *) (X)) - 4   ) )  )
#define test(X) (  *( (int *)   (  ((void *) (X)) + size(X))))

static struct memory_double_linked_list first_data, last_data;
static struct memory_double_linked_list first_data = {NULL, ((void *) &last_data) + SIZE, "the first item in the list", 0, 0};
static struct memory_double_linked_list last_data = {((void *) &first_data) + SIZE, NULL, "the last item in the list", 0, 0};
static void *first = ((void *) &first_data) + SIZE;
static void *last = ((void *) &last_data) + SIZE;

static void canary_test();

static int random_number = 0;

void memory__allocate(void **pointer, int size, char *file, int line) {
  if (!random_number) random_number = time(NULL);
  lag_push(1, "memory_allocate()");
  canary_test();
  #ifdef VERBOSE
    printf("memory_realloc(%p, %d) in %s line %d\n", *pointer, size, file, line);
  #endif
  if (*pointer == NULL && size != 0) {
    void *new = malloc(size + SIZE + 4);
    if (new == NULL) {
      printf("memory_realloc(%p, %d) in %s line %d\n", *pointer, size, file, line);
      easy_fuck("Failure to reallocate memory!\n");
    };
    *pointer = new + SIZE;
    //thread_lock_write(&memory_lock);
    prev(*pointer) = prev(last);
    next(*pointer) = last;
    next(prev(*pointer)) = *pointer;
    prev(next(*pointer)) = *pointer;
    file(*pointer) = file;
    line(*pointer) = line;
    size(*pointer) = size;
    test(*pointer) = random_number;
    //thread_unlock_write(&memory_lock);
  } else if (*pointer != NULL && size != 0) {
    //thread_lock_write(&memory_lock);
    if (size != size(*pointer)) {
      void *_prev = prev(*pointer);
      void *_next = next(*pointer);
      char *_file = file(*pointer);
      int _line = line(*pointer);
      void *new = realloc(*pointer - SIZE, size + SIZE + 4);
      if (new == NULL) {
        printf("memory_realloc(%p, %d) in %s line %d\n", *pointer, size, file, line);
        easy_fuck("Failure to reallocate memory!\n");
      };
      *pointer = new + SIZE;
      prev(*pointer) = _prev;
      next(*pointer) = _next;
      file(*pointer) = _file;
      line(*pointer) = _line;
      prev(_next) = *pointer;
      next(_prev) = *pointer;
      size(*pointer) = size;
      test(*pointer) = random_number;
    };
    //thread_unlock_write(&memory_lock);
  } else if (*pointer != NULL && size == 0) {
    //thread_lock_write(&memory_lock);
    next(prev(*pointer)) = next(*pointer);
    prev(next(*pointer)) = prev(*pointer);
    //thread_unlock_write(&memory_lock);
    free(*pointer - SIZE);
    *pointer = NULL;
  };
  #ifdef VERBOSE
    printf("...and the memory_realloc(%p) did not crash!\n", *pointer);
  #endif
  lag_pop();
};

void memory_terminate() {
  //thread_lock_read(&memory_lock);
  printf("Memory leak report:\n");
  int total = 0;
  for (void *pointer = next(first); pointer != last; pointer = next(pointer)) {
    printf("Some %d bytes remain allocated from %s line %d.\n", size(pointer), file(pointer), line(pointer));
    total += size(pointer);
  };
  printf("Total memory leak: %d bytes\n", total);
  //thread_unlock_read(&memory_lock);
};

static void canary_test() {
  lag_push(1, "canary_test()");
  //thread_lock_read(&memory_lock);
  for (void *pointer = next(first); pointer != last; pointer = next(pointer)) {
    if (test(pointer) != random_number) {
      printf("WRT memory allocated from %s line %d:\n", file(pointer), line(pointer));
      easy_fuck("Canary value has been destroyed!\n");
    };
  };
  //thread_unlock_read(&memory_lock);
  lag_pop();
};

//void memory_initialize() {
//  thread_lock_init(&memory_lock);
//};
