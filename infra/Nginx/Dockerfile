# Pull in the official nginx image.
FROM nginx

# Delete the default "welcome to nginx" page.
RUN rm /usr/share/nginx/html/*

# Copy over the dev config.
COPY templates/default.conf.template /etc/nginx/templates/default.conf.template

# Start nginx in the foreground to play nicely with Docker.
CMD ["nginx", "-g","daemon off;"]
