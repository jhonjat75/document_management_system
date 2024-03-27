# Usa la imagen oficial de Ruby
FROM ruby:3.0.4

# Instalar dependencias del sistema
RUN apt-get update -qq && \
    apt-get install -y apt-utils curl gnupg build-essential && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs postgresql-client python3 python3-pip python3-setuptools && \
    npm install -g yarn

# Crear y establecer el directorio de trabajo
WORKDIR /myapp

# Configurar variables de entorno para bundler
ENV BUNDLE_PATH=/gems
ENV BUNDLE_BIN=/gems/bin
ENV GEM_HOME=/gems
ENV PATH $GEM_HOME/bin:$BUNDLE_BIN:$PATH

# Copiar los archivos de Gemfile y Gemfile.lock
COPY Gemfile Gemfile.lock /myapp/

# Instalar las gemas necesarias
RUN bundle install

# Copiar el resto del código de la aplicación
COPY . /myapp

RUN yarn install

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Precompilar los assets para producción
RUN RAILS_ENV=production bundle exec rails assets:precompile

# Eliminar el archivo pid del servidor si existe
RUN rm -f tmp/pids/server.pid

# Exponer el puerto de la aplicación
EXPOSE 3000

# Comando por defecto para ejecutar el servidor
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
