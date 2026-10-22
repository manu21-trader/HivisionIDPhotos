FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    OMP_NUM_THREADS=1 \
    OPENBLAS_NUM_THREADS=1 \
    MKL_NUM_THREADS=1 \
    MALLOC_ARENA_MAX=2

WORKDIR /app

COPY requirements.txt ./

# mtcnn-runtime declares the desktop OpenCV package. The API only uses CPU
# image operations, so install it without dependencies and use headless OpenCV
# from requirements.txt to avoid GUI system libraries in the Railway image.
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir --no-deps mtcnn-runtime==1.0.0

COPY . .

# Railway API test: keep the upstream algorithm and download only the official
# MODNet portrait-matting weight during the image build. No request-time model
# download or Gradio process is required.
RUN python3 scripts/download_model.py --models modnet_photographic_portrait_matting \
    && test -s hivision/creator/weights/modnet_photographic_portrait_matting.onnx

EXPOSE 8080

CMD ["python3", "-u", "deploy_api.py"]
