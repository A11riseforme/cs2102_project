from flask import Blueprint, redirect, render_template
from flask_login import current_user, login_required, login_user, logout_user

from __init__ import db, login_manager
from forms import LoginForm, RegistrationForm, ResetForm, ChangePasswordForm, EditBidForm
from models import Users

view = Blueprint("view", __name__)


@login_manager.user_loader
def load_user(username):
    user = Users.query.filter_by(uname=username).first()
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
                query = "UPDATE students SET authCode = f_random_str(10) WHERE matricid = '{}'".format(
                    matricID)
                print(query)
                db.session.execute(query)
                db.session.commit()
                form.authCode.errors.append(
                    "authCode has been sent to your email, please check.")
            else:
                query = "SELECT authcode FROM students WHERE matricID = '{}'".format(
                    matricID)
                correct_authCode = db.session.execute(query).fetchone()[0]
                if authCode == correct_authCode:
                    query = "UPDATE users SET password = '{}' WHERE username = (SELECT username FROM students WHERE matricID = '{}')".format(
                        password, matricID)
                    db.session.execute(query)
                    query = "UPDATE students SET authCode = f_random_str(10) WHERE matricid = '{}'".format(
                        matricID)
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
        user = Users.query.filter_by(uname=form.username.data,
                                     isAdmin=0).first()
        if user:
            records = Users.query.filter_by(uname=form.username.data,
                                            password=form.password.data,
                                            isAdmin=0).first()
            print(records)
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
        user = Users.query.filter_by(uname=form.username.data,
                                     isAdmin=1).first()
        if user:
            records = Users.query.filter_by(uname=form.username.data,
                                            password=form.password.data,
                                            isAdmin=1).first()
            if records:
                login_user(user)
                return redirect("/admin_panel")
    return render_template("admin_login.html", form=form)


@view.route("/privileged-page", methods=["GET"])
@login_required
def render_privileged_page():
    return "<h1>Hello, {}!</h1>".format(current_user.uname)


@view.route("/admin_panel", methods=["GET"])
@login_required
def render_admin_panel():
    user = Users.query.filter_by(uname=current_user.uname, isAdmin=1).first()
    if not user:
        return redirect("/manage")
    real_name = current_user.uname
    query = "SELECT * FROM rounds WHERE CURRENT_DATE >= s_date and CURRENT_DATE <= e_date"
    current_round_data = db.session.execute(query).fetchone()
    query = "SELECT module_code FROM Courses WHERE admin = {}".format(
        real_name)
    module_codes = db.session.execute(query).fetchall()
    # print("module_codes:", module_codes)
    classes_data_by_modules = []
    for module in module_codes:
        # print("module: ", module[0])
        query = "SELECT * FROM Class WHERE module_code = '{}'".format(
            module[0])
        classes = db.session.execute(query).fetchall()
        if classes:
            classes_data_by_modules.append(classes)
    # for a in classes_data_by_modules:
    #     print(a)

    return render_template("admin_panel.html",
                           username=real_name,
                           round_no=current_round_data[0],
                           round_startTime=current_round_data[2],
                           round_endTime=current_round_data[3],
                           classes_data_by_modules=classes_data_by_modules)


@view.route("/admin_panel/profile/logout", methods=["GET"])
@login_required
def render_admin_logout():
    logout_user()
    return redirect("/manage")


@view.route("/admin_panel/profile/change_password", methods=["GET"])
@login_required
def render_admin_profile_my_courses():
    user = Users.query.filter_by(uname=current_user.uname, isAdmin=1).first()
    if not user:
        return redirect("/login")
    real_name = current_user.uname
    form = ChangePasswordForm()
    if form.validate_on_submit():
        old_password = form.oldPassword.data
        new_password = form.newPassword.data
        confirm_password = form.confirmPassword.data
        if new_password != confirm_password:
            form.confirmPassword.errors.append(
                "newPassword must be the same as the confirmPassword!")
        else:
            query = "SELECT password FROM users WHERE uname = '{}'".format(
                current_user.uname)
            password = db.session.execute(query).fetchone()[0]
            if password != old_password:
                form.oldPassword.errors.append("old password is incorrect!")
            else:
                query = "UPDATE users SET password = '{}' WHERE uname = '{}'".format(
                    new_password, current_user.uname)
                db.session.execute(query)
                db.session.commit()
                form.confirmPassword.errors.append("password updated!")
    return render_template("admin_profile_change_password.html",
                           username=real_name,
                           form=form)


