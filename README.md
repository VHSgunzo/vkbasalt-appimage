# vkBasalt-AppImage
* Build vkBasalt AppImage with Reshade Shaders in docker

## To get started:

* **Install git and docker for your distribution**

* **Download the latest revision**
```
git clone https://github.com/VHSgunzo/vkbasalt-appimage.git && cd vkbasalt-appimage
```

* **Build docker image**
```
docker build ./ -t vkbasalt
```

* **Build vkBasalt AppImage**
```
# Replace <BUILD_DIRECTORY> by the full path where you want to find the result of the build
docker run --rm -v <BUILD_DIRECTORY>:/target vkbasalt:latest
```

## Usage:
```
vkBasalt.*-x86_64.AppImage <program>
```

## Default parameters:
```
config file: /tmp/vkBasalt.conf (dynamically generated)
toggleKey = Home
effects = cas:Colourfulness:Tonemap
casSharpness = 0.6
```

## Additional environment variables:
```
RESHADE_DIR=<custom dir with Reshade Shaders>
VKBASALT_EFFECTS=<cas:Colourfulness:Tonemap...>
VKBASALT_FFX_CAS=<casSharpness 0.0-1.0>
VKBASALT_CONFIG_FILE=<custom vkbasalt config file>
```
