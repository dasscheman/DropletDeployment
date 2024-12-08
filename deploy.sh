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

php artisan backup:run

default_branch="main"
read -p "Welke branch moet er uitgerold worden? (default $default_branch): " branch
branch="${branch:-$default_branch}"

echo "${branch}"

git checkout "${branch}"
git pull

composer install
npm install
npm run build
php artisan migrate

# chown www-data ${site}storage -R
chmod a+w -R ${site}storage

