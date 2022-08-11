#!/usr/bin/env bash

(cd / && ./linuxdeploy.AppImage --appimage-extract)
cd /git

cat << EOF > ./vkbasalt.desktop
[Desktop Entry]
Encoding=UTF-8
Name=vkBasalt
Categories=Game;
Exec=vkbasalt %U
Icon=debian-logo
Terminal=true
Type=Application
StartupNotify=true
EOF

cat <<'EOF' > ./AppDir/AppRun
#!/bin/bash

HERE="$(dirname "$(readlink -f "${0}")")"

if [ "$#" -eq 0 ]; then
        echo "ERROR: No program supplied"
        echo
        echo "Usage: vkbasalt <program>"
        exit 1
fi

check_vkbasalt_cfg() {
    [ ! -n "$RESHADE_DIR" ] && \
    export RESHADE_DIR="$HERE/reshade"
    [ ! -n "$VKBASALT_CONFIG_FILE" ] && \
    export VKBASALT_CONFIG_FILE='/tmp/vkBasalt.conf'
    if [[ ! -f "$VKBASALT_CONFIG_FILE" && -d "$RESHADE_DIR" ]] || \
        [[ -f "$VKBASALT_CONFIG_FILE" && -d "$RESHADE_DIR" \
        && ! -n "$(grep -wo "$RESHADE_DIR" "$VKBASALT_CONFIG_FILE" 2>/dev/null)" ]]
        then
            echo -e "reshadeTexturePath = $RESHADE_DIR/textures" > "$VKBASALT_CONFIG_FILE"
            echo -e "reshadeIncludePath = $RESHADE_DIR/shaders" >> "$VKBASALT_CONFIG_FILE"
            (while read RES_NAME <&3 && read RES_FLPTH <&4
                do
                    echo "$RES_NAME = $RES_FLPTH"
            done 3< <(ls -1 "$RESHADE_DIR/shaders/"*.fx|sed 's/.fx$//'|xargs -I {} basename {}) \
                 4< <(ls -1 "$RESHADE_DIR/shaders/"*.fx)) >> "$VKBASALT_CONFIG_FILE"
    elif [[ -f "$VKBASALT_CONFIG_FILE" && ! -d "$RESHADE_DIR" \
        && -n "$(grep -wo 'reshadeTexturePath' "$VKBASALT_CONFIG_FILE" 2>/dev/null)" ]]
        then
            rm -rf "$VKBASALT_CONFIG_FILE"
            export VKBASALT_EFFECTS="cas"
    elif [[ ! -f "$VKBASALT_CONFIG_FILE" && ! -d "$RESHADE_DIR" ]]
        then
            export VKBASALT_EFFECTS="cas"
    fi
    if [ ! -n "$(grep -wo 'toggleKey' "$VKBASALT_CONFIG_FILE" 2>/dev/null)" ]
        then
            echo "toggleKey = Home" >> "$VKBASALT_CONFIG_FILE"
    fi
}

check_vkbasalt_eff() {
    export ENABLE_VKBASALT=1
    [ ! -n "$VKBASALT_FFX_CAS" ] && export VKBASALT_FFX_CAS="0.6"
    [ ! -n "$VKBASALT_EFFECTS" ] && export VKBASALT_EFFECTS="cas:Colourfulness:Tonemap"
    if [ ! -n "$(grep -wo "effects" "$VKBASALT_CONFIG_FILE" 2>/dev/null)" ]
        then
            echo "effects = $VKBASALT_EFFECTS" >> "$VKBASALT_CONFIG_FILE"
        else
            if [ "$(grep "effects = $VKBASALT_EFFECTS" "$VKBASALT_CONFIG_FILE" \
                2>/dev/null|sed 's/effects = //')" != "$VKBASALT_EFFECTS" ]
                then
                    sed -i "s/effects = .*/effects = $VKBASALT_EFFECTS/g" "$VKBASALT_CONFIG_FILE"
            fi
    fi
    if [ "$VKBASALT_FFX_CAS" != "Disabled" ]
        then
            if [ ! -n "$(grep -wo "casSharpness" "$VKBASALT_CONFIG_FILE" 2>/dev/null)" ]
                then
                    echo "casSharpness = $VKBASALT_FFX_CAS" >> "$VKBASALT_CONFIG_FILE"
                else
                    if [ "$(grep "casSharpness = $VKBASALT_FFX_CAS" "$VKBASALT_CONFIG_FILE" \
                        2>/dev/null|sed 's/casSharpness = //')" != "$VKBASALT_FFX_CAS" ]
                        then
                            sed -i "s/casSharpness.*/casSharpness = $VKBASALT_FFX_CAS/g" "$VKBASALT_CONFIG_FILE"
                    fi
            fi
        else
            VKBASALT_OTHEFF="$(grep -w "effects" "$VKBASALT_CONFIG_FILE" 2>/dev/null|\
                sed 's/effects = //'|sed 's/cas//'|sed 's/::/:/'|sed 's/^://'|sed 's/:$//')"
            if [ -n "$VKBASALT_OTHEFF" ]
                then
                    sed -i "s/effects = .*/effects = $VKBASALT_OTHEFF/" "$VKBASALT_CONFIG_FILE"
                else
                    sed -i "/effects.*/d" "$VKBASALT_CONFIG_FILE" 2>/dev/null
                    export DISABLE_VKBASALT=1
            fi
            sed -i "/casSharpness.*/d" "$VKBASALT_CONFIG_FILE" 2>/dev/null
    fi
}

check_vkbasalt_cfg
check_vkbasalt_eff
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$HERE/usr/lib:$HERE/usr/lib32"
export VK_LAYER_PATH="$HERE/usr/share/vulkan/implicit_layer.d:${VK_LAYER_PATH}"
export VK_INSTANCE_LAYERS=VK_LAYER_VKBASALT_post_processing:${VK_INSTANCE_LAYERS}

"$@"
EOF

chmod +x ./AppDir/AppRun
mkdir -p ./AppDir/usr/lib32
mv ./AppDir/lib/ ./AppDir/share/ ./AppDir/usr/
mv ./AppDir/usr/lib/i386-linux-gnu/libvkbasalt.so ./AppDir/usr/lib32/
rm -rfv ./AppDir/usr/lib/i386-linux-gnu
mv ./reshade ./AppDir/
(cd ./AppDir/usr/lib && ln -sv ../lib32 ./i386-linux-gnu)

export ARCH=x86_64
/squashfs-root/AppRun \
  --appdir ./AppDir \
  -d ./vkbasalt.desktop \
  -i /usr/share/pixmaps/debian-logo.png \
  --output appimage

VKBASALT_VERSION="$(cat 'vkbasalt_version' 2>/dev/null)"
VKBASALT_AI="$(ls ./*.AppImage 2>/dev/null)"

[ -f "$VKBASALT_AI" ] && \
mv "$VKBASALT_AI" /target/vkBasalt-${VKBASALT_VERSION}-${ARCH}.AppImage
# [ -f "$VKBASALT_AI" ] && \
# mv "$VKBASALT_AI" /target/vkbasalt

exec "$@"
