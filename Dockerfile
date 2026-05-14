# On utilise l'image officielle d'Audiveris : tout est déjà installé (Java + Audiveris)
FROM audiveris/audiveris:latest

USER root

# Installation de Python et des outils PDF
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-fra \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installation des bibliothèques Python
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# Création des dossiers avec les bons droits
RUN mkdir -p temp_music output_music && chmod -R 777 /app

# Le binaire audiveris est déjà dans le PATH sur cette image
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
