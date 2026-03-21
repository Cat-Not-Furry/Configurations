/* layouts.h */
#ifndef LAYOUTS_H
#define LAYOUTS_H

static const float mfact = 0.5;
static const int nmaster = 1;
static const int resizehints = 1;
static const int lockfullscreen = 1;

static const Layout layouts[] = {
    /* symbol     arrange function */
    { " ", tile },   /* first entry is default */
    { " ", NULL },   /* no layout function means floating behavior */
    { "", monocle },
};

#endif /* LAYOUTS_H */
