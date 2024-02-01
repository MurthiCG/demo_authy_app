# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version 
  3.2.2

* Rails version
  7.1.2

* Postgres Setup

We need to create a database user and set a password for the user.

1. [Generate](https://passwordsgenerator.net/) a 24 character alphanumeric password.
  _Note_: Using symbols would make the password more secure, but can cause escaping issues
  when used on the command line. To avoid this, we'll stick with numbers and letters but
  use a very long password for our database user.
2. Ensure Postgres is running `sudo service postgresql start`
3. Create a new database user `sudo -u postgres createuser -s demo_authy_app`
4. Open the Postgres console `sudo -u postgres psql \password demo_authy_app`
5. At the prompt, paste the password generated in step 1
6. Exit the postgres console `\q`

* Project Setup

1. Edit the `database.yml`, updating the values as necessary for your
  local environment including the Postgres password generated in the previous section.
4. Install dependencies
    ```
    gem install bundler
    bundle install
    ```
5. Create your database `bundle exec rake db:create db:migrate`
6. Seed the database `bundle exec rake db:seed`


* Application Startup
1. From your project root `bundle exec rails s`

_Note_: If your computer has recently been rebooted, you will first need to start your
services.
* `sudo service postgresql start`
* `sudo service redis-server start`

* Test Cases 
1) RSPEC is used for unit testing. run rspec by "bundle exec rspec"

* Controllers Used
1) api/registrations:
  a) Handles user create/registration to the application.
  b) Confirm user after registration.

2) api/users:
  a) Handles sign_in api request and response.
  b) verify_token api to authenticate via OTP.
  c) change_password api to change the password from account settings.
  d) update api to update user's name, disbale/enable mfa.


* Model
1) users table represents User Model and has information related to user.