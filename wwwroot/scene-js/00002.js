const showPerson = function(){

	const img = $('<img>', {
			src: '../img/person.png',
			addClass: 'img-person1',
			id: '00002-person1'
		}
	);
	
	$('#image-area').append(img);

	setPersonMode('person');
	getCommands(getSceneId());

	return true;
}

const hidePerson =  function(){

	// remove person image
	$('#00002-person1').remove();
	
	// set to normal mode
	setPersonMode('');
	getCommands(getSceneId());

	return true;
}