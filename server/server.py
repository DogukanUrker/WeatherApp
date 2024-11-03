from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
import requests
from datetime import datetime

load_dotenv()
app = Flask(__name__)
API_KEY = os.getenv("API_KEY")

CORS(app)


ICON_MAPPING = {
    "Sunny": "sunny",
    "Clear": "clear",
    "Partly cloudy": "cloud",
    "Cloudy": "cloud",
    "Overcast": "cloud",
    "Mist": "cloud",
    "Patchy rain possible": "rain",
    "Patchy snow possible": "snow",
    "Patchy sleet possible": "snow",
    "Patchy freezing drizzle possible": "snow",
    "Thundery outbreaks possible": "thunderstorm",
    "Blowing snow": "snow",
    "Blizzard": "snow",
    "Fog": "cloud",
    "Freezing fog": "cloud",
    "Patchy light drizzle": "rain",
    "Light drizzle": "rain",
    "Freezing drizzle": "rain",
    "Heavy freezing drizzle": "rain",
    "Patchy light rain": "rain",
    "Light rain": "rain",
    "Moderate rain at times": "rain",
    "Moderate rain": "rain",
    "Heavy rain at times": "rain",
    "Heavy rain": "rain",
    "Light freezing rain": "rain",
    "Moderate or heavy freezing rain": "rain",
    "Light sleet": "snow",
    "Moderate or heavy sleet": "snow",
    "Patchy light snow": "snow",
    "Light snow": "snow",
    "Patchy moderate snow": "snow",
    "Moderate snow": "snow",
    "Patchy heavy snow": "snow",
    "Heavy snow": "snow",
    "Ice pellets": "snow",
    "Light rain shower": "rain",
    "Moderate or heavy rain shower": "rain",
    "Torrential rain shower": "rain",
    "Light sleet showers": "snow",
    "Moderate or heavy sleet showers": "snow",
    "Light snow showers": "snow",
    "Moderate or heavy snow showers": "snow",
    "Light showers of ice pellets": "snow",
    "Moderate or heavy showers of ice pellets": "snow",
    "Patchy light rain with thunder": "thunderstorm",
    "Moderate or heavy rain with thunder": "thunderstorm",
    "Patchy light snow with thunder": "thunderstorm",
    "Moderate or heavy snow with thunder": "thunderstorm",
}


@app.route("/")
def api():
    return jsonify({"status": "OK"})


@app.route("/get/<location>")
def get(location):
    url = f"http://api.weatherapi.com/v1/current.json?key={API_KEY}&q={location}"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        temp = round(data["current"]["temp_c"])
        condition = data["current"]["condition"]["text"]
        name = data["location"]["name"]
        isDay = data["current"]["is_day"] == 1
        date = datetime.strptime(
            data["location"]["localtime"], "%Y-%m-%d %H:%M"
        ).strftime("%B %-d, %Y")

        icon_shortname = ICON_MAPPING.get(condition, "cloud")
        icon = f"{icon_shortname}{'Day' if isDay else 'Night'}"

        return jsonify(
            {
                "name": name,
                "isDay": isDay,
                "temp": temp,
                "condition": condition,
                "date": date,
                "icon": icon,
            }
        )
    else:
        return (
            jsonify({"location": location, "error": "Failed to fetch data"}),
            response.status_code,
        )


@app.route("/icons/<icon>")
def icons(icon):
    return app.send_static_file(f"icons/{icon}.png")


if __name__ == "__main__":
    app.run(debug=True)
