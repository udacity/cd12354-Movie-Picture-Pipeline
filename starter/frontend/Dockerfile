FROM  public.ecr.aws/docker/library/node:18.14.2-alpine3.17

ARG REACT_APP_MOVIE_API_URL
ENV REACT_APP_MOVIE_API_URL=${REACT_APP_MOVIE_API_URL}

WORKDIR /app

RUN mkdir -p public
RUN mkdir -p src
# Copy dependdency files
COPY package*.json .
COPY public/ /app/
COPY src/ /app/
#COPY public /app/public/
#COPY src /app/src/
COPY src/ /app/src/
COPY public/ /app/public/
RUN ls -lrt /app/public
# Install packages
RUN npm ci



# Build the app
RUN npm run build

# Expose the port used by the React app
EXPOSE 3000

# Start the React app when the container starts
CMD ["npm", "run", "serve"]