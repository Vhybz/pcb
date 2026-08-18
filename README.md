# PCB Defect Detection Backend

This is a FastAPI server designed to run the YOLOv8 PCB Defect Detection model using ONNX Runtime.

## Project Structure
- `main.py`: The FastAPI application.
- `requirements.txt`: Python dependencies.
- `pcb_defect_model.onnx`: (You must place your model file here).

## Local Development
1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Run the server:
   ```bash
   python main.py
   ```
   The server will be available at `http://localhost:8000`.

## Deployment to Render
1. Create a new "Web Service" on Render.
2. Connect your GitHub repository.
3. Set the **Build Command**: `pip install -r backend/requirements.txt`
4. Set the **Start Command**: `python backend/main.py`
5. Ensure `pcb_defect_model.onnx` is tracked in your repository (or use LFS for large files).
6. Copy the generated URL and update it in `lib/main.dart` in your Flutter project.
