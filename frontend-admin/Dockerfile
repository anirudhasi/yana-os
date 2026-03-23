FROM node:20-alpine

WORKDIR /app

# Copy package file
COPY package.json ./

# Clean install - resolves ajv peer dependency conflicts
RUN npm install --legacy-peer-deps

# Copy source
COPY . .

EXPOSE 3000

ENV REACT_APP_API_URL=http://localhost:8000/api
ENV WDS_SOCKET_PORT=0
ENV CHOKIDAR_USEPOLLING=true

CMD ["npm", "start"]
