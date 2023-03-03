import { render, screen } from '@testing-library/react';
import React from 'react';

import App from '../../App';

const movieHeading = process.env.FAIL_TEST ? 'WRONG_HEADING' : 'Movie List';

test('renders Movie List heading', () => {
  render(<App />);
  const linkElement = screen.getByText(movieHeading);
  expect(linkElement).toBeInTheDocument();
});
