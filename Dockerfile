FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Installation de Java, Python et Audiveris (version dépôts Ubuntu)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openjdk-17-jre-headless \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-fra \
    audiveris \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installation des bibliothèques Python
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# Création des dossiers et droits
RUN mkdir -p temp_music output_music && chmod -R 777 /app

# Lancement
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
