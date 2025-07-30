#!/data/data/com.termux/files/usr/bin/bash

# Colors
red='\033[1;31m'
yellow='\033[1;33m'
blue='\033[1;34m'
green='\033[1;32m'
reset='\033[0m'

# Variables
DESTINATION="${DESTINATION:-$HOME/chroot/kali-arm64}"
SETARCH="${SETARCH:-arm64}"

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

# Check if Kali environment exists
check_environment() {
    if [ ! -d "$DESTINATION" ]; then
        print_error "Kali environment not found at $DESTINATION"
        exit 1
    fi
    print_success "Kali environment found"
}

# Fix permissions
fix_permissions() {
    print_status "Fixing permissions..."
    
    # Fix ownership and permissions
    chmod 755 "$DESTINATION"
    chmod 755 "$DESTINATION/home"
    chmod 755 "$DESTINATION/home/kali"
    chmod 755 "$DESTINATION/root"
    
    # Fix important directories
    chmod 755 "$DESTINATION/bin"
    chmod 755 "$DESTINATION/sbin"
    chmod 755 "$DESTINATION/usr"
    chmod 755 "$DESTINATION/usr/bin"
    chmod 755 "$DESTINATION/usr/sbin"
    
    print_success "Permissions fixed"
}

# Setup basic system files
setup_system_files() {
    print_status "Setting up system files..."
    
    # Create /etc/passwd if it doesn't exist
    if [ ! -f "$DESTINATION/etc/passwd" ]; then
        cat > "$DESTINATION/etc/passwd" << 'EOF'
root:x:0:0:root:/root:/bin/bash
kali:x:1000:1000:kali:/home/kali:/bin/bash
EOF
    fi
    
    # Create /etc/group if it doesn't exist
    if [ ! -f "$DESTINATION/etc/group" ]; then
        cat > "$DESTINATION/etc/group" << 'EOF'
root:x:0:
kali:x:1000:
EOF
    fi
    
    # Create /etc/shadow if it doesn't exist
    if [ ! -f "$DESTINATION/etc/shadow" ]; then
        cat > "$DESTINATION/etc/shadow" << 'EOF'
root:*:0:0:99999:7:::
kali:*:0:0:99999:7:::
EOF
    fi
    
    # Setup DNS
    echo "nameserver 8.8.8.8" > "$DESTINATION/etc/resolv.conf"
    echo "nameserver 8.8.4.4" >> "$DESTINATION/etc/resolv.conf"
    
    # Create .version file
    touch "$DESTINATION/root/.version"
    
    print_success "System files setup completed"
}

# Install basic tools
install_basic_tools() {
    print_status "Installing basic tools..."
    
    # Create a simple package manager script
    cat > "$DESTINATION/usr/local/bin/apt" << 'EOF'
#!/bin/bash
echo "Package manager not available in this environment"
echo "Please use Termux package manager (pkg) for installing packages"
exit 1
EOF
    
    chmod +x "$DESTINATION/usr/local/bin/apt"
    
    # Create basic commands if they don't exist
    if [ ! -f "$DESTINATION/bin/ls" ]; then
        ln -sf /bin/busybox "$DESTINATION/bin/ls" 2>/dev/null || true
    fi
    
    if [ ! -f "$DESTINATION/bin/cat" ]; then
        ln -sf /bin/busybox "$DESTINATION/bin/cat" 2>/dev/null || true
    fi
    
    print_success "Basic tools installed"
}

# Setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    # Create .bashrc for kali user
    cat > "$DESTINATION/home/kali/.bashrc" << 'EOF'
# Kali NetHunter bashrc
export PS1='\[\033[01;32m\]kali@\[\033[01;31m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
EOF
    
    # Create .bashrc for root user
    cat > "$DESTINATION/root/.bashrc" << 'EOF'
# Kali NetHunter bashrc (root)
export PS1='\[\033[01;31m\]root@\[\033[01;31m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# '
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
EOF
    
    print_success "Environment setup completed"
}

# Main function
main() {
    print_status "Running final setup for Kali NetHunter..."
    
    check_environment
    fix_permissions
    setup_system_files
    install_basic_tools
    setup_environment
    
    print_success "Final setup completed successfully!"
    print_status "You can now use 'startkali' to enter Kali environment"
}

# Run main function
main "$@"
