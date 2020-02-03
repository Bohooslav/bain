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
- at the point you can open VS Code with `code .` or with other editor

### If you run into a problem (and I`m sure) that does mean you miss PostgreSQL or pip or python3.7 or even git

- the next step is to go to `./bolls/static/bolls/` to install imba dependencies

```bash
cd bolls/static/bolls/
npm install
```

#### Checklist

- search
- parallel
- bookmarks
- sw
- mapofsite
- collectstatic
- deploy

```bash
cd ~/bain && python3 manage.py collectstatic && gcloud app deploy
```
