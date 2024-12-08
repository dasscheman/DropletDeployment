#!/bin/bash
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

externalip=$(curl https://ipinfo.io/ip)

read -p "Geef de url ($repo): " url
echo "Url: " "$url"

echo -e "
Run the following commands for a complete new droplet:
  ${CYAN}curl -sL https://github.com/thedevdojo/larasail/archive/master.tar.gz | tar xz && source larasail-master/install${NC}
  ${PURPLE}larasail setup${NC}
  ${RED}Dit you add a dns record in stato for: ${externalip} and ${url}${NC}"

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
    elif [[ -n $repo ]]; then
	      break
    fi
    echo 'Invalid choice, try again' >&2
done

echo $repo

underscore="_"
folder=${url//./$underscore}

echo "Folder: " $folder

git clone $repo /var/www/${folder}
cp /var/www/${folder}/.env.example /var/www/${folder}/.env

#nigthly cron
line="0 0 * * * php /var/www/${folder}/artisan schedule:run"
(sudo crontab -u www-data -l; echo "$line" ) | sudo crontab -u www-data -

echo "Volgende cron is gezet:"
sudo crontab -u www-data -l

sudo chown larasail:larasail /var/www/"${folder}" -R

cd /var/www/"${folder}" || exit
echo -e "Run the following command to install new site while in folder: ${folder}:
  ${RED}larasail host ${url} /var/www/${folder}${NC}
  ${RED}larasail database init --user ${folder} --db ${folder} --force${NC}
  ${RED}./deploy.sh${NC}"
exit

#SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
