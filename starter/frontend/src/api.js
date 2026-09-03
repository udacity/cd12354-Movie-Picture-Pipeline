const configuredApiUrl = process.env.REACT_APP_MOVIE_API_URL || '';

export const movieApiUrl = configuredApiUrl
  .replace(/^\uFEFF/, '')
  .trim()
  .replace(/\/+$/, '')
  .replace(/\/movies$/, '');
