#!/bin/bash
echo "
Run the following commands for a complete new droplet:
  curl -sL https://github.com/thedevdojo/larasail/archive/master.tar.gz | tar xz && source larasail-master/install
  larasail su
  larasail setup"


# Function to display the confirmation prompt
function confirm() {
  while true; do
    read -p "Heb je bovenstaande commando's al eens gerund? (YES/NO/CANCEL) " yn
    case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        [Cc]* ) exit;;
        * ) echo "Please answer YES, NO, or CANCEL.";;
    esac
  done
}

if ! confirm; then
  echo "User chose NO. Aborting the operation..."
  exit
fi

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

git clone $repo ../www/${folder}
cp ../www/${folder}/.env.example www/${folder}/.env

#nigthly cron
line="0 0 * * * php /var/www/${folder}/artisan schedule:run"
(crontab -u www-data -l; echo "$line" ) | crontab -u www-data -

echo "Volgende cron is gezet:"
crontab -u www-data -l

externalip="curl https://ipinfo.io/ip"

echo "
Add a dns record in stato for: ${externalip} and ${url}:

Run the following command to install new site while in folder: ${folder}:
  larasail host ${url} /var/www/${folder}
  larasail database init --user ${folder} --db ${folder} --force"

exit

#SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
