FROM ruby:2.1.2

WORKDIR site

ADD Gemfile .

RUN bundle install

EXPOSE 4567

CMD ["middleman"]
