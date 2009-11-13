function StudyArea(node, set) {
	// Util
	var that = this;
	
	// Nodes
	var node = $(node);
	var definitions = $("#definitions", node);
	var study = $("#study", node);
	
	// Set
	var count = set["count"]
	var title = set["title"]
	var words = set["words"]
	
	new Definitions(definitions, words);
	new Deck(study, words);
	
	$("li", node).each(function() {
		var selector = $("a", this).attr("href");
		$(this).click(function(e) {
			e.preventDefault();
			$("> div", node).each(function() {
				$(this).hide();
			});
			$(selector, node).show();
		});
	});
	$("li:first", node).click();
}

function Deck(node, wordList) {
	// Utility
	var that = this;
	
	// Nodes
	var node = $(node);
	var progress = $("#progress", node);
	
	var reset = $("#reset", node);
	
	var card = $("#card", node);
	var front = $("#front", node);
	var back = $("#back", node);
	var flip = $("a#flip", node);
	var flag = $("#flag", node);
	var next = $("#next", node);
	
	// Hash set of words
	var words = {};
	$.each(wordList, function(){
		var word = this;
		words[word["word"]] = word["definition"];
	});
	
	// Randomized list
	var list = [];
	var currentIndex = null;
	
	// Return -1, 0 or 1 randomly
	function randomComparator(a, b) {
		return (Math.floor(Math.random() * 4) - 1);
	}
	
	// Render the current card, front side up
	function render() {
		front.html(list[currentIndex]);
		back.html(words[list[currentIndex]]);
		if (currentIndex == list.length - 1) {
			next.hide();
			flag.hide();
		} else {
			next.show();
			flag.show();
		}
		front.show();
		back.hide();
		progress.html((currentIndex + 1) + " of " + list.length + " words");
	}
	
	// Randomize words in hash and insert into list, clear stats
	this.reset = function() {
		list = []
		for (var word in words) list.push(word);
		list.sort(randomComparator);
		currentIndex = 0;
		render();
	}
	
	this.next = function() {
		currentIndex++;
		render();
	}
	
	this.flag = function() {
		// TODO splice
	}
	
	this.flip = function() {
		front.is(":visible") ? front.hide() : front.show();
		back.is(":visible") ? back.hide() : back.show();
	}
	
	// Match ui buttons to functions
	function bindAll() {
		reset.click(function(e) { e.preventDefault(); that.reset(); });
		next.click(function(e) { e.preventDefault(); that.next(); });
		flag.click(function(e) { e.preventDefault(); that.flag(); });
		flip.click(function(e) { e.preventDefault(); that.flip(); });
	}
	bindAll();
	that.reset();
}

/*
#study
	#stats
	#card
		%a#flip{ :href => "#" }
			#front
			#back
	#buttons
		%a#flag{ :href => "#" }= "Flag"
		%a#next{ :href => "#" }= "Next"
*/

function Definitions(node, words) {
	var that = this;
	var node = $(node);
	
	$.each(words, function() {
		var word = this;
		node.append($("<div/>").addClass("word-entry")
			.append($("<div/>").addClass("word").html(word["word"]))
			.append($("<div/>").addClass("definition").html(word["definition"])));
	});
}

$(function() {
	var study = new StudyArea($("#study-tabs"), set);
});