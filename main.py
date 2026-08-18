import io
import numpy as np
from PIL import Image
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import onnxruntime as ort

app = FastAPI()

# Enable CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load ONNX model
# Place your pcb_defect_model.onnx in the same directory as main.py
MODEL_PATH = "pcb_defect_model.onnx"
session = ort.InferenceSession(MODEL_PATH)
input_name = session.get_inputs()[0].name

LABELS = ["mouse_bite", "spur", "missing_hole", "short", "open_circuit", "spurious_copper"]

@app.get("/")
async def root():
    return {"status": "online", "model": "YOLOv8-ONNX"}

@app.post("/detect")
async def detect(file: UploadFile = File(...)):
    # 1. Read and preprocess image
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")
    original_width, original_height = image.size

    # Resize to 416x416 (matching model input)
    img_resized = image.resize((416, 416))
    img_array = np.array(img_resized).astype(np.float32) / 255.0

    # HWC to NCHW: [1, 3, 416, 416]
    img_array = np.transpose(img_array, (2, 0, 1))
    img_array = np.expand_dims(img_array, axis=0)

    # 2. Run Inference
    outputs = session.run(None, {input_name: img_array})
    # Output shape: [1, 10, 3549]
    output = outputs[0][0] # [10, 3549]

    # 3. Post-process (filtering & NMS simplified for brevity)
    detections = []
    conf_threshold = 0.4

    for i in range(3549):
        # Index 4-9 are class scores
        classes_scores = output[4:, i]
        class_id = np.argmax(classes_scores)
        score = classes_scores[class_id]

        if score > conf_threshold:
            # cx, cy, w, h are indices 0, 1, 2, 3
            cx, cy, w, h = output[0:4, i]

            # Convert to normalized coordinates [0, 1]
            # Since model input is 416x416
            x1 = (cx - w/2) / 416
            y1 = (cy - h/2) / 416
            bw = w / 416
            bh = h / 416

            detections.append({
                "class_name": LABELS[class_id],
                "confidence": float(score),
                "bbox": [float(x1), float(y1), float(bw), float(bh)]
            })

    # Apply simplified NMS (optional on server, but good practice)
    # For now, return all filtered detections
    return {"detections": detections}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
