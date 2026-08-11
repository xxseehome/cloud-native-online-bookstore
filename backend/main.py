from fastapi import FastAPI, HTTPException

app = FastAPI(
    title="Cloud Native Online Book Store",
    version="1.0.0",
)

books = [
    {
        "id": 1,
        "title": "Kubernetes in Action",
        "author": "Marko Luksa",
        "price": 49.99,
    },
    {
        "id": 2,
        "title": "Terraform: Up & Running",
        "author": "Yevgeniy Brikman",
        "price": 39.99,
    },
    {
        "id": 3,
        "title": "Site Reliability Engineering",
        "author": "Google",
        "price": 44.99,
    },
]


@app.get("/health")
def health():
    return {"status": "healthy", "service": "bookstore-backend"}


@app.get("/api/books")
def get_books():
    return books


@app.get("/api/books/{book_id}")
def get_book(book_id: int):
    for book in books:
        if book["id"] == book_id:
            return book

    raise HTTPException(status_code=404, detail="Book not found")
