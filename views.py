from flask import Blueprint, redirect, render_template, session, request
from flask_login import current_user, login_required, login_user, logout_user

from __init__ import db, login_manager
from forms import LoginForm, RegistrationForm, ResetForm, ChangePasswordForm, EditBidForm, AddBidForm, AddCourseForm, EditRoundForm, AddClassForm, AddClassForm, ConfirmBidResultForm, UpdateBidToSuccessfulForm
from models import Users, Student, Admin
from sqlalchemy import exc, text

from email.mime.text import MIMEText
from email.header import Header
from smtplib import SMTP_SSL

view = Blueprint("view", __name__)


def get_current_round():
    query = "SELECT rid FROM rounds WHERE current_timestamp >= s_date and current_timestamp <= e_date"
    current_round = db.session.execute(query).fetchone()
    if not current_round:
        query = "SELECT r1.rid+0.5 FROM rounds r1, rounds r2 WHERE CURRENT_TIMESTAMP <= r2.s_date AND CURRENT_TIMESTAMP >= r1.e_date LIMIT 1;"
        current_round = db.session.execute(query).fetchone()
        if not current_round:
            current_round = 0
        else:
            current_round = current_round[0]
    else:
        current_round = current_round[0]
    return current_round


def send_mail(email, authcode, matric_id):
    host_server = 'smtp.qq.com'
    sender_qq = '1075005528'
    pwd = 'pyhdqnsbiisvibdd'
    sender_qq_mail = '1075005528@qq.com'
    receiver = email
    mail_content = "please use the authcode %s and your matric_id %s to reset the password in the ShadowModreg" % (authcode, matric_id) 
    mail_title = 'your authcode for ShadowModreg'
    smtp = SMTP_SSL(host_server)
    smtp.set_debuglevel(1)
    smtp.ehlo(host_server)
    smtp.login(sender_qq, pwd)
    msg = MIMEText(mail_content, "plain", 'utf-8')
    msg["Subject"] = Header(mail_title, 'utf-8')
    msg["From"] = sender_qq_mail
    msg["To"] = receiver
    smtp.sendmail(sender_qq_mail, receiver, msg.as_string())
    smtp.quit()


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
        query = "SELECT * FROM studentInfo WHERE matric_no = '{}'".format(
            matricID)
        exists_students = db.session.execute(query).fetchone()
        if not exists_students:
            form.matricID.errors.append(
                "{} is not a valid matricID.".format(matricID))
        else:
            query = "SELECT * FROM users WHERE uname = '{}'".format(
                username)
            exists_user = db.session.execute(query).fetchone()
            if exists_user:
                form.username.errors.append(
                    "{} is already in use.".format(username))
            else:
                query = "INSERT INTO users(uname, password) VALUES ('{}', '{}')".format(
                    username, password)
                db.session.execute(query)
                db.session.commit()
                query = "INSERT INTO student VALUES ('{}', '{}', 1000)".format(
                    username, matricID)
                db.session.execute(query)
                db.session.commit()
                return "<meta http-equiv=\"refresh\" content=\"3;url = /login\" />sign-up successful, you will be redirected to login page in three seconds!"
    return render_template("registration-simple.html", form=form)


@view.route("/reset", methods=["GET", "POST"])
def render_reset_page():
    form = ResetForm()
    if form.validate_on_submit():
        authCode = form.authCode.data
        password = form.password.data
        matricID = form.matricID.data

        query = "SELECT * FROM student WHERE matric_no = '{}'".format(
            matricID)
        exists_students = db.session.execute(query).fetchone()
        if not exists_students:
            form.matricID.errors.append(
                "{} is not a valid matricID.".format(matricID))
        else:
            if not authCode:
                query = "UPDATE student SET authCode = f_random_str(10) WHERE matric_no = '{}'".format(
                    matricID)
                print(query)
                db.session.execute(query)
                db.session.commit()
                query = "SELECT authcode FROM student WHERE matric_no = '{}'".format(matricID)
                auth_code = db.session.execute(query).fetchone()[0]
                query = "SELECT nusnetid FROM studentinfo WHERE matric_no = '{}'".format(matricID)
                email = db.session.execute(query).fetchone()[0]+"@u.nus.edu"
                print(auth_code, email)
                send_mail(email, auth_code, matricID)
                form.authCode.errors.append(
                    "authCode has been sent to your email, please check.")
            else:
                query = "SELECT authcode FROM student WHERE matric_no = '{}'".format(
                    matricID)
                print(query)
                correct_authCode = db.session.execute(query).fetchone()[0]
                if authCode == correct_authCode:
                    query = "UPDATE users SET password = '{}' WHERE uname = (SELECT uname FROM student WHERE matric_no = '{}')".format(
                        password, matricID)
                    db.session.execute(query)
                    query = "UPDATE student SET authCode = f_random_str(10) WHERE matric_no = '{}'".format(
                        matricID)
                    db.session.execute(query)
                    db.session.commit()
                    return "<meta http-equiv=\"refresh\" content=\"3;url = /login\" />password-changing successful, you will be redirected to login page in three seconds!"
                else:
                    form.authCode.errors.append("authcode is invalid")
    return render_template("reset.html", form=form)



