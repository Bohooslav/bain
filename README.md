# bain

## Setting up the repo
 - clone the repo using git
```
git clone https://github.com/Bohooslav/bain.git
```
 - enter the directory
```
cd bain/
```
 - set up local enviroment
```
virtualenv env
source env/bin/activate
```
 - install reqirements using pip
```
pip install -r requirements.txt
``` 
 - run server
```
python manage.py runserver
```
 - and go to http://127.0.0.1:8000/
 - at the point you can open vs code or other editir `code .`
 
 ##### If you run into a problem (and I`m sure) that does mean you missing PostgreSQL or pip or python3.7 or even git
 
 - the next step is to go to `bolls/static/bolls/` to install imba dependencies
 ```
 cd bolls/static/bolls/
 npm install
 ```
 
 
