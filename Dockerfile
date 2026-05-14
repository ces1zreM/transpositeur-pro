FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Installation des dépendances + wget pour télécharger Audiveris
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

# TELECHARGEMENT DIRECT D'AUDIVERIS
RUN wget https://github.com/Audiveris/audiveris/releases/download/v5.3/audiveris_5.3_amd64.deb -O installer.deb \
    && dpkg -x installer.deb / \
    && rm installer.deb

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p temp_music output_music && chmod -R 777 /app

CMD uvicorn main:app --host 0.0.0.0 --port $PORT
