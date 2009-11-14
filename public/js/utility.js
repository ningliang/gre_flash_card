var BASE_URL = window.location.protocol + "//" + window.location.host;
var OK = 200;

// Center an element vertically and horizontall
$.fn.center = function() {
	var node = $(this);
	node.css({ 
		position: "absolute", 
		top: "50%", 
		"margin-top": "-" + (node.height() / 2) + "px",
		"margin-left": "20px",
		"margin-right": "20px",
		width: (node.parent().width() - 40) + "px"
	});
}

// Make any class a singleton
function makeSingleton(klass) {
	klass.instance = null;
	klass.getInstance = function() {
		if (!klass.instance) klass.instance = new klass();
		return klass.instance;
	}
}

function RequestProxy() {
	var GET = "GET";
	var POST = "POST";
	var PUT = "PUT";
	var DELETE = "DELETE";
	
	function request(path, method, data, successHandler, errorHandler) {
		var requestData = { _method: method, data: JSON.stringify(data || {}) };
		if (method == PUT || method == DELETE) method = POST;
		
		var options = {
			url: BASE_URL + path,
			type: method,
			dataType: "json",
			data: requestData,
			cache: false,
			success: function(response) { if (successHandler) successHandler(response); },
			error: function(request, status, error) { if (errorHandler) errorHandler(request.status, request.responseText) }			
		};
		
		$.ajax(options);
	}
	
	this.get = function(path, successHandler, errorHandler) { request(path, GET, null, successHandler, errorHandler); }
	this.post = function(path, successHandler, errorHandler) { request(path, POST, data, successHandler, errorHandler); }
	this.put = function(path, successHandler, errorHandler) { request(path, PUT, data, successHandler, errorHandler); }
	this.destroy = function(path, successHandler, errorHandler) { request(path, DELETE, data, successHandler, errorHandler); }
}
makeSingleton(RequestProxy);

function ServiceProxy() {
	var that = this;
	var setPath = "/sets"
	var wordPath = "/words"
	var proxy = RequestProxy.getInstance();
	
	this.allSets = function(successHandler, errorHandler) { proxy.get(setPath, successHandler, errorHandler); }
	this.allWords = function(successHandler, errorHandler) { proxy.get(wordPath, successHandler, errorHandler); }	
	this.getSet = function(setId, successHandler, errorHandler) { proxy.get(setPath + "/" + setId, successHandler, errorHandler); }
}
makeSingleton(ServiceProxy);