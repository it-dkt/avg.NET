sceneEvents.clearGame = function(){
	$('#command-area').html('');

	return true;
};

sceneEvents.backTo00001 = function(){
	setFlag('');
	window.location.href = '/scenes/00001.html';
	return true;
}
