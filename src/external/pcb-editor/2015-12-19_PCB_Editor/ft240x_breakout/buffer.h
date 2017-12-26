
struct buffer_data {
  char *memory_pointer;
  unsigned int memory_size;
  char *pointer;
  unsigned int size;
};
typedef struct buffer_data BUFFER;

void buffer__init(BUFFER *);
void buffer__kill(BUFFER *);
char *buffer__write(BUFFER *, unsigned int, char *, int);
char *buffer__allocate(BUFFER *, unsigned int, char *, int);
void buffer__free(BUFFER *, unsigned int, char *, int);

#define buffer_init(pointer) buffer__init(&pointer)
#define buffer_kill(pointer) buffer__kill(&pointer)
#define buffer_write(pointer, size) buffer__write(&pointer, size, __FILE__, __LINE__)
#define buffer_allocate(pointer, size) buffer__allocate(&pointer, size, __FILE__, __LINE__)
#define buffer_free(pointer, size) buffer__free(&pointer, size, __FILE__, __LINE__)
