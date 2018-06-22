FROM ruby:2.5.1-alpine

COPY kubefigs.rb .

CMD ./kubefigs.rb $SRC $VARS