@view.route("/admin_panel/update_rounds", methods=["GET", "POST"])
@login_required
def render_admin_update_rounds():
    user = Users.query.filter_by(uname=current_user.uname, isAdmin=1).first()
    if not user:
        return redirect("/manage")
    real_name = current_user.uname
    query = "SELECT * FROM rounds WHERE CURRENT_DATE >= s_date and CURRENT_DATE <= e_date"
    current_round_data = db.session.execute(query).fetchone()
    current_round = current_round_data[0]
    round_startTime = current_round_data[2]
    round_endTime = current_round_data[3]

    return render_template(
        "admin_update_rounds.html",
        username=real_name,
    )


@view.route("/student_panel", methods=["GET"])
@login_required
def render_student_panel():
    user = Users.query.filter_by(uname=current_user.uname, isAdmin=0).first()
    if not user:
        return redirect("/login")
    query = "SELECT rname FROM studentinfo WHERE matric_no = (SELECT matric_no FROM student WHERE uname = '{}')".format(
        current_user.uname)
    real_name = db.session.execute(query).fetchone()[0]
    query = "SELECT rid FROM rounds WHERE CURRENT_DATE >= s_date and CURRENT_DATE <= e_date"
    current_round = db.session.execute(query).fetchone()[0]
    query = "SELECT rname FROM studentinfo WHERE matric_no = (SELECT matric_no FROM student WHERE uname = '{}')".format(
        current_user.uname)
    real_name = db.session.execute(query).fetchone()[0]
    query = "SELECT b.module_code, b.bid_point, c.fname, b.cid  FROM bids AS b INNER JOIN courses AS c ON b.module_code = c.module_code WHERE b.uname = '{}' and b.rid = {};".format(
        current_user.uname, current_round)
    current_bids = db.session.execute(query).fetchall()
    print(current_bids)
    if current_round == 1 or current_round == 2:
        return render_template("student_panel.html",
                               username=real_name,
                               round_no=current_round,
                               bid_lecture=1,
                               current_bids=current_bids)
    elif current_round == 3:
        return render_template("student_panel.html",
                               username=real_name,
                               round_no=current_round,
                               bid_tutorial_labs=1,
                               current_bids=current_bids)
    else:
        return render_template("student_panel.html",
                               username=real_name,
                               round_no=current_round,
                               current_bids=current_bids)


@view.route("/student_panel/profile/change_password", methods=["GET", "POST"])
@login_required
def render_student_change_password():
    user = Users.query.filter_by(uname=current_user.uname, isAdmin=0).first()
    if not user:
        return redirect("/login")
    query = "SELECT rname FROM studentinfo WHERE matric_no = (SELECT matric_no FROM student WHERE uname = '{}')".format(
        current_user.uname)
    real_name = db.session.execute(query).fetchone()[0]
    form = ChangePasswordForm()
    if form.validate_on_submit():
        old_password = form.oldPassword.data
        new_password = form.newPassword.data
        confirm_password = form.confirmPassword.data
        if new_password != confirm_password:
            form.confirmPassword.errors.append(
                "newPassword must be the same as the confirmPassword!")
        else:
            query = "SELECT password FROM users WHERE uname = '{}'".format(
                current_user.uname)
            password = db.session.execute(query).fetchone()[0]
            if password != old_password:
                form.oldPassword.errors.append("old password is incorrect!")
            else:
                query = "UPDATE users SET password = '{}' WHERE uname = '{}'".format(
                    new_password, current_user.uname)
                db.session.execute(query)
                db.session.commit()
                form.confirmPassword.errors.append("password updated!")
    return render_template("student_profile_change_password.html",
                           username=real_name,
                           form=form)


