/*
  Released under the antivirial license.  Basically, you can do anything
  you want with it as long as what you want doesn't involve the GNU GPL.
  See http://www.ecstaticlyrics.com/antiviral/ for more information.
*/

#include "buffer.h"
#include "memory.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

/*

  buffer_allocate() makes sure there is enough room at the end of a
  buffer for the amount of data you indicate.

  buffer_free() frees any unused space at the beginning of a buffer.

  To read from buffer, just read from buffer.pointer up to buffer.size
  bytes, then either call buffer_free() with the size that you read, or
  you may increment buffer.pointer and decrement buffer.size by the
  amount of data you read, then occasionally call buffer.free with a
  size of zero to free the memory which is no longer needed.

  To write to a buffer, first call buffer_allocate() to make sure that
  there is enough space in the buffer for what you want to write to it,
  then write to the pointer it returns, and increment buffer.size by
  the amount of data you write.  Alternately, if you know exactly how
  many bytes you will write, you may call buffer_write() which will
  return a pointer to which you can write the data, and which also
  updates buffer.size automatically.

  buffer_kill() unallocates all memory in a buffer, so that you may
  delete the buffer structure without leaking memory.

*/

#define PAGE_SIZE 65536

void buffer__init(BUFFER *buffer) {
  memset(&buffer, 0, sizeof(buffer));
};

void buffer__kill(BUFFER *buffer) {
  memory_allocate(buffer->memory_pointer, 0);
  memset(buffer, 0, sizeof(buffer));
};

char *buffer__write(BUFFER *buffer, unsigned int length, char *file, int line) {
  char *pointer = buffer__allocate(buffer, length, file, line);
  buffer->size += length;
  return pointer;
};

char *buffer__allocate(BUFFER *buffer, unsigned int length, char *file, int line) {
//  printf("\e[1;33mbuffer_allocate(%d)\e[0m\n", length);
  unsigned int offset = buffer->pointer - buffer->memory_pointer;
  unsigned int available = buffer->memory_size - buffer->size - offset;
//  printf("buffer->memory_pointer = %p\n", buffer->memory_pointer);
//  printf("   buffer->memory_size = %u\n", buffer->memory_size);
//  printf("       buffer->pointer = %p\n", buffer->pointer);
//  printf("          buffer->size = %u\n", buffer->size);
//  printf("                offset = %u\n", offset);
//  printf("             available = %u\n", available);
  if (length > available) {
    unsigned int needed = length - available;
    unsigned int pages = (needed + PAGE_SIZE - 1) / PAGE_SIZE;
//    printf("                needed = %u\n", needed);
//    printf("                 pages = %u (%u bytes)\n", pages, PAGE_SIZE * pages);
    char *previous_pointer = buffer->memory_pointer;
    memory__allocate((void **) &buffer->memory_pointer, buffer->memory_size + pages * PAGE_SIZE, file, line);
    buffer->pointer += buffer->memory_pointer - previous_pointer;
    buffer->memory_size += pages * PAGE_SIZE;
//    if (buffer->memory_pointer != previous_pointer) {
//      printf("\e[1;32mBuffer has moved to %p\e[0m\n", buffer->memory_pointer);
//    };
  };
  assert(buffer->memory_pointer <= buffer->pointer);
  assert(buffer->pointer <= buffer->memory_pointer + buffer->memory_size);
  assert(buffer->pointer + buffer->size <= buffer->memory_pointer + buffer->memory_size);
  assert(buffer->pointer + buffer->size + length <= buffer->memory_pointer + buffer->memory_size);
  return buffer->pointer + buffer->size;
};

void buffer__free(BUFFER *buffer, unsigned int length, char *file, int line) {
//  printf("\e[1;33mbuffer_free(%d)\e[0m\n", length);
  if (buffer->size < length) {
    fprintf(stderr, "%s: %d: buffer_free(%d), but there are only %d bytes in the buffer.\n", file, line, length, buffer->size);
    exit(1);
  };
  buffer->pointer += length;
  buffer->size -= length;
  unsigned int extra = buffer->pointer - buffer->memory_pointer;
//  printf("buffer->memory_pointer = %p\n", buffer->memory_pointer);
//  printf("   buffer->memory_size = %u\n", buffer->memory_size);
//  printf("       buffer->pointer = %p\n", buffer->pointer);
//  printf("          buffer->size = %u\n", buffer->size);
//  printf("                 extra = %u\n", extra);
  if (extra >= PAGE_SIZE) {
    unsigned int pages = extra / PAGE_SIZE;
    char *offset = buffer->memory_pointer + pages * PAGE_SIZE;
    unsigned int count = (buffer->pointer + buffer->size - offset + PAGE_SIZE - 1) / PAGE_SIZE;
//    printf("          buffer->size = %u\n", buffer->size);
//    printf("                 pages = %u (%u bytes)\n", pages, PAGE_SIZE * pages);
//    printf("                offset = %u\n", (int) (long long) offset);
//    printf("                 count = %u\n", count);
    memmove(buffer->memory_pointer, offset, count * PAGE_SIZE);
    buffer->pointer -= pages * PAGE_SIZE;
    char *previous_pointer = buffer->memory_pointer;
    memory_allocate(buffer->memory_pointer, buffer->memory_size - pages * PAGE_SIZE);
    buffer->memory_size -= pages * PAGE_SIZE;
    buffer->pointer += buffer->memory_pointer - previous_pointer;
//    if (buffer->memory_pointer != previous_pointer) {
//      printf("\e[1;32mBuffer has moved to %p\e[0m\n", buffer->memory_pointer);
//    };
  };
  assert(buffer->memory_pointer <= buffer->pointer);
  assert(buffer->pointer <= buffer->memory_pointer + buffer->memory_size);
  assert(buffer->pointer + buffer->size <= buffer->memory_pointer + buffer->memory_size);
};
