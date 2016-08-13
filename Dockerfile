FROM ruby:2.1.2

ADD Gemfile .

RUN bundle install

EXPOSE 4567

WORKDIR site

CMD ["middleman"]
