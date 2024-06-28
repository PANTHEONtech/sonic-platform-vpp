# GUIDE for Building `sonic-platform-vpp`

## Requirements
- **Linux host machine** with **Ubuntu 20.x**
- **VM** with at least **10GB RAM** (ideal is **15GB+** depending on the number of CPU cores)

## Using GNOME Boxes
1. **Download** Ubuntu 20.04 LTS x86_64 (Live) image.
2. **Configure VM**:
   - **RAM**: At least 10 GiB
   - **Storage**: At least 300 GiB (building process temporarily takes around 100GB )

## Universal Steps
1. **Install Ubuntu**:
   - Choose **Minimal Installation** and tick **Download updates while installing Ubuntu**.
   - Erase disk and install Ubuntu (VM instance shouldn't have any OS)
   - **Write the changes to disks?** Continue.
   - Select **timezone**.
   - Optionally, check **Login automatically**.
   - After installation, **Restart** and press **Enter** when prompted.
2. **Initial Setup**:
   - Online Accounts, Livepatch **Skip**
   - Help improve Ubuntu **No, don't send system info** (it's a VM)
   - Turn off Location Services and **Done**
   - Go to **Settings -> Privacy -> Screen Lock** and set **Blank Screen Delay** to "Never".
3. **After Rebooting**:
   - Drag and drop `manage_dependencies.sh`, `manage_cores.sh` and `prepare_workspace.sh` into the VM (they should appear in the **Downloads** folder).
   - Right click in the **Downloads** folder and **Open in Terminal**
   - Run the workspace preparation script: 
        ```sh
        chmod +x *.sh
        ./prepare_workspace.sh
        ```
   - This script will clone the sonic-platform-vpp repository (you can edit the script for a specific fork) 2 times, naming one as dev for developing new features, moves the scripts inside a scripts/ folder within the workspace and created backups folder.

4. **Prepare Scripts**:
   - go into the newly created workspace directory and into the scripts folder to install dependencies
   - Run:
        ```sh
        ./manage_dependencies.sh --install 
        ```
	- you can check --help for these scripts if unsure of what to do.

5. Go into dev project and build it:

   ```sh
      cd $HOME/workspace/dev
      make sonic
   ```

   - the build will probably fail, if it does, go to build/sonic-buildimage/Makefile and change NO_BUSTER = 0 to 1
   - go back to root of the project and run `make sonic`

6. Go into sonic-platform-vpp project and build it:

   ```sh
      cd $HOME/workspace/sonic-platform-vpp
      make sonic
   ```

   - the build will probably fail, if it does, go to build/sonic-buildimage/Makefile and change NO_BUSTER = 0 to 1
   - go back to root of the project and run `make sonic`

7. **Monitor Resources (Optional)**:
   - Use the **System Monitor** application in the **Resources** tab to monitor CPU and RAM usage.



## Troubleshooting
### Issue 1: Build process halts unexpectedly
- **Error**: `dh_auto_test: error: make -j20 check VERBOSE=1 returned exit code 2` or similar (a process has been killed).
- **Cause**: Running out of memory due to high number of parallel jobs.

#### Solution
1. **Adjust CPU cores for make jobs**:
   - Go to the workspace/scripts directory, we'll need the `manage_cores.sh` script:
        ```sh
        cd $HOME/workspace/scripts
        ```
   - Edit the FILE_PATH variable inside the script to match the project path you are building right now
   - Run the script to limit CPU cores used during building process (4-6 is recommended):
        ```sh
        ./manage_cores.sh --make-jobs <number_of_cores>
        ```
   - To revert changes back to default value (using all the available CPU cores):
        ```sh
        ./manage_cores.sh --make-jobs-revert
        ```
2. **Rebuild Project**:
   - Run the building script (as we already are in the Downloads folder):
        ```sh
        ./run_build.sh
        ```
### Issue 2: Build process halts on protobuf tests
- **Error**: Similar to Issue 1, output shows that 1 test fails.
- **Cause**: Same as Issue 1, running out of memory due to high number of parallel jobs.

#### Solution
1. **Adjust CPU cores for protobuf tests script**:
   - Go to the workspace/scripts directory, we'll need the `manage_cores.sh` script:
        ```sh
        cd $HOME/workspace/scripts
        ```
   - Edit the PROTOBUF_TESTS_PATH variable inside the script to match the project path you are building right now
   - Run the script to limit CPU cores used during building process (4-6 is recommended):
        ```sh
        ./manage_cores.sh --protobuf <number_of_cores>
        ```
   - To revert changes back to default value (using all the available CPU cores):
        ```sh
        ./manage_cores.sh --protobuf-revert
        ```
2. **Rebuild Project**:
   - Run the building script (as we already are in the Downloads folder):
        ```sh
        ./run_build.sh
        ```

