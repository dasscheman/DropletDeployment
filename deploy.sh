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
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

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

composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
# Install node modules
npm install

# Build assets using Laravel Mix
npm run prod

echo "Set permissions on ${site}storage"
chmod a+w -R ${site}storage
sudo chown larasail:www-data -R  ${site}storage

# Turn off maintenance mode
php artisan up
