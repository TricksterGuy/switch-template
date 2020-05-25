#include <string.h>
#include <stdio.h>

#include <switch.h>

int main(int argc, char **argv)
{
    // Initialize console. Using NULL as the second argument tells the console library to use the internal console structure as current one.
    consoleInit(NULL);

    // Switch console is 80x44
    // To move the cursor you have to print "\x1b[r;cH", where r and c are respectively
    // the row and column where you want your cursor to move
    // These strings are drawn at the center of the screen.
	printf("\x1b[21;27HTest Code::Blocks project!\n");
	printf("\x1b[22;30HPress Start to exit.");

    while(appletMainLoop())
    {
        // Scan all the inputs. This should be done once for each frame
        hidScanInput();

        // hidKeysDown returns information about which buttons have been just pressed (and they weren't in the previous frame)
        u64 kDown = hidKeysDown(CONTROLLER_P1_AUTO);
        if (kDown & KEY_PLUS) break; // break in order to return to hbmenu

        // Updates the screen.
        consoleUpdate(NULL);
    }

    consoleExit(NULL);
    return 0;
}
