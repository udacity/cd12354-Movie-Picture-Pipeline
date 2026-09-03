import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import axios from 'axios';
import { movieApiUrl } from '../api';

function MovieList({ onMovieClick }) {
  const [movies, setMovies] = useState([]);
  const [error, setError] = useState(false);

  useEffect(() => {
    axios
      .get(`${movieApiUrl}/movies`)
      .then((response) => setMovies(response.data.movies))
      .catch(() => setError(true));
  }, []);

  if (error) {
    return <p role="alert">Unable to load movies. Please try again later.</p>;
  }

  return (
    <ul>
      {movies.map((movie) => (
        <li className="movieItem" key={movie.id} onClick={() => onMovieClick(movie)}>
          {movie.title}
        </li>
      ))}
    </ul>
  );
}

MovieList.propTypes = {
  onMovieClick: PropTypes.func.isRequired,
};

export default MovieList;
