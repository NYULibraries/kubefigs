FROM ruby:2.4.1

COPY kubefigs.rb .

CMD ./kubefigs.rb $SRC $VARS