@view.route("/login", methods=["GET", "POST"])
def render_student_login_page():
    form = LoginForm()
    if form.validate_on_submit():

        user = Users.query.filter_by(
            uname=form.username.data, password=form.password.data).first()
        if user:
            is_student = Student.query.filter_by(
                uname=form.username.data).first()
            if is_student:
                session['is_admin'] = 0
                login_user(user)
                return redirect("/students_panel")
            else:
                session['is_admin'] = 1
                login_user(user)
                return redirect("/admin_panel")
    return render_template("student_login.html", form=form)


@view.route("/manage", methods=["GET", "POST"])
def render_admin_login_page():
    form = LoginForm()
    if form.validate_on_submit():
        user = Users.query.filter_by(
            uname=form.username.data, password=form.password.data).first()
        if user:
            is_admin = Admin.query.filter_by(
                uname=form.username.data).first()
            if is_admin:
                session['is_admin'] = 1
                login_user(user)
                return redirect("/admin_panel")
            else:
                session['is_admin'] = 0
                login_user(user)
                return redirect("/students_panel")
    return render_template("admin_login.html", form=form)


@view.route("/admin_panel", methods=["GET", "POST"])
@login_required
def render_admin_panel():
    user = Users.query.filter_by(uname=current_user.uname).first()
    if not user:
        return redirect("/login")
    
    real_name = current_user.uname
    # real_name = "Admin Temporary"
    current_round_no = get_current_round()
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
    for a in classes_data_by_modules:
        print(a)
        

    return render_template("admin_panel.html",
                           username=real_name,
                           round_no=current_round_no,
                           classes_data_by_modules=classes_data_by_modules)
    

@view.route("/admin_panel/update_ballot_result/<int:isConfirmed>", methods=["GET", "POST"])
@view.route("/admin_panel/update_ballot_result", methods=["GET", "POST"])
@login_required
def render_admin_update_ballot_result(isConfirmed = None):
    user = Users.query.filter_by(uname=current_user.uname).first()
    if not user:
        return redirect("/login")
    real_name = current_user.uname
    current_round_no = get_current_round()
    # Open and read the file as a single buffer
    fd = open('ballot_result.sql', 'r')
    ballot_result_sql = fd.read()
    fd.close()
    final_result = []
    confirmMessage = ''
    
    if isConfirmed == 1:
        confirmMessage = 'Updated ballot result!'
        ballot_result = db.session.execute(ballot_result_sql).fetchall()
        print("ballot result = ",ballot_result)
        for result in ballot_result:
            uname = result[0]
            module_code = result[1]
            rid = result[2]
            sessionNum = result[3]
            print(uname, module_code, rid, result)
            query = "UPDATE ballot SET is_successful = TRUE WHERE uname = '{}' AND module_code = '{}' AND rid = {} AND session = {};".format(uname, module_code, rid, sessionNum)
            try:
                db.session.execute(query)
                db.session.commit()
            except exc.DBAPIError as err:
                db.session.execute("rollback")
                print(err)
                print("update fails for ballot: ", result)
        try:
            query = "DELETE FROM ballot WHERE is_successful = FALSE;"
            db.session.execute(query)
            db.session.commit()
            print("Deleted")
        except exc.DBAPIError as err:
            db.session.execute("rollback")
            print(err)
            print("delete ballot fails!!") 
        try:            
            query = "SELECT * FROM ballot WHERE is_successful = TRUE;"
            final_result = db.session.execute(query).fetchall()
            print("final ballot result:",final_result)
        except exc.DBAPIError as err:
            db.session.execute("rollback")
            print(err)
            print("select all successive ballots fails!!")    
        confirmMessage = 'Result Generated'
            
    return render_template("admin_update_ballot_result.html",
                           username=real_name,
                           round_no=current_round_no,
                           final_result = final_result
                           )
    
