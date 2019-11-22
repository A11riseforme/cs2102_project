# ShadowModreg Module Registration App

## How to run

1. Install [python3](https://www.python.org/downloads/) and [postgresql 12](https://www.postgresql.org/download/)

2. run the following commands in command line:

   1. `cd path_to_source_code`

   2. `py -3 -m pip install -r requirements.txt` or `python3 -m pip install -r requirements.txt`

   3. `psql -d postgres -U postgres -f db.sql`

   followed by entering your password
3. configure the credential in app.py:

   ```
   # Config
   app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://{username}:{password}@{host}:{port}/{database}'\
       .format(
           username='<username>',
           password='<password>',
           host='localhost',
           port=<port number>,
           database='<database_name>'
       )
   ```

   replace `<username>`, `<password>`,  `<port>` , and `<database>` with the actual configuration from your database. If you are not sure about `<port>` and don't recall changing such a value during initial setup or launching of PostgreSQL server, then it should be `5432` by default. 

4. Run `py -m 3 app.py` or `python3 app.py`

5. Navigate to `http://127.0.0.1:5000/` in your browser to check if flask is active.

## Usage
The application comes preloaded with an admin account with the following credentials

username: admin
password: password1

and student account with the following credentials:

username: user

password: password

## Testing functions

You need to populate the data from the following sql files in order to test the corresponding features in their respective rounds:

- student_lecture_bidding_round1.sql : student registration, password resetting, lecture bidding in round 1
- student_lecture_bidding_round2.sql : lecture bidding in round2 for students in round 2
- student_tutorial_balloting_round3.sql : tutorial balloting in round3 for students in round 3
- admin_update_bidding_result.sql : update bidding results for admin after round 1
- admin_update_balloting_result.sql : update balloting result for admin after round 2



This project was rushed in a few days, for demonstration purpose only, don't read or learn from the coding style. ~~And I won't be responsible for the permanent brain damage caused.~~ 