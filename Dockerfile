FROM ruby:2.1.5

RUN git clone  https://github.com/alexec/www.alexecollins.com.git

WORKDIR www.alexecollins.com

RUN bundler install

CMD ["middleman", "build"]
