# Extend from the official Elixir image
FROM elixir:latest
ENV REDIS_URL redis://159.203.159.138:2396

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex package manager
# By using --force, we don’t need to type “Y” to confirm the installation
RUN mix local.hex --force

# Compile the project
RUN mix do compile

ENTRYPOINT [ "mix","phx.server" ]