@view.route("/admin_panel/update_result/<int:isConfirmed>", methods=["GET", "POST"])
@view.route("/admin_panel/update_result", methods=["GET", "POST"])
@login_required
def render_admin_update_result(isConfirmed = None):
    user = Users.query.filter_by(uname=current_user.uname).first()
    if not user:
        return redirect("/login")
    real_name = current_user.uname
    current_round_no = get_current_round()
    confirm_form = ConfirmBidResultForm()
    updateBidToSuccessfulForm = UpdateBidToSuccessfulForm()
    # Open and read the file as a single buffer
    fd = open('bid_status.sql', 'r')
    bid_sql = fd.read()
    fd.close()
    bid_result = db.session.execute(bid_sql).fetchall()
    print("bid result: ", bid_result)
    
    confirmMessage = ''
    
    if isConfirmed == 1:
        confirmMessage = 'Updated bid result! Refunded bid points of failed/Pending bid to respective student.'
        try:
            for result in bid_result:
                if_successful = result[10]
                if if_successful == 'Successful':
                    
                    module_code = result[0]
                    rid = result[1]
                    sessionNum = result[2]
                    uname = result[3]
                    
                    query = "UPDATE bid SET is_successful = True WHERE uname = '{}' AND module_code = '{}' AND rid = {} AND session = {};".format(uname, module_code, rid, sessionNum)
                    print(query)
                    try:
                        db.session.execute(query)
                        db.session.commit()
                    except exc.DBAPIError:
                        db.session.execute("rollback")
                        print("update Trigger pause")    
            
            query = "DELETE FROM bid WHERE is_successful = False;"
            db.session.execute(query)
            db.session.commit()
            
            print("Updated")
            bid_result = db.session.execute(bid_sql).fetchall()
        except exc.DBAPIError as err:
            db.session.execute("rollback")
            print("err: ", err)
            
    if updateBidToSuccessfulForm.validate_on_submit():
        print("updateBidToSuccessfulForm onlick")
        try:
            module_code = updateBidToSuccessfulForm.moduleId.data
            sessionNum = updateBidToSuccessfulForm.sessionNum.data
            rid = updateBidToSuccessfulForm.rid.data
            uname = updateBidToSuccessfulForm.uname.data
            query = "UPDATE bid SET is_successful = TRUE WHERE uname = '{}' AND module_code = '{}' AND rid = {} AND session = {};".format(uname, module_code, rid, sessionNum)
            try:
                db.session.execute(query)
                db.session.commit()
            except exc.DBAPIError:
                db.session.execute("rollback")
                print("update Trigger pause")    
            return redirect("/admin_panel/update_result")
        except exc.DBAPIError as err:
            db.session.execute("rollback")
            print("err: ", err)
            updateBidToSuccessfulForm.uname.errors.append("Update fails! The bid does not exist!")
            
            
    return render_template("admin_update_result.html",
                           username=real_name,
                           round_no=current_round_no,
                           bid_result = bid_result,
                           updateBidToSuccessfulForm = updateBidToSuccessfulForm,
                           confirmMessage = confirmMessage
                           )


@view.route("/admin_panel/update_course", methods=["GET", "POST"])
@login_required
def render_admin_update_course():
    user = Users.query.filter_by(uname=current_user.uname).first()
    if not user:
        return redirect("/login")
    real_name = current_user.uname
    query = "SELECT * FROM rounds WHERE CURRENT_DATE >= s_date and CURRENT_DATE <= e_date"
    current_round_no = get_current_round()
    query = "SELECT module_code FROM Courses WHERE admin = {}".format(
        real_name)
    
    form = AddCourseForm()
    if form.validate_on_submit():
        module_code = form.moduleId.data
        fname = form.fname.data
        mc = form.mc.data
        admin = real_name
        query = "INSERT INTO courses (module_code, admin, fname, mc) VALUES ('{}', '{}', '{}', {});".format(module_code, admin, fname, mc)
        try:
            db.session.execute(query)
            db.session.commit()
            form.mc.errors.append("The module has been added successfully")
            form.moduleId.data = ''
            form.fname.data = ''
            form.mc.data = ''
        except exc.DBAPIError as err:
            print("err: ", err)
            form.moduleId.errors.append(err)
    return render_template("admin_update_course.html",
                           username=real_name,
                           round_no=current_round_no,
                           form=form)
    

