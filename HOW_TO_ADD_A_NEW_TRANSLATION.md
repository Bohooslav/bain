# How to add a new translation to the project.

### Find it in appropriate format.

I prefer sqlite modules from MyBible app. I have a `myBible_concordance.sql` file where is code for converting MyBible modules into appropriate for me format. I download that modules from 'https://www.ph4.ru/b4_poisk.php?text=TLV&abbr=0'. Except of sqlite modules it may be also any database or csv or structured data but mid that you will need to convert it into csv format to insert it into my postgresql db.

### Format it.

I download selite module from there, run the code from `myBible_concordance.sql` and export the `verses` and `books` table to csv files. csv format is handy for working with data. Then I format the `verses.csv` table, I delete some unneded tags from there, convert some of that tags ...

Mind that the output will be interpreted as html. You may use there html tags like `<i></i>` or `<br.` &c to get the text neater. I would say also that you should use some text to make it looks better. Usually I get the text from MyBible modules and there are some patters. The `<J>` tags are ancapsulating <i>Jesus words</i>. I delete it. There are `<t>` tags. Delete them. But the closing `</t>` tags change to new line tag `</br>`. There are many tags that I simply delete with regex. But you may find a new use for them.

Also add before all a new collumn `translation` that should be filled with the abbreviation of the translation aka `YLT`, `KJV`, `UBIO` &c.

Also you need to format the books and make it a JavaScript array. Examples you may find in the `translations_books.json`. Be careful. Every book should have appropriate `bookid`, `chapters`, `chronorder` according to `name`. To make easier and more precise configuration of these fields I have created `related_to_adding_of_a_new_translation.js` file with code that may help to add appropriate fields to the appropriate book. Comments about that inside.

If you add a translation of a new language -- don't forget to set the translation a default for new users with that language default in their browser. Go to `state.imba` and see the switch inside of constructor.

### Add it to the app.

After formating the text and books you may add it to the app. First of all copy the verses to the database with the next command:

```sql
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/path_to_the_file/verses.csv' DELIMITER '|' CSV HEADER;
```

Also paste the books array with the abbreviation of the translation as a name. This abbreviation should be the same as the first collumn of the `translation` collumn in the database that is described above.

After that go to `[host:port]/get-translation/{abbreviation of the new translation}` and save the result to `translations` folder inside of `bolls/static/`. The saved filed should have thr translation abbreviation as its name and `.json` as extension. Example you may find in that folder. Otherwise the user will not be able to download it.

### Test it.

Check out if it works. If the books chapters are in a proper number, if there are no weird signs. Check out everything that you think should be verified. And if everything is right...

### Create pull request.

I will run it locally, test it, and if everything is workinig fine I will deploy it.
!NOTE. Attach to the pull request the csv files you were working with. I need them for my local db. It is not shipped with the project, because it is big.

### May Jehovah bless you.

### Release _(This is for myself)_

Copy the `TRANSLATION.csv` to production database before deploying the app to GAE.
