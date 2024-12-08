## Droplet Deployment
Use Ubuntu LTS version.
`curl -sL https://github.com/thedevdojo/larasail/archive/master.tar.gz | tar xz && source larasail-master/install`
`git clone https://github.com/dasscheman/DropletDeployment.git /home/larasail/DropletDeployment`
`larasail setup`
`./init.sh`

`larasail host ${url} /var/www/${folder}`
`larasail database init --user ${folder} --db ${folder} --force`

Check de .env file and run:
`./deploy.sh`