FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Installation des outils de base
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openjdk-17-jre-headless \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-fra \
    libasound2 \
    libnss3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Téléchargement d'Audiveris via CURL (plus robuste que wget sur Render)
RUN curl -L https://github.com/Audiveris/audiveris/releases/download/v5.3/audiveris_5.3_amd64.deb -o installer.deb \
    && dpkg -x installer.deb / \
    && rm installer.deb

# 3. Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# 4. Dossiers et Permissions
RUN mkdir -p temp_music output_music && chmod -R 777 /app

# Lien symbolique pour être sûr que la commande 'audiveris' fonctionne
RUN ln -s /opt/audiveris/bin/audiveris /usr/bin/audiveris

CMD uvicorn main:app --host 0.0.0.0 --port $PORT
