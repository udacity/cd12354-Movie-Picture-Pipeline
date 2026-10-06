import { render, screen } from '@testing-library/react';
import React from 'react';
import axios from 'axios';

import App from '../../App';

jest.mock('axios');

const movieHeading = process.env.FAIL_TEST === 'true' ? 'WRONG_HEADING' : 'Movie List';

test('renders Movie List heading', () => {
  axios.get.mockResolvedValueOnce({ data: { movies: [] } });
  render(<App />);
  const linkElement = screen.getByText(movieHeading);
  expect(linkElement).toBeInTheDocument();
});
