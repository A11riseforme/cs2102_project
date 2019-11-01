from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField
from wtforms.validators import InputRequired, ValidationError


def is_valid_name(form, field):
    if not all(map(lambda char: char.isalpha(), field.data)):
        raise ValidationError('This field should only contain alphabets')


def agrees_terms_and_conditions(form, field):
    if not field.data:
        raise ValidationError(
            'You must agree to the terms and conditions to sign up')


class RegistrationForm(FlaskForm):
    matricID = StringField(
        label='matricID',
        validators=[InputRequired()],
        render_kw={'placeholder': 'matricID'}
    )
    username = StringField(
        label='Name',
        validators=[InputRequired(), is_valid_name],
        render_kw={'placeholder': 'Name'}
    )
    password = PasswordField(
        label='Password',
        validators=[InputRequired()],
        render_kw={'placeholder': 'Password'}
    )


class ResetForm(FlaskForm):
    matricID = StringField(
        label='matricID',
        validators=[InputRequired()],
        render_kw={'placeholder': 'matricID'}
    )
    authCode = StringField(
        label='',
        validators=[],
        render_kw={'placeholder': 'authCode'}
    )
    password = PasswordField(
        label='Password',
        validators=[],
        render_kw={'placeholder': 'Password'}
    )


class LoginForm(FlaskForm):
    username = StringField(
        label='Name',
        validators=[InputRequired()],
        render_kw={'placeholder': 'Name', 'class': 'input100'}
    )
    password = PasswordField(
        label='Password',
        validators=[InputRequired()],
        render_kw={'placeholder': 'Password', 'class': 'input100'}
    )
