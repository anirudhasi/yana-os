FROM node:20-alpine

WORKDIR /app

COPY package.json ./

# Install with legacy peer deps to bypass ajv conflict
# Then manually install the correct ajv version on top
RUN npm install --legacy-peer-deps && \
    npm install ajv@^8.17.1 ajv-keywords@^5.1.0 --legacy-peer-deps

COPY . .

EXPOSE 3000

ENV REACT_APP_API_URL=http://localhost:8000/api
ENV WDS_SOCKET_PORT=0
ENV CHOKIDAR_USEPOLLING=true
ENV GENERATE_SOURCEMAP=false

CMD ["npm", "start"]
