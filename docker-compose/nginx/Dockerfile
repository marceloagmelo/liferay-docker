# docker build -t pocdxp/nginx .
FROM nginx:1.16.1

RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/
COPY liferay.conf /etc/nginx/conf.d/