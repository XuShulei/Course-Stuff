#include <stdio.h>
#include <linux/unistd.h>

#define __NR_cp_range 285
#define ARRAY_SIZE 8192

_syscall3(int, cp_range, void *, start_addr, void *, end_addr, int, use_incr_cp);
/* The format is 
 * _syscallN(return type, function name, arg1 type, arg1 name ...)"
 * where "N" is the number of parameters.
 */

#define CP_CHECK(start, end, use_incr_cp)               \
    ret = cp_range (start, end, use_incr_cp);           \
    len = (unsigned long) end - (unsigned long) start;  \
    if (-1 == ret)                      \
        fprintf(stderr, "Failed to perform checkpoint, the buffer may not be in user space\n");         \
    else {                              \
        if (use_incr_cp)                \
            printf("[CP] Took a check point for buffer from addr %x, len %lu; Check file 'incr_cp_%d'\n",     \
                    start, len, ret);                                                                   \
        else                            \
            printf("[CP] Took a check point for buffer from addr %x, len %lu; Check file 'cp_%d'\n",          \
                    start, len, ret);                                                                   \
    }

int main () 
{
    int i;
    char *array;
    int ret, len;
    array = (char *) malloc (sizeof(char) * ARRAY_SIZE);
    
    // Initialize the array
    for (i = 0; i < ARRAY_SIZE; i++)
        array[i] = '1';
    
    // Checkpoint 1 (Need to add filename parameter to the system call)
    CP_CHECK(array, array + ARRAY_SIZE, 0);
    CP_CHECK(array, array + ARRAY_SIZE, 1); // Use incremental design

    // Modifiy data in array
    for (i = 0; i < ARRAY_SIZE; i++)
        array[i] = '2';

    // Checkpoint 2 (Need to add filename parameter to the system call)
    CP_CHECK(array, array + ARRAY_SIZE, 0);
    CP_CHECK(array, array + ARRAY_SIZE, 1); // Use incremental design

    // Modifiy data in the first half of array
    // Array is 3 pages long. First half touhces 2/3 pages. changing to 1/4 length to only hit one
    for (i = ARRAY_SIZE/4; i < ARRAY_SIZE/2 - 1; i++)
        array[i] = '3';

    //array[ARRAY_SIZE - 2] = '3';
    // Checkpoint 3, without modifying the whole array
    CP_CHECK(array, array + ARRAY_SIZE, 0);
    CP_CHECK(array, array + ARRAY_SIZE, 1); // Use incremental design

    // Check full range of addresses
    void *zero = (void *) 0x0, *three_gig = (void *) 0xBFFFFFFF;
    CP_CHECK(zero, three_gig, 0);
    CP_CHECK(zero, three_gig, 1); // Use incremental design

    return 0;
}