@view.route("/admin_panel/update_class", methods=["GET", "POST"])
@login_required
def render_admin_update_class():
    user = Users.query.filter_by(uname=current_user.uname).first()
    if not user:
        return redirect("/login")
    real_name = current_user.uname
    query = "SELECT * FROM rounds WHERE CURRENT_DATE >= s_date and CURRENT_DATE <= e_date;"
    current_round_no = get_current_round()
    
    form = AddClassForm()
    if form.validate_on_submit():
        moduleId = form.moduleId.data
        sessionNum = form.session.data
        rid = form.rid.data
        quota = form.quota.data
        weekday = form.weekday.data
        s_time = form.s_time.data
        e_time = form.e_time.data
        
        query = "INSERT INTO class (module_code, rid, session, quota, week_day, s_time, e_time) VALUES ('{}', {}, {}, {}, {},'{}', '{}')".format(moduleId, rid, sessionNum, quota, weekday, s_time, e_time)
        try:
            db.session.execute(query)
            db.session.commit()
            form.endTime.errors.append("The class has been added successfully")
            form.moduleId.data = ''
            form.session.data = ''
            form.rid.data = ''
            form.quota.data = ''
            form.weekday.data = ''
            form.s_time.data = ''
            form.e_time.data = ''
        except exc.DBAPIError as err:
            print("err: ", err)
            form.moduleId.errors.append(err)
    return render_template("admin_update_class.html",
                           username=real_name,
                           round_no=current_round_no,
                           form=form)


@view.route("/admin_panel/profile/logout", methods=["GET"])
@login_required
def render_admin_logout():
    logout_user()
    return redirect("/login")


@view.route("/admin_panel/update_rounds", methods=["GET", "POST"])
@login_required
def render_admin_update_rounds():
    user = Users.query.filter_by(uname=current_user.uname).first()
    if not user:
        return redirect("/manage")
    real_name = current_user.uname
    query = "SELECT * FROM rounds WHERE CURRENT_DATE >= s_date and CURRENT_DATE <= e_date"
    current_round_no = get_current_round()
    
    query = "SELECT * FROM rounds"
    all_round_data = db.session.execute(query).fetchall()
    
    form = EditRoundForm()
        
    if form.validate_on_submit():
        rid = form.rid.data
        startTime = form.startTime.data
        endTime = form.endTime.data
        admin = real_name
        query = "UPDATE rounds SET s_date = '{}', e_date = '{}' WHERE rid = {}".format(startTime, endTime, rid)
        try:
            db.session.execute(query)
            db.session.commit()
            return redirect("/admin_panel/update_rounds")
            form.endTime.errors.append("The selected round has been updated successfully")
        except exc.DBAPIError as err:
            print("err: ", err)
            form.rid.errors.append(err)

    return render_template("admin_update_rounds.html",
                           username=real_name,
                           round_no=current_round_no,
                           all_round_data = all_round_data,
                           form=form
                           )
    
@view.route("/admin_panel/profile/change_password", methods=["GET", "POST"])
@login_required
def render_admin_change_password():
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
                form.oldPassword.data = ''
                form.newPassword.data = ''
                form.confirmPassword.data = ''
    return render_template("admin_profile_change_password.html", username=current_user.uname, form=form)


@view.route("/students_panel/", methods=["GET"])
@login_required
def render_student_panel():
    if session['is_admin']:
        return redirect("/admin_panel")
    current_round = get_current_round()
    query = "SELECT si.rname, s.bid_point FROM student s NATURAL JOIN studentinfo si WHERE s.uname = '{}'".format(
        current_user.uname)
    real_name, bid_point = db.session.execute(query).fetchone()
    print(current_round)
    query = """
    SELECT B.module_code, B.session, CASE C.week_day
	    WHEN 1 THEN
		    'Monday'
	    WHEN 2 THEN
		    'Tuesday'
	    WHEN 3 THEN
		    'Wednesday'
	    WHEN 4 THEN
	    	'Thursday'
	    WHEN 5 THEN
		    'Friday'
	    WHEN 6 THEN
		    'Saturday'
	    ELSE
		    'Sunday'
        END
     || ' ' || C.s_time || '-' || C.e_time, B.bid FROM bid AS B NATURAL JOIN class AS C WHERE B.uname = '{}' and B.rid = {};""".format(
        current_user.uname, current_round)
    current_bids = db.session.execute(query).fetchall()
    query = """
            SELECT B.module_code, CASE C.week_day
	            WHEN 1 THEN
		            'Monday'
	            WHEN 2 THEN
		            'Tuesday'
	            WHEN 3 THEN
		            'Wednesday'
    	        WHEN 4 THEN
	        	    'Thursday'
	            WHEN 5 THEN
		            'Friday'
    	        WHEN 6 THEN
	    	        'Saturday'
	            ELSE
		            'Sunday'
                END
            || ' ' || C.s_time || '-' || C.e_time, C.quota, B.rank, B.session FROM ballot AS B NATURAL JOIN class AS C WHERE B.uname = '{}' and B.rid = 3 ORDER BY B.rank;
            """.format(
            current_user.uname)
    balloted_tutorials = db.session.execute(query).fetchall()
    print(balloted_tutorials)
    return render_template("student_panel.html",
                           username=real_name,
                           current_round=current_round,
                           current_bids=current_bids,
                           balloted_tutorials=balloted_tutorials,
                           bid_point=bid_point)


