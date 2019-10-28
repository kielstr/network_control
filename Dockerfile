FROM debian:buster

LABEL maintainer="kielstr@cpan.org";

# Install build tools and Perl
RUN apt-get update && apt-get install -y \
	gcc \
	g++ \
	make \
	perl \
	libperl-dev \
	curl \
	wget \
	bash \
	default-mysql-client \
	libdbd-mariadb-perl \
	sqitch\
	perl-doc

# Install cpan minus
RUN curl -L http://xrl.us/cpanm > /bin/cpanm && \
	chmod +x /bin/cpanm

RUN cpanm \
	MySQL::Config \
	DBIx::Class

COPY ./database /database

COPY ./.my.cnf /root/.my.cnf

COPY mysql.pm /usr/share/perl5/App/Sqitch/Engine/mysql.pm

COPY scripts/sqitch-db /usr/local/bin/sqitch-db

CMD ['bash']