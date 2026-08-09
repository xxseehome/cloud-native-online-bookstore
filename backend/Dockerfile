FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt \
    && groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid 10001 --home-dir /app app

COPY --chown=app:app main.py .

USER 10001:10001

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"]

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
