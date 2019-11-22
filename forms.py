from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, IntegerField, DateField, TimeField, DateTimeField
from wtforms.validators import InputRequired, ValidationError


def is_valid_name(form, field):
    if not all(map(lambda char: char.isalpha(), field.data)):
        raise ValidationError('This field should only contain alphabets!')


def is_valid_password(form, field):
    if len(field.data) < 8:
        raise ValidationError('This field should be at least 8 characters!')


def agrees_terms_and_conditions(form, field):
    if not field.data:
        raise ValidationError(
            'You must agree to the terms and conditions to sign up!')


def is_valid_bid_point_to_edit(form, field):
    if field.data and field.data < 0:
        raise ValidationError('Bid point must be non-negative!')


def is_valid_bid_point_to_add(form, field):
    if field.data and field.data <= 0:
        raise ValidationError('Bid point must be positive!')

def is_valid_round_number(form, field):
    if field.data <= 0 or field.data >3:
        raise ValidationError('There are only round 1, 2 and 3')

class RegistrationForm(FlaskForm):
    matricID = StringField(label='matricID',
                           validators=[InputRequired()],
                           render_kw={'placeholder': 'matricID'})
    username = StringField(label='Name',
                           validators=[InputRequired(), is_valid_name],
                           render_kw={'placeholder': 'Name'})
    password = PasswordField(label='Password',
                             validators=[InputRequired(), is_valid_password],
                             render_kw={'placeholder': 'Password'})


class ResetForm(FlaskForm):
    matricID = StringField(label='matricID',
                           validators=[InputRequired()],
                           render_kw={'placeholder': 'matricID'})
    authCode = StringField(label='',
                           validators=[],
                           render_kw={'placeholder': 'authCode'})
    password = PasswordField(label='Password',
                             validators=[],
                             render_kw={'placeholder': 'Password'})


class ChangePasswordForm(FlaskForm):
    oldPassword = StringField('oldPassword',
                              validators=[InputRequired(), is_valid_password])
    newPassword = StringField('newPassword',
                              validators=[InputRequired(), is_valid_password])
    confirmPassword = StringField(
        'confirmPassword', validators=[InputRequired(), is_valid_password])
    submit = SubmitField('Change Password')


class LoginForm(FlaskForm):
    username = StringField(label='Name',
                           validators=[InputRequired()],
                           render_kw={
                               'placeholder': 'Name',
                               'class': 'input100'
                           })
    password = PasswordField(label='Password',
                             validators=[InputRequired()],
                             render_kw={
                                 'placeholder': 'Password',
                                 'class': 'input100'
                             })


class EditBidForm(FlaskForm):
    bid_point = IntegerField('New Bid Point: (set to 0 to delete this bid)', validators=[
                             InputRequired(), is_valid_bid_point_to_edit])
    submit = SubmitField('Update bid')


class AddBidForm(FlaskForm):
    bid_point = IntegerField('Bid Point', validators=[
                             InputRequired(), is_valid_bid_point_to_add])
    submit = SubmitField('Add bid')
    
class EditRoundForm(FlaskForm):
    rid = IntegerField('round id',
                           validators=[InputRequired(), is_valid_round_number])
    startTime = DateTimeField('start time',
                        validators=[InputRequired()])
    endTime = DateTimeField('start time',
                      validators=[InputRequired()])
    submit = SubmitField('Edit')
    
class AddCourseForm(FlaskForm):
    moduleId = StringField('moduleId',
                           validators=[InputRequired()])
    fname = StringField('fname',
                        validators=[InputRequired()])
    mc = IntegerField('mc',
                     validators=[InputRequired()])
    submit = SubmitField('add')
    
class AddClassForm(FlaskForm):
    moduleId = StringField('moduleId',
                           validators=[InputRequired()])
    rid = IntegerField('rid',
                        validators=[InputRequired(), is_valid_round_number])
    session = IntegerField('session',
                     validators=[InputRequired()])
    quota = IntegerField('quota',
                     validators=[InputRequired()])
    weekday = IntegerField('weekday',
                     validators=[InputRequired()])
    s_time = TimeField('startTime',
                     validators=[InputRequired()])
    e_time = TimeField('endTime',
                     validators=[InputRequired()])
    submit = SubmitField('add')
    
class ConfirmBidResultForm(FlaskForm):
    submit = SubmitField('Confirm')

class UpdateBidToSuccessfulForm(FlaskForm):
    moduleId = StringField('moduleId',
                           validators=[InputRequired()])
    rid = IntegerField('rid',
                     validators=[InputRequired()])
    sessionNum = IntegerField('sessionNum',
                        validators=[InputRequired()])
    uname = StringField('uname',
                           validators=[InputRequired()])
    submit = SubmitField('Update bid to successful')
