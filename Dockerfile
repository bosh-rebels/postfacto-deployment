FROM ruby:2.7.2
RUN gem install bundler:2.2.7 && \
  apt update && \
  apt install -y nodejs

RUN wget -O package.zip https://github.com/pivotal/postfacto/releases/download/4.3.11/package.zip && \
  unzip package.zip && \
  sed -i '/.*buildpack.*/d' package/tas/config/manifest.yml && \
  sed -i '/.*buildpack.*/d' package/cf/config/manifest.yml && \
  rm -f package.zip

WORKDIR /package/assets

RUN rm -rf Gemfile.lock && \
  sed -i "s/ruby '2.7.3'/ruby '2.7.2'/g" Gemfile && \
  bundle install && \
  bundle package --all-platforms

RUN ./bin/rails assets:precompile