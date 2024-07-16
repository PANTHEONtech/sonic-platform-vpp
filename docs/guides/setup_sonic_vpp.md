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
3. **Create the sonic-platform-vpp workspace**:
   - Download `prepare_workspace.sh` from the scripts folder in this project (/docs/guides/scripts)
   - Drag and drop it into the VM (it should appear in the **Downloads** folder).
   - Right click in the **Downloads** folder and **Open in Terminal**
   - Firstly, we need to install git for the script to work properly:
		```sh
        sudo apt install git
        ```
   - Now, we can run the workspace preparation script: 
     ```sh
        chmod +x prepare_workspace.sh
        ./prepare_workspace.sh
        ```
   - This script will create a workspace folder in your $HOME directory, clone the sonic-platform-vpp repository (you can edit the script for a specific fork) 2 times, naming one of them as dev for developing new features (the other one is for building the docker-sonic-vpp image) and create a backups folder.

5. **Install dependencies**:
   - go to one of the projects **scripts** folder and install all dependencies with 1 script:
        ```sh
        cd $HOME/workspace/dev/docs/guides/scripts
        ./manage_dependencies.sh --install 
        ```
	- you can check --help for all the scripts  in the folder if unsure of what to do.

6. **Build both projects**:

   ```sh
      cd $HOME/workspace/dev
      make sonic
   ```

   ```sh
      cd $HOME/workspace/sonic-platform-vpp
      make sonic
   ```

   - each build will probably fail, if it does, go to build/sonic-buildimage/Makefile and change NO_BUSTER = 0 to 1
   - go back to root of the project and run `make sonic` again

7. **Monitor Resources (Optional)**:
   - Use the **System Monitor** application in the **Resources** tab to monitor CPU and RAM usage.

## Troubleshooting
### Issue 1: Build process halts unexpectedly
- **Error**: `dh_auto_test: error: make -j20 check VERBOSE=1 returned exit code 2` or similar (a process has been killed).
- **Cause**: Running out of memory due to high number of parallel jobs.

#### Solution
1. **Adjust CPU cores for make jobs**:
   - Depending on which build you do, go into the respective project folder (dev or sonic-platform-vpp), we'll need the `manage_cores.sh` script:
        ```sh
        cd $HOME/workspace/dev/docs/guides/scripts
        ```
   - Run the script to limit CPU cores used during building process (4-6 is recommended):
        ```sh
        chmod +x manage_cores.sh
        ./manage_cores.sh --make-jobs <number_of_cores>
        ```
   - To revert changes back to default value (using all the available CPU cores):
        ```sh
        ./manage_cores.sh --make-jobs-revert
        ```
2. **Rebuild Project**:
   - Go to the root of the current project (dev or sonic-platform-vpp) and run the build again:
        ```sh
        make sonic
        ```
### Issue 2: Build process halts on protobuf tests
- **Error**: Similar to Issue 1, output shows that 1 test fails.
- **Cause**: Same as Issue 1, running out of memory due to high number of parallel jobs.

#### Solution
1. **Adjust CPU cores for protobuf tests script**:
   - Depending on which build you do, go into the respective project folder (dev or sonic-platform-vpp), we'll need the `manage_cores.sh` script:
        ```sh
        cd $HOME/workspace/dev/docs/guides/scripts
        ```
   - Run the script to limit CPU cores used during building process (4-6 is recommended):
        ```sh
        ./manage_cores.sh --protobuf <number_of_cores>
        ```
   - To revert changes back to default value (using all the available CPU cores):
        ```sh
        ./manage_cores.sh --protobuf-revert
        ```
2. **Rebuild Project**:
   - Go to the root of the current project (dev or sonic-platform-vpp) and run the build again:
        ```sh
        make sonic
        ```

