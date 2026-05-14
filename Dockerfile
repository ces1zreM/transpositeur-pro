# On part d'une image qui CONTIENT DÉJÀ Audiveris et Java
FROM audiveris/audiveris:latest

# On passe en root pour installer Python
USER root

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-fra \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installation de tes dépendances Python
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# Création des dossiers de travail
RUN mkdir -p temp_music output_music && chmod -R 777 /app

# L'exécutable 'audiveris' est déjà configuré dans cette image
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
