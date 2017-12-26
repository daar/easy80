/*
  Released under the antivirial license.  Basically, you can do anything
  you want with it as long as what you want doesn't involve the GNU GPL.
  See http://www.ecstaticlyrics.com/antiviral/ for more information.
*/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <time.h>
#include <GL/glfw.h>
#include <GL/glu.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <assert.h>
#include <pthread.h>
#include <complex.h>

#define error_string(x) "no error message available"

#include "stb_image.h"

#include "memory.h"
#include "buffer.h"
#include "common.c"
#include "lag.h"

#define FUCK
//#define FUCK fprintf(stderr, "%s: %d\n", __FILE__, __LINE__);
//#define FUCK if (tracks) assert(track[0].point.size == track[0].points * sizeof(struct point));

#define fuck(x) fprintf(stderr, "%s\n", x), exit(1)

GLint font_texture = 0;

BUFFER data = {};

static double easy_time() {
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

GLuint load_image(char *filename) {
  int width, height;
  char *image = stbi_load(filename, &width, &height, NULL, 4);
  if (image == NULL) {
    fprintf(stderr, "Failed to load %s\n", filename);
    exit(1);
  };
  GLuint texture;
  glGenTextures(1, &texture);
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);
  stbi_image_free(image);
  return texture;
};

void draw_text(complex float location, complex float rotation, char *text) {
  glEnable(GL_TEXTURE_2D);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glBindTexture(GL_TEXTURE_2D, font_texture);
  glBegin(GL_QUADS);
  for (int i = 0; i < strlen(text); i++) {
    int c = text[i];
    if (c < 32 || c > 126) c = 127;
    float cx = (c % 16) / 16.0f;
    float cy = (c / 16) / -8.0f;
//    glTexCoord2d(cx,            cy          );  glVertex2f(x + z * 0.5f * i,        y);
//    glTexCoord2d(cx + 0.0625f,  cy          );  glVertex2f(x + z * 0.5f * (i + 1),  y);
//    glTexCoord2d(cx + 0.0625f,  cy - 0.125f );  glVertex2f(x + z * 0.5f * (i + 1),  y + z);
//    glTexCoord2d(cx,            cy - 0.125f );  glVertex2f(x + z * 0.5f * i,        y + z);
    complex float p1 = (0.5f * (i+0) - 0.5f * I) * rotation + location;
    complex float p2 = (0.5f * (i+1) - 0.5f * I) * rotation + location;
    complex float p3 = (0.5f * (i+1) + 0.5f * I) * rotation + location;
    complex float p4 = (0.5f * (i+0) + 0.5f * I) * rotation + location;
    glTexCoord2d(cx,            cy          );  glVertex2f(crealf(p1), cimagf(p1));
    glTexCoord2d(cx + 0.0625f,  cy          );  glVertex2f(crealf(p2), cimagf(p2));
    glTexCoord2d(cx + 0.0625f,  cy - 0.125f );  glVertex2f(crealf(p3), cimagf(p3));
    glTexCoord2d(cx,            cy - 0.125f );  glVertex2f(crealf(p4), cimagf(p4));
  };
  glEnd();
  glDisable(GL_TEXTURE_2D);
};

int exit_flag = 0;

static int window_width = 0;
static int window_height = 0;

typedef struct scroller {
  double target;
  double current;
  double speed;
  double acceleration;
  double tics;
} SCROLLER;

SCROLLER view_x = {};
SCROLLER view_y = {};
SCROLLER view_z = {};

void smooth_scroll (SCROLLER *x) {
  #define RESOLUTION 1000.0
  double tics = round(RESOLUTION * easy_time());
  if (x->tics == 0) x->tics = tics;
  for (; x->tics < tics; x->tics++) {
    double desired_speed = 0.0;
    double desired_accel = 0.0;
    if (x->target > x->current) {
      desired_speed = +0.99 * sqrt(2.0) * sqrt(x->acceleration) * sqrt(x->target - x->current);
    } else if (x->target < x->current) {
      desired_speed = -0.99 * sqrt(2.0) * sqrt(x->acceleration) * sqrt(x->current - x->target);
    };
    desired_accel = desired_speed - x->speed;
    if (desired_accel > +x->acceleration/RESOLUTION) desired_accel = +x->acceleration/RESOLUTION;
    if (desired_accel < -x->acceleration/RESOLUTION) desired_accel = -x->acceleration/RESOLUTION;
    x->speed += desired_accel;
    x->current += x->speed / RESOLUTION;
  };
};

complex float current_text_rotation = 1.0f;

int draw_track_points = 0;
float interval = 0.020f;
float clearance = 0.035f;
float attraction = 0.100f;
float repulsion = 0.500f;
float speed = 0.001f;
int mode = 0;
int step = 0;
int snap = 0;
int layer = 0;
int polarity = 1;

const float grid_size[] = {0.025, 0.050, 0.100, 0.250, 0.500, 1.000};
const int grid_size_count = sizeof(grid_size) / sizeof(grid_size[0]);
int grid_index = 2; float current_grid_size = 0.100f;

const float pad_size[] = {0.015, 0.035, 0.065, 0.065, 0.150, 0.300};
const int pad_size_count = sizeof(pad_size) / sizeof(pad_size[0]);
int pad_index = 2; float current_pad_size = 0.065f;

const float hole_size[] = {0.000, 0.020, 0.035, 0.045, 0.100, 0.150};
const int hole_size_count = sizeof(hole_size) / sizeof(hole_size[0]);
int hole_index = 2; float current_hole_size = 0.035f;

const float track_size[] = {0.010, 0.015, 0.035, 0.065, 0.085, 0.100};
const int track_size_count = sizeof(track_size) / sizeof(track_size[0]);
int track_index = 2; float current_track_size = 0.065f;

int mouse_int_x, mouse_int_y;
float mouse_x = 0.0f, mouse_y = 0.0f;
complex float mouse = 0.0f;

int edit = -1;
struct text *edit_text = NULL;

static void cancel() {
  // cancel any multi-step operations
  if (mode == 1) step = 0;
  if (mode == 2 && step == 2) {
    for (int p = 0; p < pads; p++) {
      pad[p].floating = 0;
    };
  };
  if (mode == 3 && step == 1) {
    buffer_kill(track[tracks-1].point);
    memory_allocate(track, --tracks * sizeof(struct track));
  };
  step = 0; edit = -1; edit_text = NULL;
};

#define point(a,b) (*(((struct point *) track[a].point.pointer) + b))

const struct meta {
  char extension[4];
  char comment[64];
} meta[8] = {
  {"GBL", "Bottom Copper"},
  {"GTL", "Top Copper"},
  {"GBO", "Bottom Silkscreen"},
  {"GTO", "Top Silkscreen"},
  {"GBS", "Bottom Solder Mask"},
  {"GTS", "Top Solder Mask"},
  {"GML", "Board Outline"},
  {"TXT", "Drill File"},
};


