
#ifdef LAG_TEST

void lag_initialize();
void lag_terminate();

#define lag_push(x, y) lag__push(x, y)
#define lag_pop() lag__pop()

void lag__push(int limit, const char *message);
void lag__pop();

#else

#define lag_initialize()
#define lag_terminate()
#define lag_push(x, y)
#define lag_pop()

#endif
