# bain

## Setting up the repo

- clone the repo using git

```bash
git clone https://github.com/Bohooslav/bain.git
```

- enter the directory

```bash
cd bain/
```

 at this point you can open VS Code with `code .` or open this folder in with any other text editor

- set up local enviroment

```bash
virtualenv env
source env/bin/activate
```

- install reqirements using pip

```bash
pip install -r requirements.txt
```

- run server

```bash
python manage.py runserver 0.0.0.0:8000
```

- and go to <http://127.0.0.1:8000/>
- check if everything is correct and you do not see any error. You will not see any book, cuz to do that you should have installed PostreSQL and download the translations from the datababase => <https://us-east-2.console.aws.amazon.com/rds/home?region=us-east-2#database:id=bollsdb;is-cluster=false>. Firstly, using pgAdmin or cmd, create a database `bain`, than run migrations:

```bash
python manage.py makemigrations
python manage.py migrate
```

 and insert the downloaded translation there. If you do not wanna set up local database you can use remote database, but be careful, do not make any tests or mutations on the production database. It is strongly recommended to use local copy, and do all your testing on it.

- the next step is to go to `./bolls/static/bolls/` to install imba dependencies

```bash
cd bolls/static/bolls/
npm install
```

- than watch the changes in files to compile them

```bash
npm run watch
```

### Checklist
- sw
- sitemap
- npm run build
- collectstatic
- deploy

```bash
cd ~/bain/bolls/static/bolls/ && npm run build && source ~/env/bin/activate && cd ~/bain && python manage.py collectstatic && cd ~/bain &&gcloud app deploy
```
