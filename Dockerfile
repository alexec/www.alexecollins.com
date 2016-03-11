FROM ruby:2.1.2

ADD Gemfile .

RUN bundler install

EXPOSE 4567

CMD ["bash", "-c", "cd site && middleman serve"]
