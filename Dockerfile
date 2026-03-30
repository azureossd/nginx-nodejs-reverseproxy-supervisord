FROM nginx:1.29.7

# Copy over site specific configuration
COPY /nginx/default.conf /etc/nginx/conf.d/default.conf
# Copy over general core configuration
COPY /nginx/nginx.conf /etc/nginx/nginx.conf
# Remove the index.html under NGINXs default content directory
RUN rm /usr/share/nginx/html/index.html

# Install node.js within the NGINX image
ENV NODE_VERSION=16.13.0
RUN apt-get update -yy && \
    apt-get upgrade -yy&& \
    apt-get install -yy curl && \
    apt-get install -yy supervisor
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

# Copy supervisord conf
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Change to the default NGINX content directory
WORKDIR /usr/share/nginx/html

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8090

ENTRYPOINT [ "/usr/share/nginx/html/init_container.sh" ]
