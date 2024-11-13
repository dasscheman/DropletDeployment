#!/usr/bin/env bash

select site in www/*/; do
    if [[ $REPLY == "0" ]]; then
        echo 'Bye!' >&2
        exit
    elif [[ ! -z $site ]]; then
	break
    fi
    echo 'Invalid choice, try again' >&2
done

cd $site || exit

php artisan key:generate
php artisan backup:run

composer install
npm install
npm run build

php artisan cache:clear
php artisan view:clear
php artisan key:generate
php artisan db:wipe
php artisan db:import
php artisan db:reset

chown www-data www/${site}/storage -R
chmod a+w -R www/${site}/storage
