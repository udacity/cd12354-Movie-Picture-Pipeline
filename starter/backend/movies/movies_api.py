from flask import Blueprint
from .resources import Movies

movies_api = Blueprint("movies_api", __name__)
movies = Movies.as_view("movies")

movies_api.add_url_rule("/movies", strict_slashes=False, defaults={"movie_id": None}, view_func=movies, methods=["GET"])
movies_api.add_url_rule("/movies", view_func=movies, methods=["POST"])
movies_api.add_url_rule("/movies/<int:movie_id>", view_func=movies, methods=["GET", "PUT", "DELETE"])
