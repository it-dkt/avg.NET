// constants
const FLAG_KEY = 'AVG_FLAG_KEY';
const COMMAND_ID_MOVE = 'GOT';
const MESSAGE_WAIT_TIME = 75;
const MESSAGE_NEWLINE_CHAR = '@';
const MESSAGE_SPLIT_CHAR = ';'
const MESSAGE_EVENT_CHAR = '^';
const MESSAGE_PART_DIV = 'message-part-'
const MESSAGE_NEXT_LINK = '▼';
const DEFAULT_EVENT_STRING = 'empty_event';

// variables
let splitMsgs = []; 
let eventString = DEFAULT_EVENT_STRING;
let personMode = ''; 
let isOk = true;

$(document).ready(function () {
	initScene();
});

const initScene = function () {

	let flag = getFlag();
	let scene_id = getSceneId();

	// clear message area 
	$('#message-area').html('Loading...');

	// get initial message of the scene
	getMessage(scene_id, '000', '000', flag);
}

const getSceneId = function () {
	return $('#scene-id').val();
}

const getCommands = function (scene_id) {

	// default scene id is current scene's
	if(scene_id){
	}else{
		scene_id = getSceneId();
	}

	const data = {
		sceneId: scene_id,
	};
	// callback function of get commands api 
	const success = showCommands;

	if(getPersonMode(scene_id)){
		// api to get commands for person mode
		execAjax('/api/command/person', data, success);
	}else{
		execAjax('/api/command', data, success);
	}
}

const showCommands = function (data, dataType) {

	// show message returned with the commands.
	showMessage(data);

	// clear command list
	$('#command-list').empty();
	// create command links
	const commands = data['commands'];
	commands.forEach(command => {
		// target_id of top level command is not set.
		const target_id = command.targetId ? command.targetId : '';

		// the id of command DOM element is command_id (ex.'CHK')
		// or command_id + target_id (ex.'CHK001')
		const link = $('<li></li>', {
			id: command.commandId + target_id
		});
		$(link).text(command.text);

		$('#command-list').append(link);
	});

	// register event fires where the player select a command
	$('#command-list li').each(function (index, element) {
		const link_id = element.id;
		const command_id = link_id.substring(0, 3);
		const target_id = link_id.substring(3, 6);

		if (command_id == COMMAND_ID_MOVE && target_id && canIGoTo(target_id)) {
			// if the command is the one to go to other scenes, and
			// if the target_id (where to go) is set, and
			// if the target is the one that the player is not forbidden,
			// go to the scene. 
			$(element).on('click', { link_id: link_id }, onChangeScene);
		} else {
			$(element).on('click', { link_id: link_id }, onClickCommand);
		}

		// hover style
		$(element).on('touchstart mouseover', function () {
			$(this).addClass('touch');
		});
		$(element).on('touchend mouseleave', function () {
			$(this).removeClass('touch');
		});
	});
}

const canIGoTo = function (target_id) {
	return target_id.substring(0, 1) != 'F'
}

const onChangeScene = function (e) {
	// lock
	if (isOk) { isOk = false; } else { return false; }

	const link_id = e.data.link_id;

	const scene_id = getSceneId();
	const command_id = link_id.substring(0, 3);
	const target_id = link_id.substring(3, 6);

	// data for api
	const data = {
		sceneId: scene_id,
		commandId: command_id,
		targetId: target_id
	};

	// callback
	const success = function (data, dataType) {
		var path = data['path'];
		window.location.href = path;
	}

	// the api returns the path of destination scene html
	execAjax('/api/scene/dest', data, success);
}

const onClickCommand = function (e) {
	// lock
	if (isOk) { isOk = false; } else { return false; }

	const link_id = e.data.link_id;

	const scene_id = getSceneId();
	const command_id = link_id.substring(0, 3);
	const target_id = link_id.substring(3, 6);

	const flag = getFlag();
	const person = getPersonMode();

	// request data for api
	const data = {
		sceneId: scene_id,
		commandId: command_id,
		flag: flag
	};

	let success = null;
	if (target_id) {
		// callback: when tartget_id is set in the id attributge of clicked element (ex: 'CHK001')
		success = function (data, dataType) {
			// show the result of executing the command to the target
			getMessage(scene_id, command_id, target_id, flag);
			// get top level command again
			getCommands(scene_id);
		}

	} else {
		// callback: when tartget_id is NOT set (ex: 'CHK')
		success = function (data, dataType) {
			if(data.commands && data.commands.length > 0){
				// if some targets returned, show them 
				showCommands(data);
			}else{
				// if no target returned, only show the default message
				showMessage(data);
			}
		}
	}

	// get targets api
	execAjax('/api/target', data, success);
}

