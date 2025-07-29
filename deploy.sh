#!/bin/bash

fatal() {
  echo "FATAL: $1" >&2
  exit 1
}

[ "$(whoami)" = "larasail" ] || fatal 'Please run this script as user larasail'

select site in /var/www/*/; do
    if [[ $REPLY == "0" ]]; then
        echo 'Bye!' >&2
        exit
    elif [[ ! -z $site ]]; then
	break
    fi
    echo 'Invalid choice, try again' >&2
done

cd $site || exit
# Install/update composer dependecies
composer install --no-interaction --prefer-dist --optimize-autoloader

php artisan down
php artisan key:generate
php artisan backup:run

default_branch="main"
read -p "Welke branch moet er uitgerold worden? (default $default_branch): " branch
branch="${branch:-$default_branch}"

echo "${branch}"

git checkout "${branch}"

git fetch --all
git reset --hard origin/"${branch}"

# Run database migrations
php artisan migrate --force

# Clear caches
php artisan cache:clear

# Clear expired password reset tokens
php artisan auth:clear-resets

# Clear and cache routes
php artisan route:cache

# Clear and cache config
php artisan config:cache

# Clear and cache views
php artisan view:cache

# Install node modules
npm install

# Build assets using Laravel Mix
npm run build

echo "Set permissions on ${site}storage"
sudo chown larasail:www-data -R  ${site}storage
sudo chown larasail:www-data -R  ${site}bootstrap/cache
chmod 775 -R ${site}storage
chmod 775 -R ${site}bootstrap/cache

npm install --omit=dev
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

#Calling the following 4 commands should fix most of the permission issues on laravel.
#
#sudo chown -R $USER:www-data storage
#sudo chown -R $USER:www-data bootstrap/cache
#chmod -R 775 storage
#chmod -R 775 bootstrap/cache

# Turn off maintenance mode
php artisan up