void gerber() {

  FILE *file[8];
  for (int i = 0; i < 8; i++) {
    char pathname[64];
    snprintf(pathname, 64, "gerbers/PCB.%s", meta[i].extension); pathname[63] = 0;
    file[i] = fopen(pathname, "wb");
    if (file[i] == NULL) {
      fprintf(stderr, "Failed to open %s for writing!\n", pathname);
      for (int j = 0; j < i; j++) {
        fclose(file[j]);
      };
      return;
    };
    if (i < 7) {
      fprintf(file[i], "G04 %s*\r\n", meta[i].comment);
      fprintf(file[i], "%%FSLAX23Y23*%%\r\n%%MOIN*%%\r\nG01*\r\n");
    } else {
      fprintf(file[i], "; This is totally an NC drill file!\r\n");
    };
  };

  // Create list of "aperatures" for the Gerber files...

  double trace[64];
  int traces = 10;

  while (1) {
    float smallest = 1000;
    for (int i = 0; i < tracks; i++) {
      if ((traces == 0 || track[i].radius > trace[traces-1]) && track[i].radius >= 0.001 && track[i].radius < smallest) smallest = track[i].radius;
    };
    for (int i = 0; i < pads; i++) {
      if ((traces == 0 || pad[i].pad_radius > trace[traces-1]) && pad[i].pad_radius >= 0.001 && pad[i].pad_radius < smallest) smallest = pad[i].pad_radius;
    };
    if (smallest == 1000) break;
    trace[traces++] = smallest;
    for (int i = 0; i < tracks; i++) {
      if (track[i].radius == smallest) track[i].tool = traces - 1;
    };
    for (int i = 0; i < pads; i++) {
      if (pad[i].pad_radius == smallest) pad[i].pad_tool = traces - 1;
    };
  };

  // Double the sizes, as we need widths rather than radii...

  for (int i = 10; i < traces; i++) {
    trace[i] *= 2.0f;
  };

  // Create the "aperatures" for these trace sizes...

  for (int j = 0; j < 7; j++) {
    for (int i = 10; i < traces; i++) {
      fprintf(file[j], "%%ADD%02dC,%0.3f*%%\r\n", i, trace[i]);
    };
  };

  // Find necessary drill sizes and create tools entries for them...

  double drill[64];
  int drills = 1;

  while (1) {
    float smallest = 1000;
    for (int i = 0; i < pads; i++) {
      if ((drills == 0 || pad[i].hole_radius > drill[drills-1]) && pad[i].hole_radius >= 0.001 && pad[i].hole_radius < smallest) smallest = pad[i].hole_radius;
    };
    if (smallest == 1000) break;
    drill[drills++] = smallest;
    for (int i = 0; i < pads; i++) {
      if (pad[i].hole_radius == smallest) pad[i].hole_tool = drills - 1;
    };
  };

  // Double the sizes, as we need diameters rather than radii...

  for (int i = 1; i < drills; i++) {
    drill[i] *= 2.0f;
  };

  // Create the tool entires for the drill sizes...

  for (int i = 1; i < drills; i++) {
    //fprintf(file[7], "; Size %02d = %0.3f Inches, Plated-Through Hole\r\n", i, drill[i]);
  };
  fprintf(file[7], "M48\r\nINCH\r\n");
  for (int i = 1; i < drills; i++) {
    fprintf(file[7], "T%02dC%0.3f\r\n", i, drill[i]);
  };
  fprintf(file[7], "%%\r\nG90\r\nG05\r\n");


  #define translate(stuff) nearbyint((crealf(stuff.location) + 2.0f) * 1000.0f), nearbyint((cimagf(stuff.location) + 2.0f) * 1000.0f)

  // Board Outline - It's a rather special case...

  fprintf(file[6], "D%02d*\r\n", track[0].tool);
  fprintf(file[6], "X%0.0fY%0.0fD02*\r\n", translate(point(0, track[0].points-1)));
  for (int i = 0; i < track[0].points; i++) {
    fprintf(file[6], "X%0.0fY%0.0fD01*\r\n", translate(point(0, i)));
  };

  // Now lets draw some tracks, and maybe some pads too!

  for (int a = 10; a < traces; a++) {
    for (int f = 0; f < 6; f++) {
      fprintf(file[f], "D%02d*\r\n", a);
    };
    for (int t = 1; t < tracks; t++) {
      if (track[t].tool != a) continue;
      if (track[t].layer < 0 || track[t].layer >= 4) continue;
      if (
        (track[t].start >= 0 && pad[track[t].start].hole_radius < 0.001f) &&
        (track[t].finish >= 0 && pad[track[t].finish].hole_radius < 0.001f) &&
        cabsf(pad[track[t].start].location - pad[track[t].finish].location) < 0.1f
      ) {
        fprintf(file[track[t].layer + 0], "X%0.0fY%0.0fD02*\r\n", translate(point(t, 0)));
        fprintf(file[track[t].layer + 0], "X%0.0fY%0.0fD01*\r\n", translate(point(t, track[t].points-1)));
        if (track[t].layer < 2) {
          fprintf(file[track[t].layer + 4], "X%0.0fY%0.0fD02*\r\n", translate(point(t, 0)));
          fprintf(file[track[t].layer + 4], "X%0.0fY%0.0fD01*\r\n", translate(point(t, track[t].points-1)));
        };
      } else if (
        (track[t].layer < 2 && !track[t].simple) || (track[t].layer >= 2 && track[t].simple)
      ) {
        fprintf(file[track[t].layer + 0], "X%0.0fY%0.0fD02*\r\n", translate(point(t, 0)));
        for (int i = 1; i < track[t].points; i++) {
          fprintf(file[track[t].layer + 0], "X%0.0fY%0.0fD01*\r\n", translate(point(t, i)));
        };
      };
    };
    for (int p = 0; p < pads; p++) {
      if (pad[p].pad_tool != a) continue;
      if (pad[p].hole_radius < 0.001f) continue;
      if (pad[p].layer != -1) continue;
      for (int f = 0; f < 6; f++) {
        if (f == 2 || f == 3) continue;
        fprintf(file[f], "X%0.0fY%0.0fD03*\r\n", translate(pad[p]));
      };
    };
  };

  // Now lets make some holes!

  #undef translate
  #define translate(stuff) nearbyint((crealf(stuff.location) + 2.0f) * 1000.0f) / 1000.0f, nearbyint((cimagf(stuff.location) + 2.0f) * 1000.0f)  / 1000.0f

  for (int a = 1; a < drills; a++) {
    fprintf(file[7], "T%02d\r\n", a);
    for (int p = 0; p < pads; p++) {
      if (pad[p].hole_tool != a) continue;
      if (pad[p].hole_radius < 0.001f) continue;
      if (pad[p].layer != -1) continue;
      fprintf(file[7], "X%0.3fY%0.3f\r\n", translate(pad[p]));
    };
  };

  // Add "end of file" markers and close all of the files...

  for (int i = 0; i < 8; i++) {
    if (i < 7) {
      fprintf(file[i], "M02*\r\n");
    } else {
      fprintf(file[i], "M30\r\n");
    };
    fclose(file[i]);
  };

};

