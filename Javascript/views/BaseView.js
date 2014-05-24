BaseView = function() { throw "abstract class!"}

BaseView.prototype.elements = "elements";

BaseView.prototype.element = function(item) {
	return eval(this.elements[item]);
}