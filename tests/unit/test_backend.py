from fastapi.testclient import TestClient

from backend.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200

    assert response.json()["status"] == "healthy"


def test_get_books():
    response = client.get("/api/books")

    assert response.status_code == 200

    assert len(response.json()) > 0


def test_get_book():
    response = client.get("/api/books/1")

    assert response.status_code == 200

    assert response.json()["id"] == 1
