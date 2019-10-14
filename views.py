from flask import Blueprint, redirect, render_template
from flask_login import current_user, login_required, login_user

from __init__ import db, login_manager
from forms import LoginForm, RegistrationForm
from models import Users

view = Blueprint("view", __name__)


@login_manager.user_loader
def load_user(username):
    user = Users.query.filter_by(username=username).first()
    return user or current_user


@view.route("/", methods=["GET"])
def render_dummy_page():
    form = LoginForm()
    return render_template("student_login.html", form=form)


@view.route("/registration", methods=["GET", "POST"])
def render_registration_page():
    form = RegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        password = form.password.data
        query = "SELECT * FROM users WHERE username = '{}'".format(username)
        exists_user = db.session.execute(query).fetchone()
        if exists_user:
            form.username.errors.append(
                "{} is already in use.".format(username))
        else:
            query = "INSERT INTO users(username, password) VALUES ('{}', '{}')"\
                .format(username, password)
            db.session.execute(query)
            db.session.commit()
            return "You have successfully signed up!"
    return render_template("registration-simple.html", form=form)


@view.route("/login", methods=["GET", "POST"])
def render_student_login_page():
    form = LoginForm()
    if form.is_submitted():
        print("username entered:", form.username.data)
        print("password entered:", form.password.data)
    if form.validate_on_submit():
        user = Users.query.filter_by(username=form.username.data).first()
        if user:
            records = Users.query.filter_by(
                username=form.username.data, password=form.password.data).first()
            if records:
                login_user(user)
                return redirect("/student_panel")
    return render_template("student_login.html", form=form)


@view.route("/manage", methods=["GET", "POST"])
def render_admin_login_page():
    form = LoginForm()
    if form.is_submitted():
        print("username entered:", form.username.data)
        print("password entered:", form.password.data)
    if form.validate_on_submit():
        user = Users.query.filter_by(username=form.username.data).first()
        if user:
            records = Users.query.filter_by(
                username=form.username.data, password=form.password.data).first()
            if records:
                login_user(user)
                return redirect("/admin_panel")
    return render_template("admin_login.html", form=form)


@view.route("/privileged-page", methods=["GET"])
@login_required
def render_privileged_page():
    return "<h1>Hello, {}!</h1>".format(current_user.username)
