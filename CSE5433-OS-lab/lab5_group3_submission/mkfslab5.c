#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <linux/types.h>
#include <asm/types.h>
#include <fcntl.h>
#include <linux/kernel.h>
#include <stdint.h>
#include "/root/lab5/linux-2.6.9-lab5/include/linux/lab5fs.h"
//#include "mkfslab5.h"

/*
	Structure of Filesystem based on a single Block Group of EXT2 per lab requirements
	Block 0 - Super Block
	Block 1 - Data Block Bitmap
	Block 2 - inode Bitmap
	Block 3:10 - inode table // to store 2048 inodes, we need 8 blocks of inodes 
	Block 10:N - Data Blocks
*/


/* Write the initial super block to the image */
int write_superblock(int filp) {
        /* Root dir will consum one inode and data block */
	struct lab5fs_sb sb = {
		.s_inodes_count = 1,
		.s_blocks_count = 1,
		.s_free_blocks_count = LAB5FS_MAX_NUM_DATA_BLOCK-1,
		.s_free_inodes_count = LAB5FS_MAX_NUM_INODES-1,
		.s_first_data_block = LAB5FS_FIRST_DATA_BLOCK,
		.s_last_data_block = LAB5FS_MAX_NUM_BLOCKS-1,
		.s_block_size = LAB5FS_BLOCK_SIZE,
		.s_magic = LAB5FS_MAGIC_NUMBER
	};

        /* skip unused sector(s) */
        int ret = lseek(filp, LAB5FS_BLOCK_SIZE * LAB5FS_SUPER_BLOCK_NUM, SEEK_SET);
        if (ret == -1 || ret != LAB5FS_BLOCK_SIZE) {
                fprintf(stderr,
                        "failed seeking into position %lu\n", LAB5FS_BLOCK_SIZE);
                return 0;
        }

	ret = write(filp, &sb, sizeof(sb));
	
	if (ret != sizeof(sb)) {
		printf("Error writing superblock to image\n");
		return -1;
	}
        printf("first data block num is %d\n", LAB5FS_FIRST_DATA_BLOCK);
	printf("Successfully wrote superblock to image.[%d]\n", ret);
	return 0;
}

/* Write the inode bitmap to the image */
int write_inode_bitmap(int filp) {
	struct lab5fs_inode_bitmap empty_bitmap = {0};
	empty_bitmap.index[0] = 1;
	//empty_bitmap.index[1] = 1;
	int ret = write(filp, &empty_bitmap, sizeof(empty_bitmap));

	if (ret != sizeof(empty_bitmap)) {
		printf("Error writing inode bitmap to file.\n");
		return -1;
	}

	printf("Successfully wrote inode bitmap to image.[%d]\n", ret);
	return 0;
}

int write_data_block_bitmap(int filp) {
	struct lab5fs_data_block_bitmap empty_bitmap = {0};
	empty_bitmap.index[0] = 1;
	//empty_bitmap.index[1] = 1;
        int ret	= write(filp, &empty_bitmap, sizeof(empty_bitmap));

        if (ret != sizeof(empty_bitmap)) {
                printf("Error writing data block bitmap to file.\n");
                return -1;
        }

        printf("Successfully wrote data block bitmap to image.[%d]\n", ret);
        return 0;
}

/* Write the inode table to the image */
int write_inode_table(int filp, struct lab5fs_inode root_inode, struct lab5fs_inode test_inode) {
        struct lab5fs_inode inode_table[LAB5FS_MAX_NUM_INODES] = {0};
	inode_table[0] = root_inode;
	//inode_table[1] = test_inode;

	int ret = write(filp, &inode_table, sizeof(inode_table));

	if (sizeof(inode_table) != ret) {
		printf("Error writing inode table to disk.\n");
		return -1;
	}

	printf("Successfully wrote inode table to disk.[%d]\n", sizeof(inode_table));
	return 0;
}

int write_root_directory(int filp, struct lab5fs_direntry root_directory) {
	int ret = write(filp, &root_directory, sizeof(root_directory));

	if (sizeof(root_directory) != ret) {
		printf("Error writing root directory to datablock\n");
		return -1;
	}

	// Write padding to the block to equal one block
	/*int padding = LAB5FS_BLOCK_SIZE - sizeof(root_directory);
	ret = lseek(filp, padding, SEEK_CUR);

	if (ret == (off_t)-1) {
		printf("Error writing padding for root directory\n");
		return -1;
	}*/

	printf("Successfully wrote root directory [%d]\n", sizeof(root_directory));
	return 0;
}

