from flask import Flask, request, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return "Hello, DevOps!", 200

@app.post("/echo")
def echo():
    data = request.get_json()
    return jsonify({"received": data}), 200

@app.get("/health")
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
