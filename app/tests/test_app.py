from app import app

def test_home():
    client = app.test_client()
    res = client.get("/")
    assert res.status_code == 200
    assert b"Hello, DevOps!" in res.data

def test_echo():
    client = app.test_client()
    payload = {"msg": "hi"}
    res = client.post("/echo", json=payload)
    assert res.status_code == 200
    assert res.json["received"] == payload
