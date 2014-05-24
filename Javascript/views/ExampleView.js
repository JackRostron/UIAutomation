ViewLoginElements = function() {
	this.elements = {
		'btnLogin' : 'app.buttons().withName("LoginButton")[0]',
		'txtEmailAddress' : 'app.textFields().withName("EmailAdressTextField")[0]',
		'txtPassword' : 'app.buttons().withName("PasswordTextField")[0]'
	}
}

ViewLoginElements.prototype = Object.create(BaseView.prototype);
var ViewLogin = new ViewLoginElements();