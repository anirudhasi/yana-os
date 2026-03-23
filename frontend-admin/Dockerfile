FROM node:20-alpine

WORKDIR /app

# Copy package files first for better layer caching
COPY package.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy rest of source
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
