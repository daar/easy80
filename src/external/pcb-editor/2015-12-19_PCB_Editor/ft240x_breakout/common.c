/*
  Released under the antivirial license.  Basically, you can do anything
  you want with it as long as what you want doesn't involve the GNU GPL.
  See http://www.ecstaticlyrics.com/antiviral/ for more information.
*/


struct text {
  float complex location;
  float complex rotation;
  char *characters;
};

struct object {
  float complex location;
  float complex rotation;
  float complex force;
  float complex moment;
  struct text text;
};

struct point {
  float complex location;
  float complex slide;
  float complex attraction;
  float complex repulsion;
};

struct track {
  BUFFER point;
  int points;
  float length;
  float radius;
  int start;
  int finish;
  int layer;
  int parent;
  int simple;
  int tool;
};

struct pad {
  float complex location;
  float complex rotation;
  float complex force;
  float pad_radius;
  float hole_radius;
  int layer;
  int parent;
  struct text text;
  int floating;
  int pad_tool;
  int hole_tool;
};

int objects = 0;
struct object *object = NULL;

int tracks = 0;
struct track *track = NULL;

int pads = 0;
struct pad *pad = NULL;