void save() {
  cancel();
  FILE *file;
  file = fopen("save.c", "wb");
  if (file == NULL) return;
  fprintf(file, "polarity = %d;\n", polarity);
  fprintf(file, "view_x.target = %f;\n", view_x.target);
  fprintf(file, "view_y.target = %f;\n", view_y.target);
  fprintf(file, "view_z.target = %f;\n", view_z.target);
  fprintf(file, "interval = %f;\n", interval);
  fprintf(file, "clearance = %f;\n", clearance);
  fprintf(file, "attraction = %f;\n", attraction);
  fprintf(file, "speed = %f;\n", speed);
  fprintf(file, "repulsion = %f;\n", repulsion);
  //fprintf(file, "grid_index = %d;\n", grid_index);
  //fprintf(file, "current_grid_size = %f;\n", current_grid_size);
  fprintf(file, "pad_index = %d;\n", pad_index);
  fprintf(file, "current_pad_size = %f;\n", current_pad_size);
  fprintf(file, "hole_index = %d;\n", hole_index);
  fprintf(file, "current_hole_size = %f;\n", current_hole_size);
  fprintf(file, "track_index = %d;\n", track_index);
  fprintf(file, "current_track_size = %f;\n", current_track_size);
  fprintf(file, "mode = %d;\n", mode);
  fprintf(file, "snap = %d;\n", snap);
  fprintf(file, "layer = %d;\n", layer);
  fprintf(file, "objects = %d;\n", objects);
  fprintf(file, "memory_allocate(object, objects * sizeof(struct object));\n");
  fprintf(file, "memset(object, 0, objects * sizeof(struct object));\n");
  for (int i = 0; i < objects; i++) {
    fprintf(file, "object[%d].location = %f + %f * I;\n", i, creal(object[i].location), cimag(object[i].location));
    fprintf(file, "object[%d].rotation = %f + %f * I;\n", i, creal(object[i].rotation), cimag(object[i].rotation));
    fprintf(file, "object[%d].text.location = %f + %f * I;\n", i, creal(object[i].text.location), cimag(object[i].text.location));
    fprintf(file, "object[%d].text.rotation = %f + %f * I;\n", i, creal(object[i].text.rotation), cimag(object[i].text.rotation));
    int length = strlen(object[i].text.characters);
    fprintf(file, "memory_allocate(object[%d].text.characters, %d);\n", i, length + 1);
    fprintf(file, "strcpy(object[%d].text.characters, \"%s\");\n", i, object[i].text.characters);
  };
  fprintf(file, "tracks = %d;\n", tracks);
  fprintf(file, "memory_allocate(track, tracks * sizeof(struct track));\n");
  fprintf(file, "memset(track, 0, tracks * sizeof(struct track));\n");
  for (int i = 0; i < tracks; i++) {
    fprintf(file, "track[%d].parent = %d;\n", i, track[i].parent);
    fprintf(file, "track[%d].layer = %d;\n", i, track[i].layer);
    fprintf(file, "track[%d].start = %d;\n", i, track[i].start);
    fprintf(file, "track[%d].finish = %d;\n", i, track[i].finish);
    fprintf(file, "track[%d].radius = %f;\n", i, track[i].radius);
    fprintf(file, "track[%d].points = %d;\n", i, track[i].points);
    fprintf(file, "track[%d].simple = %d;\n", i, track[i].simple);
    fprintf(file, "buffer_write(track[%d].point, track[%d].points * sizeof(struct point));\n", i, i);
    fprintf(file, "memset(track[%d].point.pointer, 0, track[%d].point.size);\n", i, i);
    for (int j = 0; j < track[i].points; j++) {
      fprintf(file, "point(%d, %d).location = %f + %f * I;\n", i, j, creal(point(i, j).location), cimag(point(i, j).location));
    };
    //fprintf(file, "track[%d].text.location = %f + %f * I;\n", i, creal(track[i].text.location), cimag(track[i].text.location));
    //fprintf(file, "track[%d].text.rotation = %f + %f * I;\n", i, creal(track[i].text.rotation), cimag(track[i].text.rotation));
    //int length = strlen(track[i].text.characters);
    //fprintf(file, "memory_allocate(track[%d].text.characters, %d);\n", i, length + 1);
    //fprintf(file, "strcpy(track[%d].text.characters, \"%s\");\n", i, track[i].text.characters);
  };
  fprintf(file, "pads = %d;\n", pads);
  fprintf(file, "memory_allocate(pad, pads * sizeof(struct pad));\n");
  fprintf(file, "memset(pad, 0, pads * sizeof(struct pad));\n");
  for (int i = 0; i < pads; i++) {
    fprintf(file, "pad[%d].location = %f + %f * I;\n", i, creal(pad[i].location), cimag(pad[i].location));
    fprintf(file, "pad[%d].rotation = %f + %f * I;\n", i, creal(pad[i].rotation), cimag(pad[i].rotation));
    fprintf(file, "pad[%d].pad_radius = %f;\n", i, pad[i].pad_radius);
    fprintf(file, "pad[%d].hole_radius = %f;\n", i, pad[i].hole_radius);
    fprintf(file, "pad[%d].layer = %d;\n", i, pad[i].layer);
    fprintf(file, "pad[%d].parent = %d;\n", i, pad[i].parent);
    fprintf(file, "pad[%d].text.location = %f + %f * I;\n", i, creal(pad[i].text.location), cimag(pad[i].text.location));
    fprintf(file, "pad[%d].text.rotation = %f + %f * I;\n", i, creal(pad[i].text.rotation), cimag(pad[i].text.rotation));
    int length = strlen(pad[i].text.characters);
    fprintf(file, "memory_allocate(pad[%d].text.characters, %d);\n", i, length + 1);
    fprintf(file, "strcpy(pad[%d].text.characters, \"%s\");\n", i, pad[i].text.characters);
  };
  fclose(file);
};

static void calculate_mouse_position() {
  mouse_x = mouse_int_x - window_width / 2;
  mouse_y = window_height / 2 - mouse_int_y;
  mouse_x *= powf(2.0, view_z.current) / 1000.0f;
  mouse_y *= powf(2.0, view_z.current) / 1000.0f;
  mouse_x -= view_x.current;
  mouse_y -= view_y.current;
  if (snap && mode == 0) {
    mouse_x = nearbyint(mouse_x / current_grid_size) * current_grid_size;
    mouse_y = nearbyint(mouse_y / current_grid_size) * current_grid_size;
  };
  mouse = mouse_x + mouse_y * I;
};

complex float click = 0.0f;

static void left_click() {
  if (mode == 0) {
    memory_allocate(pad, ++pads * sizeof(struct pad));
    memset(&pad[pads-1], 0, sizeof(struct pad));
    pad[pads-1].location = mouse_x + mouse_y * I;
    pad[pads-1].pad_radius = current_pad_size / 2.0f;
    pad[pads-1].hole_radius = current_hole_size / 2.0f;
    if (current_hole_size >= 0.001f) {
      pad[pads-1].layer = -1;
    } else {
      pad[pads-1].layer = layer;
    };
    pad[pads-1].parent = -1;
    pad[pads-1].text.location = 1.5f * pad[pads-1].pad_radius * current_text_rotation;
    pad[pads-1].text.rotation = 3.0f * pad[pads-1].pad_radius * current_text_rotation;
    pad[pads-1].text.characters = NULL;
    memory_allocate(pad[pads-1].text.characters, 1);
    *pad[pads-1].text.characters = 0;
    edit = pads - 1;
    edit_text = &pad[pads-1].text;
  };
  if (mode == 2) {
    static complex float point;
    if (step == 0) {
      click = mouse;
      step = 1;
    } else if (step == 1) {
      float x1, x2, y1, y2, t;
      x1 = crealf(click); y1 = cimagf(click);
      x2 = crealf(mouse); y2 = cimagf(mouse);
      if (x1 > x2) t = x1, x1 = x2, x2 = t;
      if (y1 > y2) t = y1, y1 = y2, y2 = t;
      for (int p = 0; p < pads; p++) {
        if (
          x1 <= crealf(pad[p].location) && crealf(pad[p].location) <= x2 &&
          y1 <= cimagf(pad[p].location) && cimagf(pad[p].location) <= y2
        ) {
          pad[p].floating = 1;
        };
      };
      step = 2;
    } else {
      for (int p = 0; p < pads; p++) {
        pad[p].floating = 0;
      };
      step = 0;
    };
  };
  if (mode == 1) {
    if (step == 0) {
      memory_allocate(track, ++tracks * sizeof(struct track));
      memset(&track[tracks-1], 0, sizeof(struct track));
      track[tracks-1].points = 1;
      buffer_write(track[tracks-1].point, track[tracks-1].points * sizeof(struct point));
      memset(track[tracks-1].point.pointer, 0, track[tracks-1].point.size);
      point(tracks-1, 0).location = mouse;
      track[tracks-1].radius = current_track_size / 2.0f;
      track[tracks-1].start = -1;
      track[tracks-1].finish = -1;
      track[tracks-1].layer = layer;
      track[tracks-1].parent = -1;
      track[tracks-1].simple = 1;
      step = 1;
    };
  };
  if (mode == 3) {
    if (step == 0) {
      int p;
      for (p = 0; p < pads; p++) {
        if (cabsf(mouse - pad[p].location) <= pad[p].pad_radius) break;
      };
      if (p < pads) {
        memory_allocate(track, ++tracks * sizeof(struct track));
        memset(&track[tracks-1], 0, sizeof(struct track));
        track[tracks-1].points = 2;
        buffer_write(track[tracks-1].point, track[tracks-1].points * sizeof(struct point));
        memset(track[tracks-1].point.pointer, 0, track[tracks-1].point.size);
        point(tracks-1, 0).location = pad[p].location;
        point(tracks-1, 1).location = mouse;
        track[tracks-1].radius = current_track_size / 2.0f;
        track[tracks-1].start = p;
        track[tracks-1].finish = -1;
        track[tracks-1].layer = layer;
        track[tracks-1].parent = -1;
        track[tracks-1].simple = 0;
        step = 1;
      };
    } else if (step == 1) {
      int p;
      for (p = 0; p < pads; p++) {
        if (cabsf(mouse - pad[p].location) <= pad[p].pad_radius) break;
      };
      if (p < pads) {
        point(tracks-1, track[tracks-1].points-1).location = pad[p].location;
        track[tracks-1].finish = p;
        step = 0;
      };
    };
  };
};

