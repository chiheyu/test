#!/data/data/com.termux/files/usr/bin/bash

# Colors
red='\033[1;31m'
yellow='\033[1;33m'
blue='\033[1;34m'
green='\033[1;32m'
reset='\033[0m'

# Variables
PREFIX="/data/data/com.termux/files/usr"
HOME="/data/data/com.termux/files/home"
DESTINATION="$HOME/chroot/kali-arm64"
SETARCH="arm64"
chroot="full"

# Print functions
print_status() {
    printf "\n${blue}[*] $1${reset}\n"
}

print_success() {
    printf "\n${green}[+] $1${reset}\n"
}

print_error() {
    printf "\n${red}[!] $1${reset}\n"
}

print_warning() {
    printf "\n${yellow}[!] $1${reset}\n"
}

# Check system architecture
check_architecture() {
    print_status "Checking host architecture..."
    case $(getprop ro.product.cpu.abi) in
        arm64-v8a)
            SETARCH="arm64"
            ;;
        armeabi|armeabi-v7a)
            SETARCH="armhf"
            ;;
        *)
            print_error "Unknown architecture: $(getprop ro.product.cpu.abi)"
            exit 1
            ;;
    esac
    print_success "Architecture: $SETARCH"
}

# Check and install dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    # Update package list
    pkg update -y
    
    # Install required packages
    pkg install -y proot tar axel wget
    
    print_success "Dependencies installed"
}

# Set URL for download
set_url() {
    URL="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-${chroot}-${SETARCH}.tar.xz"
    print_status "Download URL: $URL"
}

# Download Kali rootfs
download_rootfs() {
    print_status "Downloading Kali NetHunter rootfs..."
    
    cd $HOME
    rootfs="kali-nethunter-rootfs-${chroot}-${SETARCH}.tar.xz"
    
    if [ -f "$rootfs" ]; then
        print_warning "Rootfs file already exists. Skipping download."
    else
        print_status "Downloading from $URL"
        wget -O "$rootfs" "$URL"
        
        if [ $? -ne 0 ]; then
            print_error "Download failed. Trying with axel..."
            axel -a "$URL"
        fi
    fi
    
    if [ ! -f "$rootfs" ]; then
        print_error "Failed to download rootfs"
        exit 1
    fi
    
    print_success "Download completed"
}

# Extract rootfs
extract_rootfs() {
    print_status "Extracting rootfs..."
    
    # Create destination directory
    mkdir -p "$DESTINATION"
    
    # Extract with proot to handle device files
    cd $HOME
    proot --link2symlink tar -xf "$rootfs" -C $HOME 2>/dev/null || {
        print_warning "Some device files could not be created (this is normal)"
    }
    
    # Move to correct location if needed
    if [ -d "$HOME/kali-$SETARCH" ]; then
        mv "$HOME/kali-$SETARCH" "$DESTINATION"
    fi
    
    print_success "Extraction completed"
}

# Create startkali script
create_startkali() {
    print_status "Creating startkali script..."
    
    cat > $PREFIX/bin/startkali.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD

# Colors
red='\033[1;31m'
yellow='\033[1;33m'
blue='\033[1;34m'
green='\033[1;32m'
reset='\033[0m'

# Variables
DESTINATION="$HOME/chroot/kali-arm64"
PROOT="/data/data/com.termux/files/usr/bin/proot"

# Check if Kali environment exists
if [ ! -d "$DESTINATION" ]; then
    printf "\n${red}[!] Kali environment not found at $DESTINATION${reset}\n"
    printf "${yellow}[!] Please run the installation script first${reset}\n"
    exit 1
fi

# Set user and home
if [[ ("$#" != "0" && ("$1" == "-r")) ]]; then
    user="root"
    home="$DESTINATION/root"
    login="/bin/bash --login"
    shift
else
    user="kali"
    home="$DESTINATION/home/kali"
    login="/bin/bash"
fi

# Set environment variables
export HOME="$home"
export TERM="$TERM"
export LANG="$LANG"
export PATH="$DESTINATION/bin:$home/bin:$DESTINATION/sbin:$home/sbin:$DESTINATION/usr/bin:$home/.local/bin:$PATH"

# Create .version file if it doesn't exist
if [ ! -f "$DESTINATION/root/.version" ]; then
    touch "$DESTINATION/root/.version"
fi

# Start Kali environment
printf "\n${green}[+] Starting Kali NetHunter...${reset}\n"
printf "${blue}[*] User: $user${reset}\n"
printf "${blue}[*] Home: $home${reset}\n"

$PROOT --link2symlink -0 -r "$DESTINATION" \
    -b /dev \
    -b /proc \
    -b "$DESTINATION/dev:/dev/shm" \
    -b /sdcard \
    -b "$HOME" \
    -w "$home" \
    $login "$@"
EOF

    # Set permissions
    chmod 700 $PREFIX/bin/startkali.sh
    
    # Create symlink
    ln -sf $PREFIX/bin/startkali.sh $PREFIX/bin/startkali
    chmod +x $PREFIX/bin/startkali
    
    print_success "startkali script created"
}

# Setup Kali environment
setup_kali() {
    print_status "Setting up Kali environment..."
    
    # Create .version file
    touch "$DESTINATION/root/.version"
    
    # Setup DNS
    echo "nameserver 8.8.8.8" > "$DESTINATION/etc/resolv.conf"
    echo "nameserver 8.8.4.4" >> "$DESTINATION/etc/resolv.conf"
    
    # Create kali user home if it doesn't exist
    mkdir -p "$DESTINATION/home/kali"
    chmod 755 "$DESTINATION/home/kali"
    
    print_success "Kali environment setup completed"
}

# Final setup
final_setup() {
    print_status "Running final setup..."
    
    # Download and run finaltouchup script
    if [ -f "$HOME/finaltouchup.sh" ]; then
        rm "$HOME/finaltouchup.sh"
    fi
    
    wget -O "$HOME/finaltouchup.sh" "https://github.com/Hax4us/Nethunter-In-Termux/raw/master/finaltouchup.sh"
    
    if [ -f "$HOME/finaltouchup.sh" ]; then
        DESTINATION="$DESTINATION" SETARCH="$SETARCH" bash "$HOME/finaltouchup.sh"
    else
        print_warning "Could not download finaltouchup script"
    fi
    
    print_success "Final setup completed"
}

# Main installation function
main() {
    clear
    printf "\n${yellow}================================${reset}\n"
    printf "${yellow}  Kali NetHunter in Termux${reset}\n"
    printf "${yellow}================================${reset}\n"
    printf "\n${blue}[*] Starting installation...${reset}\n"
    
    # Run installation steps
    check_architecture
    check_dependencies
    set_url
    download_rootfs
    extract_rootfs
    create_startkali
    setup_kali
    final_setup
    
    # Installation complete
    printf "\n${green}================================${reset}\n"
    printf "${green}  Installation Complete!${reset}\n"
    printf "${green}================================${reset}\n"
    printf "\n${blue}[*] Usage:${reset}\n"
    printf "${yellow}  startkali     - Start Kali as kali user${reset}\n"
    printf "${yellow}  startkali -r  - Start Kali as root user${reset}\n"
    printf "${yellow}  exit          - Exit Kali environment${reset}\n"
    printf "\n${blue}[*] Enjoy Kali NetHunter in Termux!${reset}\n"
    printf "${reset}\n"
}

# Run main function
main "$@"
