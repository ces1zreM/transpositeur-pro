from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response, JSONResponse
import shutil
import os
import subprocess
import glob
from music21 import converter, interval, clef as music21_clef

app = FastAPI()

# Autorise tout le monde (dont ton React) à appeler le serveur
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "./temp_music"
OUTPUT_DIR = "./output_music"
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

# --- DISPOSITIF 1 : TRANSPOSITION ---
@app.post("/transpose")
async def transpose_file(
        file: UploadFile = File(...),
        semitones: int = Form(...),
        clef: str = Form(...)
):
    file_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        score = converter.parse(file_path)
        if semitones != 0:
            score = score.transpose(interval.Interval(semitones))

        if clef != "auto":
            for part in score.getElementsByClass('Part'):
                for measure in part.getElementsByClass('Measure'):
                    existing_clefs = measure.getElementsByClass(music21_clef.Clef)
                    
                    if clef == "Treble": new_clef = music21_clef.TrebleClef()
                    elif clef == "Bass": new_clef = music21_clef.BassClef()
                    elif clef == "Soprano": new_clef = music21_clef.SopranoClef()
                    elif clef == "Alto": new_clef = music21_clef.AltoClef()
                    elif clef == "Tenor": new_clef = music21_clef.TenorClef()

                    if existing_clefs:
                        measure.replace(existing_clefs[0], new_clef)
                    elif measure.number in [0, 1]:
                        measure.insert(0, new_clef)

        xml_data = score.write('musicxml')
        with open(xml_data, 'r', encoding='utf-8') as f:
            xml_content = f.read()
        return Response(content=xml_content, media_type="application/xml")
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

# --- DISPOSITIF 2 : CONVERSION PDF ---
@app.post("/convert-pdf")
async def convert_pdf_to_mxl(file: UploadFile = File(...)):
    if not file.filename.lower().endswith('.pdf'):
        return JSONResponse(status_code=400, content={"error": "Le fichier doit être un PDF."})

    pdf_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(pdf_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        output_name = file.filename.rsplit('.', 1)[0]
        
        # CHANGEMENT 1 : Chemin Linux pour le serveur
        audiveris_bin = "/opt/audiveris/bin/audiveris"

        # CHANGEMENT 2 : Mode "sans écran" pour éviter le crash Java
        env = os.environ.copy()
        env["JAVA_OPTS"] = "-Djava.awt.headless=true"

        result = subprocess.run(
            [audiveris_bin, "-batch", "-transcribe", "-export", "-output", OUTPUT_DIR, pdf_path],
            capture_output=True,
            text=True,
            env=env
        )

        fichiers_trouves = glob.glob(os.path.join(OUTPUT_DIR, f"{output_name}*.*"))
        fichier_cible = next((f for f in fichiers_trouves if f.lower().endswith(('.mxl', '.musicxml'))), None)

        if fichier_cible and os.path.exists(fichier_cible):
            score = converter.parse(fichier_cible)
            xml_data = score.write('musicxml')
            with open(xml_data, 'r', encoding='utf-8') as f:
                xml_content = f.read()
            return Response(content=xml_content, media_type="application/xml")
        else:
            return JSONResponse(status_code=500, content={"error": "Aucun fichier extrait", "details": result.stderr})

    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

# --- LANCEMENT ---
if __name__ == "__main__":
    import uvicorn
    # CHANGEMENT 3 : Le port est dynamique sur Render
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