@view.route("/students_panel/profile/change_password", methods=["GET", "POST"])
@login_required
def render_student_change_password():
    if session['is_admin']:
        return redirect("/admin_panel")
    query = "SELECT si.rname, s.bid_point FROM student s NATURAL JOIN studentinfo si WHERE s.uname = '{}'".format(
        current_user.uname)
    real_name, bid_point = db.session.execute(query).fetchone()
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
    return render_template("student_profile_change_password.html", username=real_name, bid_point=bid_point, form=form)


@view.route("/students_panel/profile/logout", methods=["GET"])
@login_required
def render_student_logout():
    logout_user()
    return redirect("/login")


@view.route("/students_panel/profile/modules_taken", methods=["GET"])
@login_required
def render_student_modules_taken():
    if session['is_admin']:
        return redirect("/admin_panel")
    current_round = get_current_round()
    query = "SELECT si.rname, s.bid_point FROM student s NATURAL JOIN studentinfo si WHERE s.uname = '{}'".format(
        current_user.uname)
    real_name, bid_point = db.session.execute(query).fetchone()
    query = "SELECT c.module_code, c.fname, c.mc FROM taken AS t INNER JOIN courses AS c ON t.module_code = c.module_code WHERE t.uname = '{}'".format(
        current_user.uname)
    modules_taken = db.session.execute(query).fetchall()
    print(modules_taken)
    return render_template("student_profile_modules_taken.html",
                           username=real_name,
                           bid_point=bid_point,
                           modules=modules_taken)


@view.route("/students_panel/results/<int:roundid>", methods=["GET"])
@login_required
def render_student_result(roundid):
    if session['is_admin']:
        return redirect("/admin_panel")
    current_round = get_current_round()
    query = "SELECT si.rname, s.bid_point FROM student s NATURAL JOIN studentinfo si WHERE s.uname = '{}'".format(
        current_user.uname)
    real_name, bid_point = db.session.execute(query).fetchone()
    if current_round == roundid:
        return render_template("student_results.html",
                               username=real_name,
                               bid_point=bid_point,
                               current_round=current_round,
                               error1=1)

    elif current_round < roundid:
        return render_template("student_results.html",
                               username=real_name,
                               bid_point=bid_point,
                               current_round=roundid,
                               error2=1)
    else:
        query = """
        SELECT b.module_code, b.bid, CASE week_day
	        WHEN 1 THEN
		        'Monday'
	        WHEN 2 THEN
		        'Tuesday'
	        WHEN 3 THEN
		        'Wednesday'
	        WHEN 4 THEN
	    	    'Thursday'
	        WHEN 5 THEN
		        'Friday'
	        WHEN 6 THEN
		        'Saturday'
	        ELSE
		        'Sunday'
            END
        || ' ' || h.s_time || '-' || h.e_time FROM bid AS b NATURAL JOIN class AS h WHERE b.uname = '{}' and b.rid = {} and b.is_successful = True;""".format(
            current_user.uname, roundid)
        modules_got = db.session.execute(query).fetchall()
        print(modules_got)
        return render_template("student_results.html",
                               username=real_name,
                               bid_point=bid_point,
                               current_round=current_round,
                               roundid=roundid,
                               modules_got=modules_got)


@view.route("/students_panel/bid/edit/<string:module_code>/<int:sid>",
            methods=["GET", "POST"])
