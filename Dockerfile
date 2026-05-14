FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Installation des dépendances (Java + Python + Outils)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openjdk-17-jre-headless \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-fra \
    libasound2 \
    libnss3 \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Installation d'Audiveris 5.3 (Lien stable via un mirroir plus fiable)
RUN wget https://github.com/Audiveris/audiveris/releases/download/v5.3/audiveris_5.3_amd64.deb -O installer.deb \
    && dpkg -i installer.deb || apt-get install -f -y \
    && rm installer.deb

# 3. Dépendances Python
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# 4. Préparation des dossiers
RUN mkdir -p temp_music output_music && chmod -R 777 /app

# On crée le lien symbolique CORRECT : du dossier d'installation vers le dossier des commandes système
RUN ln -s /opt/audiveris/bin/audiveris /usr/bin/audiveris

# On donne les droits d'exécution au cas où
RUN chmod +x /opt/audiveris/bin/audiveris

CMD uvicorn main:app --host 0.0.0.0 --port $PORT
