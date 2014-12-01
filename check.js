<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<script src="http://crypto-js.googlecode.com/svn/tags/3.1.2/build/rollups/md5.js"></script>
<script type="text/javascript">
$(document).ready(function(){ 

	$("*[xtag!='509']").each(function(){
		var tagname = this.tagName;
		/* TODO try to remove and STOP attacker's script
		   if (tagname === "SCRIPT") {
		   $(this).remove();
		   }
		*/
		// $(this).hide();
		$(this).fadeOut(3000, "linear");
		console.log(tagname + " removed hided (no xtag");
	});	

	// remove element without ssig
	$(":not([ssig])").each(function(){
		if ($(this).attr('xtag') != undefined) { // need not remove twice
			var tagname = this.tagName;
			$(this).fadeOut(3000, "linear");
			console.log(tagname + " removed hided (no ssig");
		}
	});	

	// traverse dom tree with post-order to check the integrity
	traverse(document.body);
});

function check_and_alarm(node) {
	// TODO implement asymmetric hash
	md5 = CryptoJS.MD5(node.innerHTML).toString().substring(0, 8)
		ssig = node.getAttribute('ssig')

		if (md5 != ssig) {
			console.log(ssig + ' vs ' + md5 + ' ' + node.nodeName);
			$(node).css('background-color', 'red');
			return false;
		}

	// console.log(ssig + ' ' + node.nodeName); // md5 matched
	return true;
}

// return false if md5 not matched, traverse with post-order
function traverse(node) {
	var num = $(node).children('[ssig]').length
		var children_intact = true;
	$(node).children('[ssig]').each(function(index, item) {
		if (false == traverse(item))
		children_intact = false;
	});
	// console.log(node.innerHTML);
	// console.log(node.textContent);

	// perform check for leaves
	// if children are intact, also check for this node (like text field,
	// the order of children)
	if (num == 0 || children_intact == true)
		return check_and_alarm(node);

	return children_intact;
}
</script>
