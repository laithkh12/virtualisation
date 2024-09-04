# Create a script to be executed inside the container
CONTAINER_SCRIPT="$ROOT_DIR/container_script.sh"
cat << 'EOF' > "$CONTAINER_SCRIPT"
#!/bin/bash

# Function to copy files into the container
cntnr_cp() {
    local src_path="$1"
    local dest_path="$2"
    
    if [ -z "$src_path" ] || [ -z "$dest_path" ]; then
        echo "Source and destination paths must be provided."
        return 1
    fi
    
    if file "$src_path" | grep -q "ELF"; then
        echo "Skipping ELF file: $src_path"
        return 0
    fi

    # Copy the file into the container
    echo "Copying $src_path to container path $dest_path"
    cp "$src_path" "$dest_path"

    if [ $? -ne 0 ]; then
        echo "Failed to copy file from $src_path to $dest_path"
        return 1
    fi
    
    echo "Successfully copied file from $src_path to $dest_path"
    return 0
}


EOF

chmod +x "$CONTAINER_SCRIPT"
