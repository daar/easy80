/*
  Released under the antivirial license.  Basically, you can do anything
  you want with it as long as what you want doesn't involve the GNU GPL.
  See http://www.ecstaticlyrics.com/antiviral/ for more information.
*/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>
#include <string.h>

#undef memory_allocate
#define memory_allocate(pointer, size) pointer = realloc(pointer, size)

#define easy_fuck(x) fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, (x)), exit(1)

static void sort(double *item, int count) {
  if (count <= 1) return;
  int half_one = count >> 1;
  int half_two = count - half_one;
  sort(item, half_one);
  sort(item + half_one, half_two);
  double *temp = NULL;
  memory_allocate(temp, sizeof(double) * count);
  double *pointer_one = item;
  double *pointer_two = item + half_one;
  for (int i = 0; i < count; i++) {
    if (half_one && half_two) {
      if (*pointer_one < *pointer_two) {
        temp[i] = *pointer_one;
        pointer_one++;
        half_one--;
      } else {
        temp[i] = *pointer_two;
        pointer_two++;
        half_two--;
      };
    } else if (half_one) {
      temp[i] = *pointer_one;
      pointer_one++;
      half_one--;
    } else {
      temp[i] = *pointer_two;
      pointer_two++;
      half_two--;
    };
  };
  memmove(item, temp, sizeof(double) * count);
  memory_allocate(temp, 0);
};
struct structure_lag_stack {
  char *text;
  int limit;
  double credit;
};

struct structure_lag_data {
  char *text;
  int count;
  double *time;
  double limit;
};

#define SIZE 256

static struct structure_lag_stack stack[SIZE];
static int pointer = 0;
static int level = 0;

static struct structure_lag_data *data = NULL;
static int entries = 0;

//static pthread_key_t key;

double easy_time() {
  #ifdef WINDOWS
    return glfwGetTime();
  #else
    // glfwGetTime uses gettimeofday() which is less desriable than
    // CLOCK_MONOTONIC since changing the system time affects
    // gettimeofday() but does not affect CLOCK_MONOTONIC.
    struct timespec bullshit;
    clock_gettime(CLOCK_MONOTONIC, &bullshit);
    return bullshit.tv_sec + bullshit.tv_nsec / 1000000000.0;
  #endif
};

void lag__push(int limit, const char *message) {
//  if (pthread_getspecific(key) == NULL) return;

  double start = easy_time();

  if (pointer == SIZE) easy_fuck("lag stack overflow");

  stack[pointer].text = (char *) message;
  stack[pointer].limit = limit;
  stack[pointer].credit = 0;

  pointer++;

  int i;
  for (i = 0; i < entries; i++) {
    if (data[i].text == message) break;
  };
  if (i >= entries) {
    memory_allocate(data, (++entries * sizeof(struct structure_lag_data)));
    data[i].text = (char *) message;
    data[i].count = 0;
    data[i].time = NULL;
    data[i].limit = limit / 1000.0;
  };
  memory_allocate(data[i].time, sizeof(double) * (data[i].count + 1));
  data[i].time[data[i].count] = -easy_time();

  memory_allocate(data[0].time, sizeof(double) * (data[0].count + 1));
  data[0].time[data[0].count++] = easy_time() - start;
};

void lag__pop() {
//  if (pthread_getspecific(key) == NULL) return;
  double start = easy_time();

  if (pointer == 0) easy_fuck("lag stack underflow");

  pointer--;

  int i;
  for (i = 0; i < entries; i++) {
    if (data[i].text == stack[pointer].text) break;
  };
  if (i >= entries) {
    printf("Item: %s\n", stack[pointer].text);
    easy_fuck("lag_pop() on a non-pushed item");
  };
  data[i].time[data[i].count] += easy_time();
  if (pointer > 0) stack[pointer - 1].credit += data[i].time[data[i].count];
  data[i].time[data[i].count] -= stack[pointer].credit;
  data[i].count++;

  memory_allocate(data[0].time, sizeof(double) * (data[0].count + 1));
  data[0].time[data[0].count++] = easy_time() - start;
};

void lag_initialize() {
  memory_allocate(data, (++entries * sizeof(struct structure_lag_data)));
  data[0].text = "lag_push() & lag_pop()";
  data[0].count = 0;
  data[0].time = NULL;
  data[0].limit = 0.0005;
//  pthread_key_create(&key, NULL);
//  pthread_setspecific(key, (void *) 1);
};

void lag_terminate() {
  if (entries <= 1) return;
  double subtotal[entries];
  double total = 0;
  for (int i = 0; i < entries; i++) {
    subtotal[i] = 0;
    for (int j = 0; j < data[i].count; j++) {
      subtotal[i] += data[i].time[j];
    };
    total += subtotal[i];
  };
  printf("Lag percentiles per function:\n");
  printf("  90%%  50%%  10%%   1%% worst total\n");
  double thresholds[] = {0.1, 0.5, 0.9, 0.99, 1.0};
  for (int c = 0; c < entries; c++) {
    int i;
    double max = -1.0;
    for (int d = 0; d < entries; d++) {
      if (subtotal[d] > max) {
        max = subtotal[d];
        i = d;
      };
    };
    sort(data[i].time, data[i].count);
    for (int j = 0; j < 5; j++) {
      int k = round(data[i].count * thresholds[j]);
      if (k > data[i].count - 1) k = data[i].count - 1;
      if (data[i].time[k] < data[i].limit) {
        printf("%5.0f", 1000 * data[i].time[k]);
      } else {
        printf("\e[1;31m%5.0f\e[0m", 1000 * data[i].time[k]);
      };
    };
    printf("%6.1f%%", 100 * subtotal[i] / total);
    printf("  %s\n", data[i].text);
    subtotal[i] = -1;
  };
};