@view.route("/student_panel/profile/logout", methods=["GET"])
@login_required
def render_student_logout():
    logout_user()
    return redirect("/login")


@view.route("/student_panel/profile/modules_taken", methods=["GET"])
@login_required
def render_student_modules_taken():
    user = Users.query.filter_by(uname=current_user.uname, isAdmin=0).first()
    if not user:
        return redirect("/login")
    query = "SELECT rname FROM studentinfo WHERE matric_no = (SELECT matric_no FROM student WHERE uname = '{}')".format(
        current_user.uname)
    real_name = db.session.execute(query).fetchone()[0]
    query = "SELECT c.module_code, c.fname, c.mc FROM taken AS t INNER JOIN courses AS c ON t.module_code = c.module_code WHERE t.uname = '{}'".format(
        current_user.uname)
    modules_taken = db.session.execute(query).fetchall()
    print(modules_taken)
    return render_template("student_profile_modules_taken.html",
                           username=real_name,
                           modules=modules_taken)


@view.route("/student_panel/results/<int:roundid>", methods=["GET"])
@view.route("/student_panel/results/", methods=["GET"])
@login_required
def render_student_result(roundid=None):
    user = Users.query.filter_by(uname=current_user.uname, isAdmin=0).first()
    if not user:
        return redirect("/login")
    query = "SELECT rname FROM studentinfo WHERE matric_no = (SELECT matric_no FROM student WHERE uname = '{}')".format(
        current_user.uname)
    real_name = db.session.execute(query).fetchone()[0]
    query = "SELECT rid FROM rounds WHERE CURRENT_DATE >= s_date and CURRENT_DATE <= e_date"
    current_round = db.session.execute(query).fetchone()[0]
    if current_round == roundid:

        return render_template("student_results.html",
                               username=real_name,
                               roundid=roundid,
                               error1=1)
    elif current_round < roundid:
        return render_template("student_results.html",
                               username=real_name,
                               roundid=roundid,
                               error2=1)
    else:
        query = "SELECT module_code, bid_point FROM bids WHERE uname = '{}' AND rid = {} AND is_successful = TRUE".format(
            current_user.uname, roundid)
        #print(query)
        modules_got = db.session.execute(query).fetchall()
        #print(modules_got)
        return render_template("student_results.html",
                               username=real_name,
                               roundid=roundid,
                               modules_got=modules_got)


@view.route("/student_panel/bid/edit/<string:module_code>/<int:cid>",
            methods=["GET", "POST"])
@view.route("/student_panel/bid/edit/", methods=["GET"])
@login_required
def render_student_bid_edit(module_code=None, cid=None):
    user = Users.query.filter_by(uname=current_user.uname, isAdmin=0).first()
    if not user:
        return redirect("/login")
    query = "SELECT rname FROM studentinfo WHERE matric_no = (SELECT matric_no FROM student WHERE uname = '{}')".format(
        current_user.uname)
    real_name = db.session.execute(query).fetchone()[0]
    query = "SELECT rid FROM rounds WHERE CURRENT_DATE >= s_date and CURRENT_DATE <= e_date"
    current_round = db.session.execute(query).fetchone()[0]
    if module_code and cid:
        print('asdfasdf')
        form = EditBidForm()
        return render_template("student_bid_edit.html",
                               username=real_name,
                               form=form)
    else:
        query = "SELECT b.module_code, b.bid_point, c.fname, b.cid  FROM bids AS b INNER JOIN courses AS c ON b.module_code = c.module_code WHERE b.uname = '{}' and b.rid = {};".format(
            current_user.uname, current_round)
        current_bids = db.session.execute(query).fetchall()
        return render_template("student_bid_edit.html",
                               username=real_name,
                               current_bids=current_bids,
                               module_not_specified=1)
