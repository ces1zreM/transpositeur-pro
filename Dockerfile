FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. Dépendances système
RUN apt-get update && apt-get install -y \
    python3 python3-pip openjdk-17-jre-headless \
    poppler-utils tesseract-ocr tesseract-ocr-fra \
    wget unzip libasound2 libnss3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Installation manuelle d'Audiveris (Version portable ZIP)
# C'est beaucoup plus fiable que le .deb
RUN wget https://github.com/Audiveris/audiveris/releases/download/v5.3/Audiveris-5.3.zip -O audiveris.zip \
    && unzip audiveris.zip \
    && mv Audiveris-5.3 audiveris_engine \
    && chmod +x /app/audiveris_engine/bin/audiveris \
    && rm audiveris.zip

# 3. Dépendances Python
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# 4. Dossiers de travail
RUN mkdir -p temp_music output_music && chmod -R 777 /app

# On crée un lien direct pour que la commande 'audiveris' existe
RUN ln -s /app/audiveris_engine/bin/audiveris /usr/bin/audiveris

CMD uvicorn main:app --host 0.0.0.0 --port $PORT