@view.route("/students_panel/bid/", methods=["GET"])
@login_required
def render_student_bid_edit(module_code=None, sid=None):
    if session['is_admin']:
        return redirect("/admin_panel")
    query = "SELECT si.rname, s.bid_point FROM student s NATURAL JOIN studentinfo si WHERE s.uname = '{}'".format(
        current_user.uname)
    real_name, bid_point = db.session.execute(query).fetchone()
    current_round = get_current_round()
    if module_code and sid:
        query = "SELECT bid FROM bid WHERE uname = '{}' AND module_code = '{}' AND rid = {} AND session = {}".format(
            current_user.uname, module_code, current_round, sid)
        bid_points = db.session.execute(query).fetchone()[0]
        form = EditBidForm()
        if form.validate_on_submit():
            new_bid_points = form.bid_point.data
            if new_bid_points == 0:
                query = "DELETE FROM bid WHERE uname = '{}' AND module_code = '{}' AND rid = {} AND session = {}".format(
                    current_user.uname, module_code, current_round, sid)
                print(query)
                db.session.execute(query)
                db.session.commit()
                return redirect("/students_panel/bid/")
            else:
                query = "UPDATE bid SET bid = {} WHERE uname = '{}' AND module_code = '{}' AND rid = {} AND session = {}".format(
                    new_bid_points, current_user.uname, module_code, current_round, sid)
                try:
                    db.session.execute(query)
                    db.session.commit()
                    return redirect("/students_panel/bid/")
                except exc.DBAPIError as e:
                    tmp = ' '.join(i for i in e.__str__().split(
                        '\n')[0].split(" ")[1:])
                    form.bid_point.errors.append(tmp)

        return render_template("student_bid.html", username=real_name, bid_point=bid_point, form=form, module_code=module_code, bid_points=bid_points, edit=1)
    else:
        query = """
        SELECT B.module_code, B.session, CASE C.week_day
	        WHEN 1 THEN
		        'Monday'
	        WHEN 2 THEN
		        'Tuesday'
	        WHEN 3 THEN
		        'Wednesday'
	        WHEN 4 THEN
	    	    'Thursday'
	        WHEN 5 THEN
		        'Friday'
	        WHEN 6 THEN
		        'Saturday'
	        ELSE
		        'Sunday'
            END
         || ' ' || C.s_time || '-' || C.e_time, B.bid FROM bid AS B NATURAL JOIN class AS C WHERE B.uname = '{}' and B.rid = {};""".format(
            current_user.uname, current_round)
        current_bids = db.session.execute(query).fetchall()
        query = """
        SELECT module_code, session, CASE week_day
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            ELSE 'Sunday'
        END || ' ' || s_time || '-' || e_time, quota FROM class WHERE  rid = {} AND module_code NOT IN (SELECT module_code FROM taken WHERE uname = '{}' UNION SELECT module_code FROM bid WHERE uname = '{}' AND rid = {} AND is_successful = True);
        """.format(current_round, current_user.uname, current_user.uname, current_round-1)
        available_lectures = db.session.execute(query).fetchall()
        print(current_round)
        return render_template("student_bid.html",
                               username=real_name,
                               bid_point=bid_point,
                               current_round=current_round,
                               current_bids=current_bids,
                               available_lectures=available_lectures,
                               module_not_specified=1)


@view.route("/students_panel/bid/add/<string:module_code>/<int:sid>", methods=["GET", "POST"])
@login_required
def render_student_bid_add(module_code, sid):
    if session['is_admin']:
        return redirect("/admin_panel")
    query = "SELECT si.rname, s.bid_point FROM student s NATURAL JOIN studentinfo si WHERE s.uname = '{}'".format(
        current_user.uname)
    real_name, bid_point = db.session.execute(query).fetchone()
    current_round = get_current_round()
    print(current_round)
    form = AddBidForm()
    query = """
        SELECT module_code, CASE week_day
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            ELSE 'Sunday'
        END || ' ' || s_time || '-' || e_time, quota FROM class WHERE rid = {} AND module_code = '{}' and session = {};
        """.format(current_round, module_code, sid)
    module_info = db.session.execute(query).fetchone()
    if form.validate_on_submit():
        bid = form.bid_point.data
        query = "INSERT INTO bid VALUES ('{}', {}, '{}', {}, {}, 'f')".format(
            current_user.uname, bid, module_code, current_round, sid)
        print(query)
        try:
            db.session.execute(query)
            db.session.commit()
            return redirect("/students_panel/bid/")
        except exc.DBAPIError as e:
            tmp = ' '.join(i for i in e.__str__().split(
                '\n')[0].split(" ")[1:])
            print(tmp)
            form.bid_point.errors.append(tmp)

    return render_template("student_bid.html", username=real_name, bid_point=bid_point, form=form, module_info=module_info, add=1)


@view.route("/students_panel/bid/lectures/view", methods=["GET"])
@login_required
def render_student_bid_lectures():
    if session['is_admin']:
        return redirect("/admin_panel")
    return "asdf"


