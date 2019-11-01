from flask import Blueprint, redirect, render_template
from flask_login import current_user, login_required, login_user

from __init__ import db, login_manager
from forms import LoginForm, RegistrationForm, ResetForm
from models import Users

view = Blueprint("view", __name__)


@login_manager.user_loader
def load_user(username):
    user = Users.query.filter_by(username=username).first()
    return user or current_user


@view.route("/", methods=["GET"])
def render_dummy_page():
    return redirect("/login")


@view.route("/registration", methods=["GET", "POST"])
def render_registration_page():
    form = RegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        password = form.password.data
        matricID = form.matricID.data
        query = "SELECT * FROM studentsInfo WHERE matricID = '{}'".format(
            matricID)
        exists_students = db.session.execute(query).fetchone()
        if not exists_students:
            form.matricID.errors.append(
                "{} is not a valid matricID.".format(matricID))
        else:
            query = "SELECT * FROM users WHERE username = '{}'".format(
                username)
            exists_user = db.session.execute(query).fetchone()
            if exists_user:
                form.username.errors.append(
                    "{} is already in use.".format(username))
            else:
                query = "INSERT INTO users(username, password, isAdmin) VALUES ('{}', '{}', 0)"\
                    .format(username, password)
                db.session.execute(query)
                db.session.commit()
                return "<meta http-equiv=\"refresh\" content=\"5;url = /login\" />sign-up successful, you will be redirected to login page in five seconds!"
    return render_template("registration-simple.html", form=form)


@view.route("/reset", methods=["GET", "POST"])
def render_reset_page():
    form = ResetForm()
    if form.validate_on_submit():
        authCode = form.authCode.data
        password = form.password.data
        matricID = form.matricID.data
        
        query = "SELECT * FROM studentsInfo WHERE matricID = '{}'".format(
            matricID)
        exists_students = db.session.execute(query).fetchone()
        if not exists_students:
            form.matricID.errors.append(
                "{} is not a valid matricID.".format(matricID))
        else:
            if not authCode:
                query = "UPDATE students SET authCode = f_random_str(10) WHERE matricid = '{}'".format(matricID)
                print(query)
                db.session.execute(query)
                db.session.commit()
                form.authCode.errors.append("authCode has been sent to your email, please check.")
            else:
                query = "SELECT authcode FROM students WHERE matricID = '{}'".format(matricID)
                correct_authCode = db.session.execute(query).fetchone()[0]
                if authCode == correct_authCode:
                    query = "UPDATE users SET password = '{}' WHERE username = (SELECT username FROM students WHERE matricID = '{}')". format(password, matricID)
                    db.session.execute(query)
                    query = "UPDATE students SET authCode = f_random_str(10) WHERE matricid = '{}'".format(matricID)
                    db.session.execute(query)
                    db.session.commit()
                    return "<meta http-equiv=\"refresh\" content=\"5;url = /login\" />password-changing successful, you will be redirected to login page in five seconds!"
                else:
                    form.authCode.errors.append("authcode is invalid")
    return render_template("reset.html", form=form)


@view.route("/login", methods=["GET", "POST"])
def render_student_login_page():
    form = LoginForm()
    if form.is_submitted():
        print("username entered:", form.username.data)
        print("password entered:", form.password.data)
    if form.validate_on_submit():
        user = Users.query.filter_by(
            username=form.username.data, isAdmin=0).first()
        if user:
            records = Users.query.filter_by(
                username=form.username.data, password=form.password.data, isAdmin=0).first()
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
        user = Users.query.filter_by(
            username=form.username.data, isAdmin=1).first()
        if user:
            records = Users.query.filter_by(
                username=form.username.data, password=form.password.data, isAdmin=1).first()
            if records:
                login_user(user)
                return redirect("/admin_panel")
    return render_template("admin_login.html", form=form)


@view.route("/privileged-page", methods=["GET"])
@login_required
def render_privileged_page():
    return "<h1>Hello, {}!</h1>".format(current_user.username)


@view.route("/admin_panel", methods=["GET"])
@login_required
def render_admin_panel():
    user = Users.query.filter_by(
        username=current_user.username, isAdmin=1).first()
    if not user:
        return redirect("/student_panel")
    return render_template("admin_panel.html")


@view.route("/student_panel", methods=["GET"])
@login_required
def render_student_panel():
    user = Users.query.filter_by(
        username=current_user.username, isAdmin=0).first()
    if not user:
        return redirect("/admin_panel")
    return "<h1>Hello, {}!</h1>".format(current_user.username)
