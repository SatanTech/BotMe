#!/bin/bash

# Fungsi untuk mengecek dan menginstal Node.js & NPM
check_node() {
    if ! command -v node &> /dev/null; then
        echo -e "⚙️ Node.js belum terinstall. Menginstall versi terbaru (LTS)..."
        
        # Update paket sistem
        apt update && apt install -y curl sudo
        
        # Menggunakan Nodesource untuk Node.js versi LTS terbaru (misal v20 atau v22)
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
        
        echo -e "✅ Node.js $(node -v) & NPM $(npm -v) berhasil diinstall!"
    else
        echo -e "✅ Node.js $(node -v) sudah terinstall."
    fi
}

menu_management() {
    clear
    
    # 0. Jalankan pengecekan Node.js dulu
    check_node
    
    # 1. Buat folder kerja
    mkdir -p /etc/bt-manager
    cd /etc/bt-manager

    # 2. Inisialisasi package.json (Paksa gunakan Type Module)
    if [ ! -f "package.json" ]; then
        echo -e "📦 Menginisialisasi proyek Node.js..."
        npm init -y
        # Tambahkan type: module agar bisa pakai 'import'
        sed -i 's/"main": "index.js"/"main": "index.js",\n  "type": "module"/g' package.json
        npm install bt-bot-vpn-tele-manager
    fi

    # 3. Buat file index.js (Entry Point)
    echo "import 'bt-bot-vpn-tele-manager';" > index.js

    # 4. Cek file .env
    if [ ! -f ".env" ]; then
        echo -e "\n--- Konfigurasi Bot Baru ---"
        read -p "Masukkan Token Bot Telegram: " bot_token
        read -p "Masukkan ID Telegram Admin: " admin_id
        
        echo "BOT_TOKEN=$bot_token" > .env
        echo "ADMIN_ID=$admin_id" >> .env
        echo -e "✅ Konfigurasi disimpan di .env\n"
    fi

    # 5. Jalankan menggunakan PM2
    if ! command -v pm2 &> /dev/null; then
        echo -e "⚙️ Menginstall PM2..."
        npm install -g pm2
    fi

    echo -e "📡 Memulai bot..."
    pm2 stop bt-manager &> /dev/null
    pm2 delete bt-manager &> /dev/null
    pm2 start index.js --name "bt-manager"
    
    echo -e "\n──────────────────────────────────────────"
    echo -e "🚀 Bot berhasil dijalankan dalam background!"
    echo -e "💡 Gunakan 'pm2 logs bt-manager' untuk melihat log."
    echo -e "──────────────────────────────────────────"
}

# Jalankan fungsi
menu_management