@view.route("/students_panel/ballot/", methods=["GET"])
@view.route("/students_panel/ballot/<string:action>/<string:module_code>/<int:sid>", methods=["GET"])
@login_required
def render_student_ballot_edit(action=None, module_code=None, sid=None):
    if session['is_admin']:
        return redirect("/admin_panel")
    query = "SELECT si.rname, s.bid_point FROM student s NATURAL JOIN studentinfo si WHERE s.uname = '{}'".format(
        current_user.uname)
    real_name, bid_point = db.session.execute(query).fetchone()
    current_round = get_current_round()
    if current_round != 3:
        return redirect("/students_panel/")
    if module_code and sid:
        if action == 'add':
            query = "INSERT INTO ballot VALUES ('{}', (SELECT COUNT(*) FROM ballot WHERE uname = '{}')+1, '{}', 3, {}, 'f')".format(
                current_user.uname, current_user.uname, module_code, sid)
            print(query)
            try:
                db.session.execute(query)
                db.session.commit()
                return redirect("/students_panel/ballot/")
            except exc.DBAPIError as e:
                tmp = ' '.join(i for i in e.__str__().split(
                    '\n')[0].split(" ")[1:])
                return(tmp)
        elif action == 'del':
            query = "SELECT rank FROM ballot WHERE uname = '{}' AND module_code = '{}' AND session = {} AND rid = 3".format(
                current_user.uname, module_code, sid)
            prev_rank = db.session.execute(query).fetchone()[0]

            query = "DELETE FROM ballot WHERE uname = '{}' AND module_code = '{}' AND session = {} AND rid = 3".format(
                current_user.uname, module_code, sid)
            try:
                db.session.execute(query)
                db.session.commit()
                query = "UPDATE ballot SET rank = rank-1 WHERE uname = '{}' AND rid = 3 AND rank > {}".format(
                    current_user.uname, prev_rank)
                db.session.execute(query)
                db.session.commit()
                return redirect("/students_panel/ballot/")
            except exc.DBAPIError as e:
                tmp = ' '.join(i for i in e.__str__().split(
                    '\n')[0].split(" ")[1:])
                return(tmp)
        elif action == 'up':
            query = "SELECT rank FROM ballot WHERE uname = '{}' AND module_code = '{}' AND  session = {} AND rid = 3".format(
                current_user.uname, module_code, sid)
            prev_rank = db.session.execute(query).fetchone()[0]
            if prev_rank != 1:
                # move the slot after to the end+1
                query = "UPDATE ballot SET rank = (SELECT COUNT(*) FROM ballot WHERE uname = '{}' AND rid = 3)+1 WHERE uname = '{}' And rid=3 AND rank = {};".format(
                    current_user.uname, current_user.uname, prev_rank-1)
                db.session.execute(query)
                # move down
                query = "UPDATE ballot SET rank = {} WHERE uname = '{}' AND module_code = '{}' AND rid = 3 AND rank = {} AND session = {}".format(
                    prev_rank-1, current_user.uname, module_code, prev_rank, sid)
                db.session.execute(query)
                # move back
                query = "UPDATE ballot SET rank = {} WHERE uname = '{}' AND rid = 3 AND rank = (SELECT COUNT(*) FROM ballot WHERE uname = '{}' AND rid = 3)+1".format(
                    prev_rank, current_user.uname, current_user.uname)
                db.session.execute(query)
                try:
                    db.session.commit()
                    return redirect("/students_panel/ballot/")
                except exc.DBAPIError as e:
                    tmp = ' '.join(i for i in e.__str__().split(
                        '\n')[0].split(" ")[1:])
                    return(tmp)
            else:
                return redirect("/students_panel/ballot/")
        elif action == "down":
            query = "SELECT rank FROM ballot WHERE uname = '{}' AND module_code = '{}' AND  session = {} AND rid = 3".format(
                current_user.uname, module_code, sid)
            prev_rank = db.session.execute(query).fetchone()[0]
            print(prev_rank)
            query = "SELECT COUNT(*) FROM ballot WHERE uname = '{}' AND rid = 3".format(
                current_user.uname)
            ballot_no = db.session.execute(query).fetchone()[0]
            print(ballot_no)
            if prev_rank != ballot_no:
                # move the slot after to the end+1
                query = "UPDATE ballot SET rank = {} WHERE uname = '{}' And rid=3 AND rank = {};".format(
                    ballot_no+1, current_user.uname, prev_rank+1)
                db.session.execute(query)
                # move down
                query = "UPDATE ballot SET rank = {} WHERE uname = '{}' AND module_code = '{}' AND rid = 3 AND rank = {} AND session = {}".format(
                    prev_rank+1, current_user.uname, module_code, prev_rank, sid)
                db.session.execute(query)
                # move back
                query = "UPDATE ballot SET rank = {} WHERE uname = '{}' AND rid = 3 AND rank = {}".format(
                    prev_rank, current_user.uname, ballot_no+1)
                db.session.execute(query)
                try:
                    db.session.commit()
                    return redirect("/students_panel/ballot/")
                except exc.DBAPIError as e:
                    tmp = ' '.join(i for i in e.__str__().split(
                        '\n')[0].split(" ")[1:])
                    return(tmp)
            else:
                return redirect("/students_panel/ballot/")
    else:
        query = """
            SELECT module_code, CASE week_day
                WHEN 1 THEN 'Monday'
                WHEN 2 THEN 'Tuesday'
                WHEN 3 THEN 'Wednesday'
                WHEN 4 THEN 'Thursday'
                WHEN 5 THEN 'Friday'
                WHEN 6 THEN 'Saturday'
                ELSE 'Sunday'
            END || ' ' || s_time || '-' || e_time, session, quota FROM class WHERE module_code IN (SELECT module_code FROM bid WHERE uname = '{}' AND is_successful = True) AND rid = 3 ORDER BY module_code;
            """.format(current_user.uname)
        available_tutorials = db.session.execute(query)
        query = """
            SELECT B.module_code, CASE C.week_day
	            WHEN 1 THEN
		            'Monday'
	            WHEN 2 THEN
		            'Tuesday'
	            WHEN 3 THEN
		            'Wednesday'
    	        WHEN 4 THEN
	        	    'Thursday'
	            WHEN 5 THEN
		            'Friday'
    	        WHEN 6 THEN
	    	        'Saturday'
	            ELSE
		            'Sunday'
                END
            || ' ' || C.s_time || '-' || C.e_time, C.quota, B.rank, B.session FROM ballot AS B NATURAL JOIN class AS C WHERE B.uname = '{}' and B.rid = 3 ORDER BY B.rank;
            """.format(
            current_user.uname)
        balloted_tutorials = db.session.execute(query).fetchall()
        # print(balloted_tutorials)
        return render_template("student_ballot.html", username=real_name, bid_point=bid_point, current_round=current_round, available_tutorials=available_tutorials, balloted_tutorials=balloted_tutorials)