void print_file_write_error() {
	printf("Error writing to file\n");
	return;
}

/*
 * C program for initializing our lab 5 file system to a file
 * parameter should be the name of the file being formatted.
 */

int main(int argc, char **argv) {
	if (2 != argc) {
		printf("Invalid number of arguments. Please provide the file to format.\n");
		return 0;
	}
	
	/* We should write our super block to the file provided. */
	int filp = open(argv[1], O_WRONLY | O_CREAT);
	if (filp == -1) {
		printf("Error opening the file.\n");
		return;
	}
 
        /* Creating exiting inode and data for root */       
        uint32_t default_inode_blocks[LAB5FS_MAX_BLOCKS_PER_FILE] = {0};
	struct lab5fs_direntry root_dir = {
		.inode = LAB5FS_ROOT_INO,
		.rec_len = LAB5FS_DIRENT_SIZE - LAB5FS_NAME_LEN,
		.name_len = 0,
                .ftype = LAB5FS_VDIR,
		.name = ""
	};

        default_inode_blocks[0] = LAB5FS_FIRST_DATA_BLOCK;
	struct lab5fs_inode root_inode = {
            .i_uid = 0,
            .i_gid = 0,
            .i_nlink = 1,
            .i_mode = S_IFDIR | S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH,    /* permissions - 0x40755 */
            .i_ino = LAB5FS_ROOT_INO,
            .i_size = LAB5FS_BLOCK_SIZE, //sizeof(struct lab5fs_direntry),
            .block_no = LAB5FS_FIRST_DATA_BLOCK,
            .i_blocks = 1,
            //.i_last_blk_offset = sizeof(struct lab5fs_direntry),
            .i_vtype = LAB5FS_VDIR,
            .i_atime = time(NULL),
            .i_ctime = time(NULL),
            .i_mtime = time(NULL),
	};
        memcpy(root_inode.i_block, default_inode_blocks, sizeof(uint32_t)*LAB5FS_MAX_BLOCKS_PER_FILE);
    
        /* just testing an existing file */
        struct lab5fs_inode test_inode = {
            .i_uid = 0,
            .i_gid = 0,
            .i_nlink = 1,
            .i_mode = S_IFREG | S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH,    /* permissions - 0x40755 */
            .i_ino = LAB5FS_ROOT_INO+1,
            .i_size = 0,
            .block_no = LAB5FS_FIRST_DATA_BLOCK+1,
            .i_blocks = 0,
            .i_vtype = LAB5FS_VREG,
            .i_atime = time(NULL),
            .i_ctime = time(NULL),
            .i_mtime = time(NULL),
        };
        default_inode_blocks[0] = LAB5FS_FIRST_DATA_BLOCK+1;
        memcpy(test_inode.i_block, default_inode_blocks, sizeof(uint32_t)*LAB5FS_MAX_BLOCKS_PER_FILE);

        struct lab5fs_direntry test_file = {
                .inode = LAB5FS_ROOT_INO+1,
		.rec_len = 18,
                .name_len = 9,
                .ftype = LAB5FS_VREG,
                .name = "test0.txt"
        };

	int ret = 1;

        // sanity check for Eric
        /*int i = 0;
        for (i = 0; i < LAB5FS_MAX_BLOCKS_PER_FILE; i++) {
            printf("block index %lu\n", root_inode.i_block[i]);
        }*/
	
	
	/* Here's the plan coach. First write a super block to block 0.
	 * Then clear out some memory for the inode bitmap
	 * Then clear out some memory for the inode table
	 * Then write the "." and ".." directories to the disk
	 * Then let the user know that we're done. 	 
	 */
	
	do {
		if(write_superblock(filp)) {
                	print_file_write_error();
			ret = -1;
			break;
        	}
		if (write_inode_bitmap(filp)) {
			print_file_write_error();
			ret = -1;
			break;
		}
		if (write_data_block_bitmap(filp)) {
			print_file_write_error();
			ret = -1;
			break;
		}
		if (write_inode_table(filp, root_inode, test_inode)) {
			print_file_write_error();
			ret = -1;
			break;
		}
		if (write_root_directory(filp, root_dir)) {
			print_file_write_error();
			ret = -1;
			break;
		}
		/*if (write_root_directory(filp, test_file)) {
			print_file_write_error();
			ret = -1;
			break;
		}*/
	} while (0);
	
        close(filp);
        printf("Successfully created lab5fs\n"); 
	return ret;	
}
