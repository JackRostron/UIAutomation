BaseView = function() { throw "abstract class!"}

BaseView.prototype.elements = null;

BaseView.prototype.element = function(item) {
	return eval(this.elements[item]);
}