const getMessage = function (scene_id, command_id, target_id, flag) {

	const data = {
		sceneId: scene_id,
		commandId: command_id,
		targetId: target_id,
		flag: flag
	};

	// callback
	const success = function (data, dataType) {
		showMessage(data);
	}

	// get messages api
	execAjax('/api/message', data, success);
}

// call backend api
const execAjax = function (url, pData, pSuccess, pError) {

	// default callback
	let success = function (data, dataType) {
		alert(data);
	}

	if (pSuccess) {
		success = pSuccess;
	}

	// default error callback
	const error = function (XMLHttpRequest, textStatus, errorThrown) {
		alert('Error : ' + errorThrown);
		$("#XMLHttpRequest").html("XMLHttpRequest : " + XMLHttpRequest.status);
		$("#textStatus").html("textStatus : " + textStatus);
		$("#errorThrown").html("errorThrown : " + errorThrown);
	}

	if (pError) {
		error = pError;
	}

	$.ajax({
		type: "GET",
		url: url,
		data: pData,
		success: success,
		error: error
	});
}

const showMessage = function (data) {

	const msg = data['message'];
	const flag = data['flag'];
	const event = data['event'];

	// update the player's flag value
	if (flag) {
		sessionStorage[FLAG_KEY] = flag;
	}

	if (event) {
		eventString = event;
	}

	if (msg) {
		splitMsgs = msg.split(MESSAGE_SPLIT_CHAR);
		//console.log(splitMsgs);
		showMessagePart(0);
	}
}

// show messages splited by the defined charactor
const showMessagePart = function (part_index) {

	const div_selector = '#message-area';
	const messagePart = splitMsgs[part_index];
	//console.log('part text : ' + text);

	// clear message area 
	$(div_selector).html('');

	index = 0;

	// show charactors one by one
	const write_text = function () {
		// if matches defined controll charactors
		if (messagePart.charAt(index) == MESSAGE_NEWLINE_CHAR) {
			// new line
			$(div_selector).html($(div_selector).html() + '<br/>');
		} else if (messagePart.charAt(index) == MESSAGE_EVENT_CHAR) {
			// execute event
			execEvent();
		} else {
			// normal charactors
			$(div_selector).html($(div_selector).html() + messagePart.charAt(index));
			//console.log(index + ' : ' + text.charAt(index));
		}

		index++;
		if (messagePart.length > index) {
			// show next charactor
			setTimeout(write_text, MESSAGE_WAIT_TIME);
		} else {
			// the end of the message part
			if (splitMsgs.length > (part_index + 1)) {
				// create link to next part
				const next_link = $('<a></a>');
				next_link.attr('href', 'javascript:void(0);');
				next_link.text(MESSAGE_NEXT_LINK);
				next_link.on('click', function () {
					showMessagePart(part_index + 1);
				});

				$(div_selector).append($('<br/>'));
				$(div_selector).append(next_link);
			} else {
				// if all of parts are shown, unlock command
				isOk = true;
			}
		}
	}

	setTimeout(write_text, MESSAGE_WAIT_TIME);
}

const setPersonMode = function (person_flag) {
	personMode = person_flag;
}

const getPersonMode = function () {
	return personMode;
}

const getFlag = function () {

	let flag = sessionStorage[FLAG_KEY];

	if (flag) {
		;
	} else {
		flag = '0'
		setFlag(flag);
	}

	return flag;
}

const setFlag = function (flag) {
	if (flag) {
		sessionStorage[FLAG_KEY] = flag;
	} else {
		sessionStorage.removeItem(FLAG_KEY);
	}
}

const execEvent = function () {

	if (eventString) {
		if (sceneEvents[eventString] !== 'undefined') {
			sceneEvents[eventString](); 
		} else {
			alert(eventString + 'is NOT a function!');
		}

		// default
		eventString = DEFAULT_EVENT_STRING;
	}
}

// default event
const empty_event = function () { };

const sceneEvents = {
	getInitialCommands: function(){

		getCommands();
	}
};
