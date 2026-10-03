import os
from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello_world():
    return "Hello from a configurable app!"


if __name__ == "__main__":
    # Read the port from the PORT environment variable.
    # Default to 5000 if it's not set.
    port = int(os.environ.get("PORT", 5000))
    # Run the app, listening on all interfaces
    app.run(host="0.0.0.0", port=port)
