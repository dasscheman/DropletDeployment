## Droplet Deployment
Use Ubuntu LTS version.
`curl -sL https://github.com/thedevdojo/larasail/archive/master.tar.gz | tar xz && source larasail-master/install`
`git clone https://github.com/dasscheman/DropletDeployment.git /home/larasail/DropletDeployment`
`sudo apt-get install php-curl`
`larasail setup php83`
`./init.sh`

`larasail host ${url} /var/www/${folder}`

Check de .env file and run:
`./deploy.sh`


larasail host test.montessorizeist.nl /var/www/test_montessorizeist_nl
larasail database init --user test_montessorizeist_nl --db test_montessorizeist_nl --force
Check de .env file and run:
./deploy.sh

https://www.digitalocean.com/community/questions/how-to-enable-ssh-access-for-non-root-users