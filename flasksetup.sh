# #!/bin/bash

# # Exit immediately if a command exits with a non-zero status
# set -e

# echo "==== Starting Flask + MongoDB Project Setup ===="

# # 1. Check environment variables
# if [ -z "$MONGO_USER" ] || [ -z "$MONGO_PASS" ]; then
#   echo "Please set environment variables MONGO_USER and MONGO_PASS first."
#   echo "Example:"
#   echo "export MONGO_USER='your_username'"
#   echo "export MONGO_PASS='your_password'"
#   exit 1
# fi

# # 2. Create project folder
# PROJECT_NAME="backend"
# mkdir -p "$PROJECT_NAME/db"
# cd "$PROJECT_NAME"

# echo "Project directory created: $PROJECT_NAME"

# # 3. Create virtual environment
# python3 -m venv venv
# echo "Virtual environment created."

# # Activate virtual environment
# source venv/bin/activate

# # 4. Upgrade pip
# pip install --upgrade pip

# # 5. Install required packages
# pip install Flask==2.3.3 \
#             Flask-Cors==3.0.10 \
#             Flask-JWT-Extended==4.7.0 \
#             pymongo==4.14.1 \
#             python-dotenv==1.0.1 \
#             email-validator==2.1.1 \
#             Werkzeug==2.3.7 \
#             Flask-Bcrypt==1.0.1

# echo "All packages installed."

# # 6. Create requirements.txt
# pip freeze > requirements.txt
# echo "requirements.txt generated."

# # 7. Create config.py with dev/prod SSL toggle
# cat <<EOL > config.py
# import os
# import urllib.parse

# ENV = os.environ.get("ENV", "development")  # "production" in production

# DB_USERNAME = os.environ.get("MONGO_USER")
# DB_PASSWORD = urllib.parse.quote_plus(os.environ.get("MONGO_PASS"))
# DB_NAME = "test"

# MONGO_URI = f"mongodb+srv://{DB_USERNAME}:{DB_PASSWORD}@cluster0.dlua3bq.mongodb.net/{DB_NAME}?retryWrites=true&w=majority"

# if ENV == "development":
#     CLIENT_OPTIONS = {"tls": True, "tlsAllowInvalidCertificates": True}
# else:
#     CLIENT_OPTIONS = {"tls": True}  # production: verify SSL certificates
# EOL

# # 8. Create db/__init__.py
# cat <<EOL > db/__init__.py
# from pymongo import MongoClient
# from config import MONGO_URI, CLIENT_OPTIONS

# client = MongoClient(MONGO_URI, **CLIENT_OPTIONS)
# db = client.get_database()  # Gets the database specified in MONGO_URI
# EOL

# # 9. Create db/models.py
# cat <<EOL > db/models.py
# from . import db

# users_collection = db["users"]

# def insert_user(user_data):
#     """Insert a new user document"""
#     return users_collection.insert_one(user_data).inserted_id

# def find_user_by_email(email):
#     """Find a user by email"""
#     return users_collection.find_one({"email": email})
# EOL

# # 10. Create app.py with basic endpoints
# cat <<'EOL' > app.py
# from flask import Flask, request, jsonify
# from flask_cors import CORS
# from flask_bcrypt import Bcrypt
# from db.models import insert_user, find_user_by_email

# app = Flask(__name__)
# CORS(app)
# bcrypt = Bcrypt(app)

# @app.route("/auth/register", methods=["POST"])
# def register():
#     data = request.json
#     if find_user_by_email(data["email"]):
#         return jsonify({"message": "User already exists"}), 400
#     hashed = bcrypt.generate_password_hash(data["password"]).decode("utf-8")
#     insert_user({"name": data["name"], "email": data["email"], "password": hashed})
#     return jsonify({"message": "User registered successfully"}), 201

# @app.route("/auth/login", methods=["POST"])
# def login():
#     data = request.json
#     user = find_user_by_email(data["email"])
#     if not user or not bcrypt.check_password_hash(user["password"], data["password"]):
#         return jsonify({"message": "Invalid email or password"}), 401
#     return jsonify({"message": "Login successful"}), 200

# if __name__ == "__main__":
#     print("Starting Flask server...")
#     app.run(debug=True)
# EOL

# # 11. Optional: create .env placeholder
# cat <<EOL > .env
# MONGO_USER=your_username
# MONGO_PASS=your_password
# ENV=development
# EOL

