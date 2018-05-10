// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require turbolinks
//= require_tree .
//= require popper
//= require bootstrap-sprockets

$(function() {
	// Add search parameter upon showing/hiding inactive accounts
	$("#server_accounts_list").submit( function(eventObj) {
		$('<input />').attr('type', 'hidden').attr('name', "search").attr('value', $('#search').val()).appendTo('#server_accounts_list');
		return true;
	});

	///-- Search Accounts w/o loading page (ADD AJAX) --//.live() is deprecated, use .on rather --///

	// $("#server_accounts th a, #server_accounts th a asc, #server_accounts th a desc, #server_accounts td input, #server_accounts .pagination a").on("click", function() {
	// 	$.getScript(this.href);
	// 	return false;
	// });

	$(document).on("click", "#server_accounts th a, #server_accounts th a asc, #server_accounts th a desc, #server_accounts td input, #server_accounts .pagination a", function() {

		preloader();

		show_inactive = ($("#show_inactive").is(':checked'));
		search = ($("#search").val());

		ahref = this.href;
		ahref = ahref + '&show_inactive=' + show_inactive + '&search=' + search;
		this.href = ahref;

		$.getScript(this.href);
		return false;
	});

	$("#server_accounts_list").submit(function() {
		$.get(this.action, $(this).serialize(), null, "script");
		return false;
	});
	$("#server_accounts_list input").keyup(function() {
		$.get($("#server_accounts_list").attr("action"), $("#server_accounts_list").serialize(), null, "script");
		return false;
	});
	///-- end of AJAX --///
});

function preloader () {
	var element = $("#animationLoadBackgroud")[0];
	element.classList.toggle("animationload");
	var element = $("#osahanloading")[0];
	element.classList.toggle("osahanloading");
};

function showInactiveAccounts(checkboxElem) {
	preloader();

	if (checkboxElem.checked) {
		checkboxElem.value = 'true';
	};

	$('#server_accounts_list').submit();
};

function setParams (is_editing, server_id) {
	var id = server_id;
	if (id == null || id == '' || id == undefined) {
		id = $('#server_account_Id').val();
	}
	var accountCode = $('#server_account_AccountCode').val();
	var dataSource = $('#server_account_SystemServer').val();
	var useWindowsNT = $('#server_account_UseWindowsNT').is(':checked');
	var username = $('#server_account_Username').val();
	var password = $('#server_account_Password').val();
	var database = $('#server_account_SystemDatabase').val();

	var params = 'id=' + id + '&is_editing=' + is_editing + '&data_source=' + dataSource
    	+ '&database=' + database + '&use_windows_nt=' + useWindowsNT + '&username=' + username + '&password=' + password
    	+ '&account_code=' + accountCode;

    $("#notice").text('');
	$("#notice").removeClass('alert alert-success');
	$("#notice").removeClass('alert alert-danger');

    //Disable once clicked
    $('#btn_test_connection').addClass('disabled');
    $('#btn_update_connection').addClass('disabled');
    $("#btn_close").prop("disabled",true);

    return params;
};

function testConnection (is_editing, id) {
	preloader();
	$('#notice').hide();
	$('#btn_test_connection').attr('href', '/server_accounts/test_connection?' + setParams(is_editing, id));
};

function updateConnection () {
	if(confirm('Are you sure you want to save this?')) {
	    $('#btn_update_connection').attr('href', '/server_accounts/update_connection?' + setParams());
	}
	else {
		$('#btn_update_connection').attr('href', '');
	}
};

function setConnection () {
	if ($('#server_account_Id').val() == 0) {
		//If Setting Connection for New Account. Use Windows NT must be checked
		$("#server_account_UseWindowsNT").prop("checked", true); //Check Windows NT
		$('#server_account_Password').val(''); //Clear Password
		$('#username_password :input').attr('disabled', true);  //Disable UserName and Password
	}
	else {
		if($('#server_account_UseWindowsNT').is(':checked')) { //If Use Windows NT
			$('#username_password :input').attr('disabled', true);  //Disable UserName and Password
			$('#server_account_Password').val(''); //Clear Password
		};
	}
};

function searchAccounts () {
	preloader();
	
	var show_inactive = 'false';
	if ($("#show_inactive").val() == 'true') {
		show_inactive = 'true';
	}

	$("#server_accounts_search").submit( function(eventObj) {
		$('<input />').attr('type', 'hidden').attr('name', "direction").attr('value', $("#direction").val()).appendTo('#server_accounts_search');
		$('<input />').attr('type', 'hidden').attr('name', "sort").attr('value', $("#sort").val()).appendTo('#server_accounts_search');
		$('<input />').attr('type', 'hidden').attr('name', "show_inactive").attr('value', show_inactive).appendTo('#server_accounts_search');
		return true;
	});
};

function acountBtnActions (btn, action) {
	selectedAccountId = $("#table_server_accounts tr.bg-info td:first");
	
	if (selectedAccountId.length == 0) {
		alert('Select record first.');
		btn.preventDefault();
	}
	else {
		selectedAccountId = selectedAccountId[0].innerText;
	}
	switch(action) {
		case 'Show':
			btn.href = "server_accounts/" + selectedAccountId;
			break;
		case 'Edit':
			btn.href = "server_accounts/" + selectedAccountId + "/edit";
			break;
		case 'Delete':
			if (confirm("Are you sure?") == true) {
				btn.href = "server_accounts/" + selectedAccountId;
			} else {
		    	btn.preventDefault();
		    }
			break;
		case 'EnableDisableESS':
		 	var client_code = $("#table_server_accounts tr.bg-info td:eq(1)")[0].innerText;
		    var is_ess_enabled = $("#table_server_accounts tr.bg-info td:eq(6)")[0].innerText;
		    if (confirm("Are you sure?") == true) {
		    	preloader();
		    	$('#btn_enable_disable_ess').addClass('disabled'); //Disable the Button
		        btn.href = 'server_accounts/enable_ess?id=' + selectedAccountId + '&client_code=' + client_code + '&is_ess_enabled=' + is_ess_enabled;
		    } else {
		    	btn.preventDefault();
		    }
		    break;
		case 'TestConnection':
		 	var client_code = $("#table_server_accounts tr.bg-info td:eq(1)")[0].innerText;
		 	testConnection(false, selectedAccountId);
			break;
	}
};