server {

    # Port that the web server will listen on.
    listen          80;

    client_max_body_size 29M;

    root /srv/www/ssl.example.com/laravel/public;
    index index.php index.html index.htm;

    server_name ssl.example.com;

    # Useful logs for debug.
    access_log      /srv/www/ssl.example.com/logs/access.log;
    error_log       /srv/www/ssl.example.com/logs/error.log;
    rewrite_log     on;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        try_files $uri /index.php =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}


server {

    # Port that the web server will listen on.
    listen          443;

    # SSL
    ssl on;
    ssl_certificate /srv/www/ssl.example.com/ssl/crt/someline_wildcard_cert_combined.crt;
    ssl_certificate_key /srv/www/ssl.example.com/ssl/private/private_key_no_passphrase.key;

    client_max_body_size 29M;

    root /srv/www/ssl.example.com/appletree/public;
    index index.php index.html index.htm;

    server_name ssl.example.com;

    # Useful logs for debug.
    access_log      /srv/www/ssl.example.com/logs/access.log;
    error_log       /srv/www/ssl.example.com/logs/error.log;
    rewrite_log     on;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
            include snippets/fastcgi-php.conf;

    #       # With php7.0-cgi alone:
    #       fastcgi_pass 127.0.0.1:9000;
    #       # With php7.0-fpm:
            fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    location ~ /\.ht {
            deny all;
    }

}