# echo "==== Setup Completed ===="
# echo "To start the server:"
# echo "1. cd $PROJECT_NAME"
# echo "2. source venv/bin/activate"
# echo "3. python app.py"

# source venv/bin/activate
# python app.py
#!/bin/bash
# Exit on error
set -e

echo "==== Setting up Flask + MongoDB Backend ===="

# 1. Check environment variables
if [ -z "$MONGO_USER" ] || [ -z "$MONGO_PASS" ]; then
  echo "Please set environment variables MONGO_USER and MONGO_PASS first."
  echo "Example:"
  echo "export MONGO_USER='your_username'"
  echo "export MONGO_PASS='your_password'"
  exit 1
fi

BACKEND_DIR="backend"
mkdir -p "$BACKEND_DIR/db"
cd "$BACKEND_DIR"

# 2. Create virtual environment
python3 -m venv venv
source venv/bin/activate

# 3. Install packages
pip install --upgrade pip
pip install Flask==2.3.3 \
            Flask-Cors==3.0.10 \
            Flask-JWT-Extended==4.7.0 \
            pymongo==4.14.1 \
            python-dotenv==1.0.1 \
            email-validator==2.1.1 \
            Werkzeug==2.3.7 \
            Flask-Bcrypt==1.0.1

# 4. Save requirements
pip freeze > requirements.txt

# 5. Create config.py
cat <<EOL > config.py
import os
import urllib.parse

ENV = os.environ.get("ENV", "development")
DB_USERNAME = os.environ.get("MONGO_USER")
DB_PASSWORD = urllib.parse.quote_plus(os.environ.get("MONGO_PASS"))
DB_NAME = "test"

MONGO_URI = f"mongodb+srv://{DB_USERNAME}:{DB_PASSWORD}@cluster0.dlua3bq.mongodb.net/{DB_NAME}?retryWrites=true&w=majority"

if ENV == "development":
    CLIENT_OPTIONS = {"tls": True, "tlsAllowInvalidCertificates": True}
else:
    CLIENT_OPTIONS = {"tls": True}
EOL

# 6. Create db/__init__.py
cat <<EOL > db/__init__.py
from pymongo import MongoClient
from config import MONGO_URI, CLIENT_OPTIONS

client = MongoClient(MONGO_URI, **CLIENT_OPTIONS)
db = client.get_database()
EOL

# 7. Create db/models.py
cat <<EOL > db/models.py
from . import db

users_collection = db["users"]

def insert_user(user_data):
    return users_collection.insert_one(user_data).inserted_id

def find_user_by_email(email):
    return users_collection.find_one({"email": email})
EOL

# 8. Create app.py with JWT
cat <<'EOL' > app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from db.models import insert_user, find_user_by_email

app = Flask(__name__)
CORS(app)
bcrypt = Bcrypt(app)

# JWT secret key
app.config["JWT_SECRET_KEY"] = "super-secret-key"
jwt = JWTManager(app)

@app.route("/auth/register", methods=["POST"])
def register():
    data = request.json
    if find_user_by_email(data["email"]):
        return jsonify({"message": "User already exists"}), 400
    hashed = bcrypt.generate_password_hash(data["password"]).decode("utf-8")
    insert_user({"name": data["name"], "email": data["email"], "password": hashed})
    return jsonify({"message": "User registered successfully"}), 201

@app.route("/auth/login", methods=["POST"])
def login():
    data = request.json
    user = find_user_by_email(data["email"])
    if not user or not bcrypt.check_password_hash(user["password"], data["password"]):
        return jsonify({"message": "Invalid email or password"}), 401
    token = create_access_token(identity=user["email"])
    return jsonify({"token": token}), 200

@app.route("/auth/me", methods=["GET"])
@jwt_required()
def me():
    email = get_jwt_identity()
    user = find_user_by_email(email)
    if not user:
        return jsonify({"message": "User not found"}), 404
    return jsonify({"name": user["name"], "email": user["email"]})

if __name__ == "__main__":
    print("Starting Flask server...")
    app.run(debug=True)
EOL

# 9. Optional .env placeholder
cat <<EOL > .env
MONGO_USER=your_username
MONGO_PASS=your_password
ENV=development
EOL

echo "==== Backend Setup Complete ===="
echo "Run:"
echo "cd backend && source venv/bin/activate && python app.py"
source venv/bin/activate
python app.py
