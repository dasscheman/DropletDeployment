#!/bin/bash

repos=("https://github.com/dasscheman/OV-Montessori.git" "https://github.com/dasscheman/BisonBar.git")

IFS=$'\n'
PS3='Select Github repo, or 0 to exit: '

select repo in "${repos[@]}"; do
    if [[ $REPLY == "0" ]]; then
        echo 'Bye!' >&2
        exit
    elif [[ ! -z $repo ]]; then
	break
    fi
    echo 'Invalid choice, try again' >&2
done

echo $repo
read -p "Geef de url ($repo): " url

echo "Url: " $url
underscore="_"
folder=${url//./$underscore}

echo "Folder: " $folder

git clone $repo www/${folder}
cp www/${folder}/.env.example www/${folder}/.env

#nigthly cron
line="0 0 * * * php www/${folder}/artisan schedule:run"
crontab -u www-data -l; echo "$line"

echo "
Run the following commands for a complete new droplet:
  curl -sL https://github.com/thedevdojo/larasail/archive/master.tar.gz | tar xz && source larasail-master/install
  larasail su
  larasail setup"

echo "
Run the following command to install new site while in folder: ${folder}:
  larasail host ${url} /var/www/${folder}"


exit

git clone https://github.com/dasscheman/BisonBar.git bisonbar_biologenkantoor_nl

curl -sL https://github.com/thedevdojo/larasail/archive/master.tar.gz | tar xz && source larasail-master/install

larasail su
larasail setup


larasail host test.montessorizeist.nl /var/www/test_montessorizeist_nl  #--www-alias
larasail host bisonbar.biologenkantoor.nl /var/www/bisonbar_biologenkantoor_nl #--www-alias

## Montessori
cd /var/www/test_montessorizeist_nl
cp .env.example .env
larasail database init --user test_montessorizeist_nl --db test_montessorizeist_nl --force

composer install
npm install
npm run dev
php artisan key:generate
php artisan db:wipe
php artisan migrate

chown www-data /var/www/test_montessorizeist_nl/storage -R
chmod a+w -R /var/www/test_montessorizeist_nl/storage

0 0 * * * php /home/forge/ovsumatralaan.montessorizeist.nl/artisan payments:sendoverview

## BisonBar
cd /var/www/bisonbar_biologenkantoor_nl
cp .env.example .env
larasail database init --user bisonbar_biologenkantoor_nl --db bisonbar_biologenkantoor_nl --force

composer install
npm install
npm run build
php artisan key:generate
php artisan db:wipe
php artisan db:import
php artisan db:reset

chown www-data /var/www/bisonbar_biologenkantoor_nl/storage -R
chmod a+w -R /var/www/bisonbar_biologenkantoor_nl/storage

SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
