# Utilisation d'Ubuntu 22.04 pour une meilleure compatibilité avec les bibliothèques audio/système
FROM ubuntu:22.04

# Éviter les questions interactives pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Installation des dépendances système (Java, Tesseract pour l'OCR, outils PDF)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openjdk-17-jre-headless \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-fra \
    libasound2 \
    libnss3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Installation d'Audiveris via ton fichier .deb
# On utilise 'dpkg -x' pour extraire les fichiers sans avoir besoin de droits 'root' complets
COPY Audiveris-5.10.1-ubuntu24.04-x86_64*.deb ./installer.deb
RUN dpkg -x ./installer.deb / && rm ./installer.deb

# 3. Installation des bibliothèques Python
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# 4. Copie du reste de ton code (main.py, etc.)
COPY . .

# 5. Création des dossiers temporaires avec les droits d'écriture
RUN mkdir -p temp_music output_music && chmod -R 777 /app

# 6. Lancement du serveur sur le port dynamique de Render
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
