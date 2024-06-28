# Developer Workflow for SONiC-vpp Environment (VXLAN)

**Note:** This workflow assumes that `setup_sonic_vpp_.md` was followed and your project is named `dev` and is located in `$HOME/workspace/dev/`. If not, adjust any commands with absolute paths accordingly.

## 1. Install Useful Extensions
- Install Dev Containers and Docker VSCode Extensions.

## 2. Build and Run the Development Container

```sh
cd $HOME/workspace/dev/dockers/dev_container
make build_container
make docker_run
```

## 4. Attach to the Container
- In VSCode, go to Remote Explorer -> `sonic-vpp-dev` -> Attach in current window (or open in a new window).

## 5. Build `sonic-sairedis`
Run the following commands inside the `sonic-sairedis` directory to build it:

```sh
./autogen.sh
./configure --with-sai=vpp --enable-syncd --enable-python2=no
compiledb make
```

## 6. Rebuild `sonic-sairedis` After Changes
When you make changes inside the `vpplib`, clean the build and rebuild `sonic-sairedis`:

```sh
make distclean
autoreconf -i
./configure --with-sai=vpp --enable-syncd --enable-python2=no
compiledb make
```
---

# Replacing `sonic-sairedis` or Editing `vpplib`

**Backup the `sonic-sairedis` folder in the `sonic-platform-vpp` project before starting.** Do this outside of any container:

```sh
cp $HOME/workspace/sonic-platform-vpp/build/sonic-buildimage/src/sonic-sairedis backups/
```

## 1. Remove the Existing `sonic-sairedis` Folder

```sh
cd $HOME/workspace/sonic-platform-vpp/build/sonic-buildimage/src/
rm -rf sonic-sairedis
```

## 2. Copy the Modified `sonic-sairedis`
Inside `dockers/dev_container`, run:

```sh
make copy_vpplib
```

---

# Applying Changes to `docker-sonic-vpp.gz` Image and Testing

**Backup the "target" folder:**

```sh
cp $HOME/workspace/sonic-platform-vpp/build/sonic-buildimage/target backups/
```

## 1. Enable the VPP Plugin
### a) Edit `vpp_template.json`
In `$HOME/workspace/sonic-platform-vpp/platform/mkrules/files/build_templates/vpp_template.json`, add to the plugins list:

```json
"vxlan_plugin.so": "enable"
```

It should look similar to this:

```json
"plugins": {
	"plugin": {
	    "default": "disable",
	    "af_packet_plugin.so": "enable",
	    "dpdk_plugin.so": "enable",
	    "linux_cp_plugin.so": "enable",
	    "linux_nl_plugin.so": "enable",
		"vxlan_plugin.so": "enable"
	}
},
```

### b) Edit `startup.conf.tmpl`
In `$HOME/workspace/sonic-platform-vpp/platform/vpp/docker-sonic-vpp/conf/startup.conf.tmpl`, add:

```sh
plugin vxlan_plugin.so { enable }
```

It should look similar to this:

```sh
## Disable all plugins by default and then selectively enable specific plugins
plugin default { disable }
plugin af_packet_plugin.so { enable }
plugin dpdk_plugin.so { enable }
plugin linux_cp_plugin.so { enable }
plugin linux_nl_plugin.so { enable }
plugin acl_plugin.so { enable }
plugin vxlan_plugin.so { enable }
```

## 2. Clean and Rebuild the Image
From the root of the project (`sonic-platform-vpp`), run:

```sh
make clean_syncd_dependencies
make sonic
```
**Note:** The building process takes around 30 minutes.

## 3. Load the Built Docker Image

```sh
docker load < target/docker-sonic-vpp.gz
```

## 4. Install `containerlab`
If you don't have it already, install `containerlab`:

```sh
curl -sL https://containerlab.dev/setup | sudo bash -s "all"
```

## 5. Clone `vpp-sonic-labs` Repository

```sh
git clone https://github.com/Giluerre/vpp-sonic-labs.git
```

## 6. Open `vpp_vxlan_ebgp` in VSCode

```sh
cd vpp-sonic-labs/vpp_vxlan_ebgp
code .
```

## 7. Create the Environment
Run the script to create the environment:

```sh
./run.sh
```

## 8. Connect to `router1`
Open a new window of VSCode and connect to `router1`:

- Remote Explorer -> `docker-sonic-vpp` (with additional label `clab-frr01-router1`) -> Attach in current window.

## 9. Monitor the Setup Process
Go to `log/syslog` to see the setup process in real time.