static void right_click() {
  if (mode == 0) {
    calculate_mouse_position();
    edit = -1; edit_text = NULL;
    for (int i = 0; i < pads; i++) {
      complex float a = pad[i].location;
      if (cabsf(mouse - a) < pad[i].pad_radius + 0.005) {
        edit = i; edit_text = &pad[i].text;
      };
    };
  };
  if (mode == 1) {
    if (step == 0) {
      int closest = -1;
      float distance = 1000.0f;
      for (int t = 0; t < tracks; t++) {
        if (!track[t].simple) continue;
        if (track[t].layer != layer) continue;
        for (int p = 0; p < track[t].points; p++) {
          float d = cabsf(point(t, p).location - mouse);
          if (d < distance) {
            distance = d;
            closest = t;
          };
        };
      };
      if (closest >= 0) {
        int t = closest;
        buffer_kill(track[t].point);
        memmove(&track[t], &track[t+1], (tracks - t - 1) * sizeof(struct track));
        memory_allocate(track, --tracks * sizeof(struct track));
      };
    } else {
      int t = tracks - 1;
      buffer_kill(track[t].point);
      memmove(&track[t], &track[t+1], (tracks - t - 1) * sizeof(struct track));
      memory_allocate(track, --tracks * sizeof(struct track));
      step = 0;
    };
  };
  if (mode == 3) {
    if (step == 0) {
      calculate_mouse_position();
      for (int p = 0; p < pads; p++) {
        if (cabsf(mouse - pad[p].location) < pad[p].pad_radius + 0.005) {
          for (int t = 1; t < tracks; t++) {
            if (track[t].layer == layer && (track[t].start == p || track[t].finish == p)) {
              buffer_kill(track[t].point);
              memmove(&track[t], &track[t+1], (tracks - t - 1) * sizeof(struct track));
              memory_allocate(track, --tracks * sizeof(struct track));
              t--; continue;
            };
          };
        };
      };
    } else {
      cancel();
    };
  };
};

void GLFWCALL character_callback(int character, int action) {
  if (action != GLFW_PRESS) return;
  if (edit_text != NULL && character != '"' && character != '\\') {
    int l = strlen(edit_text->characters);
    memory_allocate(edit_text->characters, l + 2);
    edit_text->characters[l] = character;
    edit_text->characters[l+1] = 0;
  };
};

int pad_float_g = 0;
int pad_float_x = 0;
int pad_float_y = 0;
int pad_float_z = 0;

int faster = 0;

void GLFWCALL key_callback(int key, int action) {

  if (key == GLFW_KEY_LSHIFT) faster = action == GLFW_PRESS ? +1 : 0;

  if (mode == 2 && step == 2) {
    if (key == 'W') pad_float_y += action == GLFW_PRESS ? +1 : -1;
    if (key == 'A') pad_float_x -= action == GLFW_PRESS ? +1 : -1;
    if (key == 'S') pad_float_y -= action == GLFW_PRESS ? +1 : -1;
    if (key == 'D') pad_float_x += action == GLFW_PRESS ? +1 : -1;
    if (key == 'Q') pad_float_z += action == GLFW_PRESS ? +1 : -1;
    if (key == 'E') pad_float_z -= action == GLFW_PRESS ? +1 : -1;
    if (key == 'G' && action == GLFW_PRESS) pad_float_g = 1;
    if (key == 'G' && action != GLFW_PRESS) pad_float_g = 0;
  };

  if (action != GLFW_PRESS) return;

  if (key == GLFW_KEY_ESC) cancel();
  if (key == GLFW_KEY_PAGEUP && view_z.target > -2) view_z.target -= 0.5;
  if (key == GLFW_KEY_PAGEDOWN && view_z.target < +4) view_z.target += 0.5;

  if (snap && mode == 0) {
    if (key == GLFW_KEY_LEFT) view_x.target += current_grid_size;
    if (key == GLFW_KEY_RIGHT) view_x.target -= current_grid_size;
    if (key == GLFW_KEY_UP) view_y.target -= current_grid_size;
    if (key == GLFW_KEY_DOWN) view_y.target += current_grid_size;
  } else {
    if (key == GLFW_KEY_LEFT) view_x.target += 0.25 * window_width * pow(2, view_z.target) / 1000.0f;
    if (key == GLFW_KEY_RIGHT) view_x.target -= 0.25 * window_width * pow(2, view_z.target) / 1000.0f;
    if (key == GLFW_KEY_UP) view_y.target -= 0.25 * window_height * pow(2, view_z.target) / 1000.0f;
    if (key == GLFW_KEY_DOWN) view_y.target += 0.25 * window_height * pow(2, view_z.target) / 1000.0f;
  };

  if (edit >= 0) {
    if (key == GLFW_KEY_ENTER) edit = -1, edit_text = NULL;
    if (key == GLFW_KEY_INSERT) {
      pad[edit].pad_radius = current_pad_size / 2.0f;
      pad[edit].hole_radius = current_hole_size / 2.0f;
    };
  } else {
    if (key == GLFW_KEY_ENTER) left_click();
    if (key == '[' && grid_index < grid_size_count - 1) current_grid_size = grid_size[++grid_index];
    if (key == ']' && grid_index > 0) current_grid_size = grid_size[--grid_index];
    if (mode == 0 && key == '-' && pad_index > 0) current_pad_size = pad_size[--pad_index], current_hole_size = hole_size[--hole_index];
    if (mode == 0 && key == '=' && pad_index < pad_size_count - 1) current_pad_size = pad_size[++pad_index], current_hole_size = hole_size[++hole_index];
    if ((mode == 1 || mode == 3) && key == '-' && track_index > 0) current_track_size = track_size[--track_index];
    if ((mode == 1 || mode == 3) && key == '=' && track_index < track_size_count - 1) current_track_size = track_size[++track_index];
    if (key == '1') layer = 0;
    if (key == '2') layer = 1;
    if (key == '3') layer = 2;
    if (key == '4') layer = 3;
  };

  if (key == '.') draw_track_points = !draw_track_points;

  if (key == GLFW_KEY_F1) cancel(), mode = 0;
  if (key == GLFW_KEY_F2) cancel(), mode = 1;
  if (key == GLFW_KEY_F3) cancel(), mode = 2;
  if (key == GLFW_KEY_F4) cancel(), mode = 3;
  if (key == GLFW_KEY_F5) snap = !snap;
  if (key == GLFW_KEY_F6) save(), gerber();
  if (key == GLFW_KEY_F7 && interval < 0.025f) interval = nearbyint(interval * 1000.0f + 1) / 1000.0f;
  if (key == GLFW_KEY_F8 && interval > 0.005f) interval = nearbyint(interval * 1000.0f - 1) / 1000.0f;
  if (key == GLFW_KEY_F9 && speed > 0.00015) speed -= 0.0001;
  if (key == GLFW_KEY_F10 && speed < 0.00195) speed += 0.0001;
  if (key == GLFW_KEY_F11 && repulsion > 0.0015f) repulsion *= powf(10.0f, -0.25f);
  if (key == GLFW_KEY_F12 && repulsion < 0.900f) repulsion *= powf(10.0f, +0.25f);
  if (key == 'O' && clearance > 0.010f) clearance = nearbyint(clearance * 200.0f - 1) / 200.0f;
  if (key == 'P' && clearance < 0.100f) clearance = nearbyint(clearance * 200.0f + 1) / 200.0f;
  if (repulsion > 0.5f) repulsion = 0.5f;

  if (edit < 0) {

    int shift = 0, x = 0, y = 0;
    if (key == 'I') y += shift = 1;
    if (key == 'J') x -= shift = 1;
    if (key == 'K') y -= shift = 1;
    if (key == 'L') x += shift = 1;
    if (shift) {
      complex float offset = 0.1f * (x + y * I);
      for (int t = 0; t < tracks; t++) {
        for (int p = 0; p < track[t].points; p++) {
          point(t, p).location += offset;
        };
      };
      for (int p = 0; p < pads; p++) {
        pad[p].location += offset;
      };
    };

    #define mirror(x) x = (I * cimagf(x) - crealf(x))

    if (key == 'M') {
      polarity = -polarity;
      cancel();
      for (int t = 0; t < tracks; t++) {
        for (int p = 0; p < track[t].points; p++) {
          mirror(point(t, p).location);
        };
        if (track[t].layer >= 0) track[t].layer ^= 1;
      };
      for (int p = 0; p < pads; p++) {
        mirror(pad[p].location);
        mirror(pad[p].rotation);
        mirror(pad[p].text.location);
        mirror(pad[p].text.rotation);
        if (pad[p].layer >= 0) pad[p].layer ^= 1;
      };
    };

  };

  #define rotate(x) x *= I

  if (key == 'R' && edit_text == NULL) {
    cancel();
    for (int t = 0; t < tracks; t++) {
      for (int p = 0; p < track[t].points; p++) {
        rotate(point(t, p).location);
      };
    };
    for (int p = 0; p < pads; p++) {
      rotate(pad[p].location);
      rotate(pad[p].rotation);
      rotate(pad[p].text.location);
      rotate(pad[p].text.rotation);
    };
  };

  printf("interval = %0.3f, clearance = %0.3f, speed = %0.4f, repulsion = %0.3f\n", interval, clearance, speed, repulsion);

  if (edit >= 0) {
    if (key == GLFW_KEY_BACKSPACE) {
      int l = strlen(pad[edit].text.characters);
      if (l > 0) {
        memory_allocate(pad[edit].text.characters, l);
        pad[edit].text.characters[l-1] = 0;
      };
    };
    if (key == GLFW_KEY_HOME) {
      pad[edit].text.location *= cpowf(M_E, +0.25 * M_PI * I);
      pad[edit].text.rotation *= cpowf(M_E, +0.25 * M_PI * I);
      current_text_rotation *= cpowf(M_E, +0.25 * M_PI * I);
    };
    if (key == GLFW_KEY_END) {
      pad[edit].text.location *= cpowf(M_E, -0.25 * M_PI * I);
      pad[edit].text.rotation *= cpowf(M_E, -0.25 * M_PI * I);
      current_text_rotation *= cpowf(M_E, -0.25 * M_PI * I);
    };
    if (key == GLFW_KEY_DEL) {
      for (int t = 1; t < tracks; t++) {
        if (track[t].start == edit || track[t].finish == edit) {
          buffer_kill(track[t].point);
          memmove(&track[t], &track[t+1], (tracks - t - 1) * sizeof(struct track));
          memory_allocate(track, --tracks * sizeof(struct track));
          t--; continue;
        } else {
          if (track[t].start > edit) track[t].start--;
          if (track[t].finish > edit) track[t].finish--;
        };
      };
      memory_allocate(pad[edit].text.characters, 0);
      memmove(&pad[edit], &pad[edit+1], (pads - edit - 1) * sizeof(struct pad));
      memory_allocate(pad, --pads * sizeof(struct pad));
      edit = -1; edit_text = NULL;
    };
  };

};

