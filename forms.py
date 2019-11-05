from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, IntegerField
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


def is_valid_bid_point(form, field):
    if field.Points < 0:
        raise ValidationError('Bid point must be non-negative!')


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
    bid_point = IntegerField('bid_point', validators=[is_valid_bid_point])
