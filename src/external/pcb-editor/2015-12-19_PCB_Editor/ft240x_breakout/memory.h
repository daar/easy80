
#define memory_allocate(pointer, size) memory__allocate((void **) &(pointer), size, __FILE__, __LINE__)

void memory__allocate(void **, int, char *, int);
void memory_terminate();
