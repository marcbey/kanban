ARG EX_VSN=1.18.4
ARG OTP_VSN=27.3.4.1
ARG DEB_VSN=noble-20250619
ARG BUILDER_IMG="hexpm/elixir:${EX_VSN}-erlang-${OTP_VSN}-ubuntu-${DEB_VSN}"
ARG RUNNER_IMG="ubuntu:${DEB_VSN}"

############# builder #############

FROM ${BUILDER_IMG} AS builder

WORKDIR /app

ENV MIX_ENV="prod"

# Install dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config

# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

# Compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/
COPY rel rel
RUN mix release

############# runner #############

FROM ${RUNNER_IMG} AS runner

# Install the OS dependencies that we need to
RUN apt-get update -y && \
    apt-get install -y \
    libstdc++6 \
    openssl \
    libncurses6 \
    locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

WORKDIR "/app"

RUN chown nobody /app

# Set the runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/kanban ./

USER nobody

CMD ["/app/bin/server"]
