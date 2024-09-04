#!/bin/bash

LOG_FILE="logCon.log"  # Updated log file name

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to show usage
usage() {
    log_message "Usage: $0 -r <root_dir> [-p]"
    log_message "  -r <root_dir>    Root directory for the container"
    log_message "  -p               Create a new process tree for the container"
    exit 1
}

# Function to copy files into the container
cntnr_cp() {
    local src_path="$1"
    local dest_path="$2"
    
    if [ -z "$src_path" ] || [ -z "$dest_path" ]; then
        log_message "Source and destination paths must be provided."
        return 1
    fi
    
    if file "$src_path" | grep -q "ELF"; then
        log_message "Skipping ELF file: $src_path"
        return 0
    fi

    # Copy the file into the container
    log_message "Copying $src_path to container path $dest_path"
    sudo cp "$src_path" "$ROOT_DIR/$dest_path"

    if [ $? -ne 0 ]; then
        log_message "Failed to copy file from $src_path to $ROOT_DIR/$dest_path"
        return 1
    fi
    
    log_message "Successfully copied file from $src_path to $ROOT_DIR/$dest_path"
    return 0
}

# Parse command line arguments
while getopts "r:p" opt; do
    case ${opt} in
        r )
            ROOT_DIR=${OPTARG}
            ;;
        p )
            CREATE_PID_NS=true
            ;;
        * )
            usage
            ;;
    esac
done

# Check if root directory is provided
if [ -z "$ROOT_DIR" ]; then
    usage
fi

log_message "Starting container creation process..."

# Create the root directory if it doesn't exist
if [ ! -d "$ROOT_DIR" ]; then
    log_message "Creating root directory at $ROOT_DIR"
    mkdir -p "$ROOT_DIR"

    # Populate the root directory with the required structure
    debootstrap stable "$ROOT_DIR"
fi

# Check if debootstrap command was successful
if [ $? -ne 0 ]; then
    log_message "Failed to create the root filesystem using debootstrap."
    exit 1
fi

# Mount proc if not already mounted
if ! mountpoint -q "$ROOT_DIR/proc"; then
    log_message "Mounting proc filesystem..."
    sudo mount -t proc proc "$ROOT_DIR/proc"
fi

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

# Example usage of cntnr_cp (remove or modify as needed)
# cntnr_cp /path/to/host/file /path/to/container/file
EOF

chmod +x "$CONTAINER_SCRIPT"

# Set the PS1 variable inside the container
# Inside create_container.sh
SET_PS1="export PS1='<inside> \u@\h:\w\$ '; source /container_script.sh; echo 'container_script sourced'"

# Create the isolated environment
if [ "$CREATE_PID_NS" = true ]; then
    UNSHARE_COMMAND="sudo unshare --root=\"$ROOT_DIR\" --pid --fork /bin/bash -c \"$SET_PS1; /bin/bash\""
    log_message "Launched container with unshare command: $UNSHARE_COMMAND"
    eval "$UNSHARE_COMMAND"
    log_message "Started container with PID: $$"
else
    UNSHARE_COMMAND="sudo unshare --root=\"$ROOT_DIR\" /bin/bash -c \"$SET_PS1; /bin/bash\""
    log_message "Launched container with unshare command: $UNSHARE_COMMAND"
    eval "$UNSHARE_COMMAND"
    log_message "Started container with PID: $$"
fi

log_message "Container creation process completed."
