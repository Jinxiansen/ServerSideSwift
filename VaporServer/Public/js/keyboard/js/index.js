// caps lock key
document.addEventListener("DOMContentLoaded", function(){
	document.getElementById("caps-lock").addEventListener("click", function(){
		let l = this.childNodes[0].classList;
		l.contains("on") ? l.remove("on") : l.add("on");
	});
});