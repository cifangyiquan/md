docker run -i -p 3000:80 -v /home/lingc/workspace/md/nginx/:/etc/nginx/conf.d -v /home/lingc/workspace/md/dist:/dist --network web_network  nginx
