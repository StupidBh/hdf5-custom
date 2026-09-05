#include "hdf5.h"

#include <stdio.h>

int main(void)
{
    unsigned major = 0;
    unsigned minor = 0;
    unsigned release = 0;

    if (H5get_libversion(&major, &minor, &release) < 0) {
        return 1;
    }

    printf("HDF5 %u.%u.%u\n", major, minor, release);
    return major == H5_VERS_MAJOR ? 0 : 2;
}
