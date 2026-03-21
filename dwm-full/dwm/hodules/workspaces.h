/* workspaces.h */
#ifndef WORKSPACES_H
#define WORKSPACES_H

static const char *tags[] = {" ", "", "", "", "", "", ""};

static const Rule rules[] = {
    /* class      instance    title       tags mask     isfloating   monitor */
    {"Gimp", NULL, NULL, 0, 1, -1},
    {"Firefox", NULL, NULL, 1 << 8, 0, -1},
};

#endif /* WORKSPACES_H */