void GLFWCALL wheel_callback(int position) {
  static int memory = 0;
  for (; memory < position; memory++) {
    if (view_z.target > -2) view_z.target -= 0.5;
  };
  for (; memory > position; memory--) {
    if (view_z.target < +4) view_z.target += 0.5;
  };
};

double last_time = 0;

void rainbow() {
  float r, g, b;
  float a = 4 * fmod(last_time, 1.0);
  if (a < 1) r = 1, g = a, b = 0;
  else if (a < 2) r = 2 - a, g = 1, b = 0;
  else if (a < 2.5) r = 0, g = 1, b = 2 * (a - 2);
  else if (a < 3.0) r = 0, g = 2 * (3 - a), b = 1;
  else if (a < 3.5) r = 2 * (a - 3), g = 0, b = 1;
  else r = 1, g = 0, b = 2 * (4 - a);
  glColor3f(r, g, b);
};

void GLFWCALL position_callback(int x, int y) {
  mouse_int_x = x;
  mouse_int_y = y;
  if (mode == 1 && step == 1) {
    calculate_mouse_position();
    if (cabsf(point(tracks-1, track[tracks-1].points-1).location - mouse) >= 0.005) {
      buffer_write(track[tracks-1].point, sizeof(struct point));
      point(tracks-1, track[tracks-1].points++).location = mouse;
    };
  };
};

void GLFWCALL button_callback(int button, int action) {
  calculate_mouse_position();
  if (action == GLFW_PRESS) {
    if (button == 0) left_click();
    if (button == 1) right_click();
  } else {
    if (button == 0 && mode == 1 && step == 1) step = 0;
  };
};

