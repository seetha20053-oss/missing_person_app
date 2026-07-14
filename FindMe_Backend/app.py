from flask import Flask, request, jsonify
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)

# -----------------------------
# Search Locations
# -----------------------------
@app.route("/search", methods=["GET"])
def search():

    query = request.args.get("q")

    if not query:
        return jsonify([])

    url = "https://nominatim.openstreetmap.org/search"

    params = {
        "q": query,
        "format": "json",
        "limit": 10,
        "countrycodes": "in"
    }

    headers = {
        "User-Agent": "FindMe App"
    }

    response = requests.get(
        url,
        params=params,
        headers=headers,
    )

    return jsonify(response.json())


# -----------------------------
# Reverse Geocoding
# GPS -> Address
# -----------------------------
@app.route("/reverse", methods=["GET"])
def reverse():

    lat = request.args.get("lat")
    lon = request.args.get("lon")

    if not lat or not lon:
        return jsonify({
            "error": "Latitude and Longitude required"
        }), 400

    url = "https://nominatim.openstreetmap.org/reverse"

    params = {
        "lat": lat,
        "lon": lon,
        "format": "json"
    }

    headers = {
        "User-Agent": "FindMe App"
    }

    response = requests.get(
        url,
        params=params,
        headers=headers,
    )

    return jsonify(response.json())


# -----------------------------
# Home
# -----------------------------
@app.route("/")
def home():
    return "FindMe Flask Server Running..."


# -----------------------------
# Run
# -----------------------------
if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True,
    )