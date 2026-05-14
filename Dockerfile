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

# 2. Installation d'Audiveris 5.3
RUN wget https://github.com/Audiveris/audiveris/releases/download/v5.3/audiveris_5.3_amd64.deb -O installer.deb \
    && dpkg -i installer.deb || apt-get install -f -y \
    && rm installer.deb

# 3. Dépendances Python
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# 4. Préparation des dossiers (Indispensable)
RUN mkdir -p temp_music output_music && chmod -R 777 /app temp_music output_music

CMD uvicorn main:app --host 0.0.0.0 --port $PORT