int main() {

  lag_initialize();

  lag_push(1000000, "everything else");

  #include "save.c"

  if (tracks == 0) {
    memory_allocate(track, ++tracks * sizeof(struct track));
    memset(&track[tracks-1], 0, sizeof(struct track));
    track[tracks-1].points = 1000;
    buffer_write(track[tracks-1].point, track[tracks-1].points * sizeof(struct point));
    memset(track[tracks-1].point.pointer, 0, track[tracks-1].point.size);
    track[tracks-1].radius = 0.005f;
    track[tracks-1].start = -1;
    track[tracks-1].finish = -1;
    track[tracks-1].layer = -1;
    track[tracks-1].parent = -1;
    track[tracks-1].simple = 0;
    for (int i = 0; i < 1000; i++) {
      point(tracks-1, i).location = 3.0f * cos(2 * M_PI * i / 1000) + 3.0f * sin(2 * M_PI * i / 1000) * I;
    };
  };

  glfwInit();
  glfwOpenWindowHint(GLFW_FSAA_SAMPLES, 16);
  glfwOpenWindow(1024, 768, 8, 8, 8, 8, 0, 0, GLFW_WINDOW);
  glfwSetWindowPos((1920 - 1024) / 2, (1080 - 768) / 2);

  glfwSetKeyCallback(key_callback);
  glfwSetCharCallback(character_callback);
  glfwSetMousePosCallback(position_callback);
  glfwSetMouseButtonCallback(button_callback);
  glfwSetMouseWheelCallback(wheel_callback);

  font_texture = load_image("font.png");

  while (glfwGetWindowParam(GLFW_OPENED) && !exit_flag) {

FUCK

    double this_time = easy_time();
    double fps = 1.0 / (this_time - last_time);
    last_time = this_time;

    //static int frame = 0;
    //if (++frame >= spawn_rate) frame = 0;
    //float fraction = (float) (spawn_rate - frame) / (float) spawn_rate;

    static float fraction = 0.0;
    fraction -= speed;
    if (fraction < 0.0) fraction = interval;

    calculate_mouse_position();

FUCK

    // Update track end points, and if we're drawing a track, move its endpoint to the mouse position.

    lag_push(100, "update track endpoints");

    if (tracks && track[tracks-1].start >= 0 && track[tracks-1].finish < 0) point(tracks-1, track[tracks-1].points-1).location = mouse;
    for (int t = 1; t < tracks; t++) {
      if (track[t].start >= 0) point(t, 0).location = pad[track[t].start].location;
      if (track[t].finish >= 0) point(t, track[t].points-1).location = pad[track[t].finish].location;
    };

    lag_pop();

FUCK

    // reset all force variables to zero, and measure track lengths

    lag_push(100, "reset force variables");

    for (int t = 0; t < tracks; t++) {
      track[t].length = 0.0f;
      for (int p = 0; p < track[t].points; p++) {
        point(t, p).slide = 0.0f;
        point(t, p).attraction = 0.0f;
        point(t, p).repulsion = 0.0f;
        if (p > 0) track[t].length += cabsf(point(t, p).location - point(t, p - 1).location);
      };
    };
    for (int p = 0; p < pads; p++) {
      pad[p].force = 0.0f;
    };

    lag_pop();

FUCK

    // If the distance between the last two track points is too long, add a new point to the end.

    lag_push(100, "add new track points");

    for (int t = 1; t < tracks; t++) {
      if (track[t].simple) continue;
      float distance = cabsf(point(t, track[t].points - 1).location - point(t, track[t].points - 2).location);
      if (distance > interval) {
        buffer_write(track[t].point, sizeof(struct point)); track[t].points++;
        memmove(&point(t, track[t].points - 1), &point(t, track[t].points - 2), sizeof(struct point));
      };
    };

    lag_pop();

FUCK

    // Slowly remove points from the beginning of the track to keep it in motion.

    lag_push(100, "remove old track points");

    for (int t = 1; t < tracks; t++) {
      if (track[t].simple) continue;
      if (track[t].points > 2 && fraction == interval) {
        memmove(&point(t, 1), &point(t, 0), sizeof(struct point));
        buffer_free(track[t].point, sizeof(struct point)); track[t].points--;
      };
    };

    lag_pop();

FUCK

    #define BL_SIZE 160
    #define BL_RESOLUTION 0.05f
    static struct block {
      struct entry {
        complex float location;
        float radius;
        int layer;
        int item;
      } *chain;
      int size;
    } block[BL_SIZE][BL_SIZE] = {};
    static int count[BL_SIZE][BL_SIZE];

    memset(count, 0, sizeof(count));

FUCK

    // Add tracks to block list:

    lag_push(100, "add tracks to block list");

    for (int t = 1; t < tracks; t++) {
      for (int p = 0; p < track[t].points; p++) {
        int lx = floorf((crealf(point(t, p).location) - track[t].radius - clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
        int ux = floorf((crealf(point(t, p).location) + track[t].radius + clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
        int ly = floorf((cimagf(point(t, p).location) - track[t].radius - clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
        int uy = floorf((cimagf(point(t, p).location) + track[t].radius + clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
        for (int x = lx; x <= ux; x++) {
          if (x < 0 || x >= BL_SIZE) continue;
          for (int y = ly; y <= uy; y++) {
            if (y < 0 || y >= BL_SIZE) continue;
            if (block[x][y].size < ++count[x][y]) memory_allocate(block[x][y].chain, (block[x][y].size += 100) * sizeof(struct entry));
            block[x][y].chain[count[x][y]-1].location = point(t, p).location;
            block[x][y].chain[count[x][y]-1].radius = track[t].radius;
            block[x][y].chain[count[x][y]-1].layer = track[t].layer;
            block[x][y].chain[count[x][y]-1].item = t;
          };
        };
      };
    };

    lag_pop();

FUCK

    // Add pads to block list:

    lag_push(100, "add pads to block list");

    for (int p = 0; p < pads; p++) {
      int lx = floorf((crealf(pad[p].location) - pad[p].pad_radius - clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
      int ux = floorf((crealf(pad[p].location) + pad[p].pad_radius + clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
      int ly = floorf((cimagf(pad[p].location) - pad[p].pad_radius - clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
      int uy = floorf((cimagf(pad[p].location) + pad[p].pad_radius + clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
      for (int x = lx; x <= ux; x++) {
        if (x < 0 || x >= BL_SIZE) continue;
        for (int y = ly; y <= uy; y++) {
          if (y < 0 || y >= BL_SIZE) continue;
          if (block[x][y].size < ++count[x][y]) memory_allocate(block[x][y].chain, (block[x][y].size += 100) * sizeof(struct entry));
          block[x][y].chain[count[x][y]-1].location = pad[p].location;
          block[x][y].chain[count[x][y]-1].radius = pad[p].pad_radius;
          block[x][y].chain[count[x][y]-1].layer = pad[p].layer;
          block[x][y].chain[count[x][y]-1].item = p + tracks;
        };
      };
    };

    lag_pop();

FUCK

    // Calculate repulsion forces...

    static struct force {
      complex float force;
      float conflict;
    } *best = NULL;

    //memory_allocate(best, (tracks + pads) * sizeof(struct force));

    lag_push(100, "calculate repulsion forces");

    for (int t = 0; t < tracks; t++) {
      if (track[t].simple) continue;
      if (
        (track[t].start >= 0 && pad[track[t].start].hole_radius < 0.001f) &&
        (track[t].finish >= 0 && pad[track[t].finish].hole_radius < 0.001f) &&
        cabsf(pad[track[t].start].location - pad[track[t].finish].location) < 0.1f
      ) continue;
      for (int p = 0; p < track[t].points; p++) {
        float best_conflict = 0.0f;
        complex float best_force = 0.0f;
        if (t != 0 && (p == 0 || p == track[t].points - 1)) continue;
        //memset(best, 0, (tracks + pads) * sizeof(struct force));
        if (t == 0) track[t].radius = 0.05f;
        int lx = floorf((crealf(point(t, p).location) - track[t].radius - clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
        int ux = floorf((crealf(point(t, p).location) + track[t].radius + clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
        int ly = floorf((cimagf(point(t, p).location) - track[t].radius - clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
        int uy = floorf((cimagf(point(t, p).location) + track[t].radius + clearance / 2.0f) / BL_RESOLUTION) + (BL_SIZE >> 1);
        if (t == 0) track[t].radius = 0.005f;
        for (int y = ly; y <= uy; y++) {
          if (y < 0 || y >= BL_SIZE) continue;
          for (int x = lx; x <= ux; x++) {
            if (x < 0 || x >= BL_SIZE) continue;
            for (int i = 0; i < count[x][y]; i++) {
              if (block[x][y].chain[i].item == t) continue;
              if (block[x][y].chain[i].layer != track[t].layer && block[x][y].chain[i].layer != -1 && track[t].layer != -1) continue;
              if (track[t].start >= 0) {
                if (block[x][y].chain[i].item < tracks) {
                  if (track[block[x][y].chain[i].item].start == track[t].start) continue;
                  if (track[block[x][y].chain[i].item].finish == track[t].start) continue;
                } else {
                  if (block[x][y].chain[i].item == track[t].start + tracks) continue;
                };
              };
              if (track[t].finish >= 0) {
                if (block[x][y].chain[i].item < tracks) {
                  if (track[block[x][y].chain[i].item].start == track[t].finish) continue;
                  if (track[block[x][y].chain[i].item].finish == track[t].finish) continue;
                } else {
                  if (block[x][y].chain[i].item == track[t].finish + tracks) continue;
                };
              };
              //lag_push(1, "part two");
              complex float v = point(t, p).location - block[x][y].chain[i].location;
              float actual = cabsf(v);
              float required = track[t].radius + block[x][y].chain[i].radius + clearance;
              if (t == 0) required = block[x][y].chain[i].radius + 0.05f;
              if (actual < required) {
                float conflict = required - actual;
                if (conflict > best_conflict) {
                  best_conflict = conflict;
                  if (actual < 0.001f) actual = 0.001f;
                  best_force = conflict * v / actual;
                };
              };
              //lag_pop();
            };
          };
        };

        point(t, p).repulsion = best_force;

        //lag_push(1, "part three");
/*
        complex float first = 0.0f;
        complex float second = 0.0f;
        complex float third = 0.0f;
        float first_conflict = 0.0f;
        float second_conflict = 0.0f;
        float third_conflict = 0.0f;
        for (int i = 0; i < tracks + pads; i++) {
          if (first_conflict < best[i].conflict) {
//            third = second; third_conflict = second_conflict;
//            second = first; second_conflict = first_conflict;
            first = best[i].force; first_conflict = best[i].conflict;
//          } else if (second_conflict < best[i].conflict) {
//            third = second; third_conflict = second_conflict;
//            second = best[i].force; second_conflict = best[i].conflict;
//          } else if (third_conflict < best[i].conflict) {
//           third = best[i].force; third_conflict = best[i].conflict;
          };
        };
        point(t, p).repulsion = first;
//        point(t, p).repulsion += second;
//        point(t, p).repulsion += third;
        //lag_pop();
*/
      };
    };

    lag_pop();

FUCK

    // apply slide force to track points

    lag_push(100, "calculate follow forces");

    for (int t = 1; t < tracks; t++) {
      if (track[t].simple) continue;
      float d = cabsf(point(t, 1).location - point(t, 0).location);
      if (d > fraction) {
        complex float f = point(t, 0).location - point(t, 1).location;
        float e = cabsf(f); if (e < 0.001f) e = 0.001f;
        point(t, 1).slide = fabsf(d - fraction) * f / e;
      };
      for (int p = 2; p < track[t].points - 1; p++) {
        float d = cabsf(point(t, p).location - point(t, p - 1).location);
        if (d > interval) {
          complex float f = point(t, p - 1).location - point(t, p).location;
          float e = cabsf(f); if (e < 0.001f) e = 0.001f;
          point(t, p).slide = fabsf(d - interval) * f / e;
        };
      };
    };


    lag_pop();

FUCK

    // apply board outline forces

    lag_push(100, "board outline forces");

    for (int t = 0; t < 1; t++) {
      if (track[t].simple) continue;
      for (int p = 0; p < track[t].points; p++) {
        int q = p + 1; if (q >= track[t].points) q -= track[t].points;
        int o = p + (track[t].points >> 1); if (o >= track[t].points) o -= track[t].points;
        complex float w = point(t, q).location - point(t, p).location;
        float s = powf(cabsf(w) * 100.0f, 2.0f);
        if (s > 10.0f) s = 10.0f;
        point(t, p).attraction = 0.5f * w * s;
        complex float v = point(t, p).attraction / cabsf(point(t, p).attraction);
        point(t, p).attraction += 0.0002f * v * I * polarity;
      };
    };

    lag_pop();

FUCK

    // apply the forces

    lag_push(100, "applying forces");

    for (int t = 0; t < tracks; t++) {
      if (track[t].simple) continue;
      for (int p = 0; p < track[t].points; p++) {
        point(t, p).location += 0.99 * point(t, p).slide;
        point(t, p).location += attraction * point(t, p).attraction;
        if (t != 0) {
          float max = 1.0f * speed;
          if (cabsf(point(t, p).repulsion) > max) {
            point(t, p).repulsion *= max / cabsf(point(t, p).repulsion);
          };
        };
        point(t, p).location += repulsion * point(t, p).repulsion;
      };
    };

    lag_pop();

FUCK

    // apply pad float forces

    lag_push(100, "floating pads");

    if (mode == 2 && step == 2) {
      complex float average = 0.0f;
      complex float a_random_rotation = 0.0f;
      int count = 0;
      for (int p = 0; p < pads; p++) {
        if (pad[p].floating) {
          pad[p].location += 0.0005 * (pad_float_x + pad_float_y * I) * (faster ? 10.0f : 1.0f);
          average += pad[p].location; count++;
          a_random_rotation = pad[p].text.rotation;
        };
      };
      if (count) average /= count;
      if (pad_float_g) {
        float ax = crealf(average);
        float ay = cimagf(average);
        float az = 8.0f * cargf(a_random_rotation) / M_PI;
        float dx = 0.5f * current_grid_size * roundf(ax / (0.5f * current_grid_size)) - ax;
        float dy = 0.5f * current_grid_size * roundf(ay / (0.5f * current_grid_size)) - ay;
        float dz = round(az) - az;
        float angle = 0.1f * M_PI * dz / 16.0f;
        complex float rotation = cos(angle) + sin(angle) * I;
        for (int p = 0; p < pads; p++) {
          if (pad[p].floating) {
            pad[p].location -= average;
            pad[p].location *= rotation;
            pad[p].location += average;
            pad[p].location += 0.1 * (dx + dy * I);
            pad[p].text.location *= rotation;
            pad[p].text.rotation *= rotation;
          };
        };
      };
      if (pad_float_z) {
        float angle = pad_float_z * 0.05f * M_PI / 180.0f * (faster ? 10.0f : 1.0f);
        complex float rotation = cos(angle) + sin(angle) * I;
        for (int p = 0; p < pads; p++) {
          if (pad[p].floating) {
            pad[p].location -= average;
            pad[p].location *= rotation;
            pad[p].location += average;
            pad[p].text.location *= rotation;
            pad[p].text.rotation *= rotation;
          };
        };
      };
    };

    lag_pop();

FUCK

    if (snap && mode == 0) {
      view_x.target = nearbyint(view_x.target / current_grid_size) * current_grid_size;
      view_y.target = nearbyint(view_y.target / current_grid_size) * current_grid_size;
    };

    view_x.acceleration = 4 * pow(2.0, view_z.current);
    view_y.acceleration = 4 * pow(2.0, view_z.current);
    view_z.acceleration = 16;

    smooth_scroll(&view_x);
    smooth_scroll(&view_y);
    smooth_scroll(&view_z);

FUCK

    lag_push(100, "drawing everything");

    glfwGetWindowSize(&window_width, &window_height);
    if (window_width > 0 && window_height > 0) {
      glViewport(0, 0, window_width, window_height);

      glMatrixMode(GL_MODELVIEW); glLoadIdentity();
      glScaled(2.0 / window_width, 2.0 / window_height, 1.0);
      glScaled(pow(2.0, -view_z.current) * 1000.0f, pow(2.0, -view_z.current) * 1000.0f, 1.0);
      glTranslated(view_x.current, view_y.current, 0.0);

      glClearColor(0.1, 0.1, 0.1, 1.0);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      glEnable(GL_BLEND);
      //glHint(GL_POINT_SMOOTH_HINT, GL_FASTEST);
      //glHint(GL_LINE_SMOOTH_HINT, GL_FASTEST);
      //glHint(GL_POLYGON_SMOOTH_HINT, GL_FASTEST);
      //glEnable(GL_POINT_SMOOTH);
      //glEnable(GL_LINE_SMOOTH);
      //glEnable(GL_POLYGON_SMOOTH);

      float width = window_width * powf(2.0, view_z.current) / 1000.0f;
      float height = window_height * powf(2.0, view_z.current) / 1000.0f;
      float top = +window_height / 2.0f * powf(2.0f, view_z.current) / 1000.0f - view_y.current;
      float bottom = -window_height / 2.0f * powf(2.0f, view_z.current) / 1000.0f - view_y.current;
      float right = +window_width / 2.0f * powf(2.0f, view_z.current) / 1000.0f - view_x.current;
      float left = -window_width / 2.0f * powf(2.0f, view_z.current) / 1000.0f - view_x.current;

      //printf("width = %0.3f, height=%0.3f, (%0.3f, %0.3f, %0.3f, %0.3f\n", width, height, left, right, bottom, top);

FUCK

      // draw 10 x 10 cm box

      glColor3f(0.0, 0.0, 0.0);
      glBegin(GL_QUADS);
      //#define EDGE (5.0f / 2.54f)
      #define EDGE (2.5f / 2.54f)
      glVertex2f(-EDGE, -EDGE);
      glVertex2f(+EDGE, -EDGE);
      glVertex2f(+EDGE, +EDGE);
      glVertex2f(-EDGE, +EDGE);
      glEnd();

FUCK

      // draw grid

      glColor3f(0.25, 0.50, 0.75);
      glPointSize(M_PI / pow(2.0, view_z.current));
      glBegin(GL_POINTS);
      for (float y = floor(bottom / current_grid_size) * current_grid_size; y <= ceil(top / current_grid_size) * current_grid_size; y += current_grid_size) {
        for (float x = floor(left / current_grid_size) * current_grid_size; x <= ceil(right / current_grid_size) * current_grid_size; x += current_grid_size) {
          glPointSize(3.0f / pow(2.0, view_z.current));
          glVertex2f(x, y);
        };
      };
      glEnd();

FUCK

      // draw tracks

      lag_push(100, "drawing tracks and pads");

      #define SMOOTH 36
      complex float angle_table[SMOOTH+1];
      for (int i = 0; i <= SMOOTH; i++) {
        angle_table[i] = cpowf(M_E, 2.0f * M_PI * I * i / (float) SMOOTH);
      };

      for (int l = 0; l < 5; l++) {
        for (int t = 0; t < tracks; t++) {
          if (l == 0 && track[t].layer != -1) continue;
          if (l == 1 && track[t].layer != 2) continue;
          if (l == 2 && track[t].layer != 0) continue;
          if (l == 3 && track[t].layer != 1) continue;
          if (l == 4 && track[t].layer != 3) continue;
          if ((mode == 1 || mode == 3) && edit == t) {
            rainbow();
          } else {
            if (track[t].layer == -1) glColor4f(0.0, 0.5, 1.0, 1.0);
            if (track[t].layer == 0) glColor4f(1.0, 0.0, 0.0, 1.0);
            if (track[t].layer == 1) glColor4f(0.0, 1.0, 0.0, 0.5);
            if (track[t].layer == 2) glColor4f(0.2, 0.2, 0.2, 1.0);
            if (track[t].layer == 3) {
              if (layer == 3) {
                glColor4f(1.0, 1.0, 1.0, 1.0);
              } else {
                glColor4f(1.0, 1.0, 1.0, 0.5);
              };
            };
          };
          glBegin(GL_TRIANGLE_STRIP);
          for (int p = 0; p < track[t].points; p++) {
            complex float a, b, c;
            if (p > 0) {
              a = point(t, p - 1).location;
            } else {
              a = point(t, p).location;
            };
            if (p < track[t].points - 1) {
              b = point(t, p + 1).location;
            } else {
              b = point(t, p).location;
            };
            c = b - a;
            c /= cabsf(c);
            c *= track[t].radius * I;
            a = point(t, p).location + c;
            b = point(t, p).location - c;
            glVertex2f(crealf(a), cimagf(a));
            glVertex2f(crealf(b), cimagf(b));
          };
          glEnd();
          for (int p = 0;;) {
            glBegin(GL_TRIANGLE_FAN);
            float complex c = point(t, p).location;
            glVertex2f(crealf(c), cimagf(c));
            for (int i = 0; i <= SMOOTH; i++) {
              float complex a = angle_table[i];
              float complex b = a * track[t].radius + c;
              glVertex2f(crealf(b), cimagf(b));
            };
            glEnd();
            if (p != track[t].points - 1) {
              p = track[t].points - 1;
            } else {
              break;
            }
          };
          if (draw_track_points) {
            // draw individual track points for debugging
            glPointSize(3.0);
            glColor3f(1.0, 1.0, 1.0);
            glBegin(GL_POINTS);
            for (int p = 0; p < track[t].points; p++) {
              float complex c = point(t, p).location;
              glVertex2f(crealf(c), cimagf(c));
            };
            glEnd();
          };
        };

        // draw pads

        for (int p = 0; p < pads; p++) {
          if (l == 0 && pad[p].layer != 2) continue;
          if (l == 1 && pad[p].layer != 0) continue;
          if (l == 2 && pad[p].layer != 1) continue;
          if (l == 3 && pad[p].layer != 3) continue;
          if (l == 4 && pad[p].layer != -1) continue;
          if (1) {
            glColor3f(0.5, 0.5, 0.5);
            glBegin(GL_LINE_LOOP);
            float complex c = pad[p].location;
            float d = pad[p].pad_radius + 0.01f;
            if (d < 0.0025f) d = 0.0025f;
            //glVertex2f(crealf(c), cimagf(c));
            for (int i = 0; i <= SMOOTH; i++) {
              float complex a = angle_table[i];
              float complex b = a * d + pad[p].location;
              glVertex2f(crealf(b), cimagf(b));
            };
            glEnd();
          };
          if (mode == 0 && edit == p) {
            rainbow();
          } else if (pad[p].layer == 0) {
            glColor3f(1.0, 0.0, 0.0);
          } else if (pad[p].layer == 1) {
            glColor3f(0.0, 1.0, 0.0);
          } else if (pad[p].layer == 2) {
            glColor3f(1.0, 1.0, 1.0);
          } else if (pad[p].layer == 3) {
            glColor3f(0.5, 0.5, 0.5);
          } else {
            glColor3f(1.0, 1.0, 0.0);
          };
          glBegin(GL_TRIANGLE_STRIP);
          for (int i = 0; i <= SMOOTH; i++) {
            float complex a = angle_table[i];
            float complex b = a * pad[p].pad_radius + pad[p].location;
            float complex c = a * pad[p].hole_radius + pad[p].location;
            glVertex2f(crealf(b), cimagf(b));
            glVertex2f(crealf(c), cimagf(c));
          };
          glEnd();
          glColor3f(0.0, 0.0, 0.0);
          glBegin(GL_TRIANGLE_FAN);
          float complex c = pad[p].location;
          float d = pad[p].hole_radius;
          if (d < 0.0025f) d = 0.0025f;
          glVertex2f(crealf(c), cimagf(c));
          for (int i = 0; i <= SMOOTH; i++) {
            float complex a = angle_table[i];
            float complex b = a * d + pad[p].location;
            glVertex2f(crealf(b), cimagf(b));
          };
          glEnd();
          if (layer == 2 || layer == 3) continue;
          glColor3f(1.0, 1.0, 1.0);
          float complex a = pad[p].text.location;
          float complex b = pad[p].text.rotation;
          a += pad[p].location;
          draw_text(a, b, pad[p].text.characters);
        };
      };

      lag_pop();

FUCK

      // draw selection box

      if (mode == 2 && step == 1) {
        glColor3f(1.0, 1.0, 1.0);
        glBegin(GL_LINE_LOOP);
        glVertex2f(mouse_x, mouse_y);
        glVertex2f(crealf(click), mouse_y);
        glVertex2f(crealf(click), cimagf(click));
        glVertex2f(mouse_x, cimagf(click));
        glEnd();
      };

FUCK

      // draw mouse cursor

      if (snap && mode == 0) {
        glColor3f(1.0, 1.0, 1.0);
        glLineWidth(2.0);
        glBegin(GL_LINES);
        float size = 0.010 * powf(2.0, view_z.current);
        glVertex2f(mouse_x-size, mouse_y);
        glVertex2f(mouse_x+size, mouse_y);
        glVertex2f(mouse_x, mouse_y-size);
        glVertex2f(mouse_x, mouse_y+size);
        glEnd();
      };

FUCK

      //size = 0.016 * powf(2.0, view_z.current);
      glMatrixMode(GL_MODELVIEW); glLoadIdentity();
      glTranslated(-1.0, -1.0, 0.0);
      glScaled(2.0 / window_width, 2.0 / window_height, 1.0);

      char status[1000];
      int line = 0;
      sprintf(status, "grid size: %0.0f %s", 1000.0f * current_grid_size, "mills");
      glColor3f(1.0, 1.0, 1.0);
      draw_text(2 + (window_height - 8 - 16 * line) * I, 16, status); line++;
      sprintf(status, "current layer: "); draw_text(2 + (window_height - 8 - 16 * line) * I, 16, status);
      if (layer == 0) {
        glColor3f(1.0, 0.0, 0.0);
        draw_text(122 + (window_height - 8 - 16 * line) * I, 16, "bottom"); line++;
      } else if (layer == 1) {
        glColor3f(0.0, 1.0, 0.0);
        draw_text(122 + (window_height - 8 - 16 * line) * I, 16, "top"); line++;
      } else if (layer == 2) {
        glColor3f(0.2, 0.2, 0.2);
        draw_text(122 + (window_height - 8 - 16 * line) * I, 16, "silkscreen"); line++;
      } else if (layer == 3) {
        glColor3f(1.0, 1.0, 1.0);
        draw_text(122 + (window_height - 8 - 16 * line) * I, 16, "silkscreen"); line++;
      };
      glColor3f(1.0, 1.0, 1.0);
      if (mode == 0) {
        sprintf(status, "pad size: %0.0f %s", 1000.0f * current_pad_size, "mills");
        draw_text(2 + (window_height - 8 - 16 * line) * I, 16, status); line++;
        sprintf(status, "hole size: %0.0f %s", 1000.0f * current_hole_size, "mills");
        draw_text(2 + (window_height - 8 - 16 * line) * I, 16, status); line++;
      } else if (mode == 1 || mode == 3) {
        sprintf(status, "track width: %0.0f %s", 1000.0f * current_track_size, "mills");
        draw_text(2 + (window_height - 8 - 16 * line) * I, 16, status); line++;
      };
      line = 0;
      static float fps_average = 0.0f;
      fps_average = 0.95 * fps_average + 0.05 * fps;
      sprintf(status, "FPS: %0.0f", fps_average);
      draw_text(window_width - 2 - 8 * strlen(status) + (window_height - 8 - 16 * line) * I, 16, status); line++;

FUCK

      glfwSwapBuffers();

FUCK

    };

    lag_pop();

  };

  glfwCloseWindow();

  lag_pop();

  lag_terminate();

//  memory_terminate();

};
