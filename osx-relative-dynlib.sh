#!/bin/bash -eu

process_binary() {
    local binary="$1"
    echo "[*] Processing $binary..."

    # Find all linked libraries from the Homebrew prefix
    local libraries=(
        $(otool -L "$binary" | grep '/usr/local/opt/' | awk '{print $1}')
    )
    
    # If this is a dylib, the first entry is the ID of the library itself, which
    # we don't really care about.
    if [ "${binary##*.}" = "dylib" ]; then
        libraries=("${libraries[@]:1}")
    fi

    # When empty, skip the loop to avoid a Bash unbound variable error
    if [ ${#libraries[@]} -le 0 ]; then
        continue
    fi

    for lib in "${libraries[@]}"; do
        local lib_basename=$(basename "$lib")

        # Check that we have a copy of each linked library
        if [ ! -f "$lib_basename" ]; then
            echo "  [-] Failed to find linked library $lib_basename"
            continue
        fi

        # Change the path to be relative
        install_name_tool -change "$lib" "@executable_path/$lib_basename" \
                          "$binary"
        echo "  [+] Made relative link to $lib_basename"
    done
}


for binary in *.dylib $(find . -type f -perm +111); do
    process_binary "$binary"
done