@view.route("/students_panel/ballot/del/<string:module_code>/<int:sid>", methods=["GET"])
@login_required
def render_student_ballot_del(module_code, sid):
    if session['is_admin']:
        return redirect("/admin_panel")
    query = "SELECT rank FROM ballot WHERE uname = '{}' AND module_code = '{}' AND session = {} AND rid = 3".format(
        current_user.uname, module_code, sid)
    prev_rank = db.session.execute(query).fetchone()[0]

    query = "DELETE FROM ballot WHERE uname = '{}' AND module_code = '{}' AND session = {} AND rid = 3".format(
        current_user.uname, module_code, sid)
    try:
        db.session.execute(query)
        db.session.commit()
        query = "UPDATE ballot SET rank = rank-1 WHERE uname = '{}' AND rid = 3 AND rank > {}".format(
            current_user.uname, prev_rank)
        db.session.execute(query)
        db.session.commit()
        return redirect("/students_panel/ballot/")
    except exc.DBAPIError as e:
        tmp = ' '.join(i for i in e.__str__().split(
            '\n')[0].split(" ")[1:])
        return(tmp)


@view.route("/search", methods=["POST"])
@login_required
def render_studetn_search():
    if session['is_admin']:
        return redirect("/admin_panel")
    query = "SELECT si.rname, s.bid_point FROM student s NATURAL JOIN studentinfo si WHERE s.uname = '{}'".format(
        current_user.uname)
    real_name, bid_point = db.session.execute(query).fetchone()
    current_round = get_current_round()
    if request.form['module_code']:
        module_code = request.form['module_code']
        """
        query = "SELECT rid FROM rounds WHERE current_timestamp >= s_date and current_timestamp <= e_date"
        current_round = db.session.execute(query).fetchone()[0]
        """

        query = """
        SELECT module_code, CASE week_day
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            ELSE 'Sunday'
        END || ' ' || s_time || '-' || e_time, session, rid, quota FROM class WHERE module_code ilike '%{}%' order by rid;
        """.format(module_code)
        modules = db.session.execute(query).fetchall()
        print(modules)
        print(request.form['module_code'])
        return render_template('student_search.html', username=real_name, bid_point=bid_point, modules=modules)
