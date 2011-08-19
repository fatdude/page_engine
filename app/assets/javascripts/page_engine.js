$(document).ready(function(){
  if ($('ul#pages').length > 0){
    page_sort();
  };
  
  CKEDITOR.editorConfig = function( config )
  {
	  config.basePath = '/assets/ckeditor';
  };

  $('html').live('ajax:before', function(event, xhr){
    $(event.target).find('input.delete').addClass('waiting');
  });

  var selected_tab = 0;
  var page_parts = $('.page_parts').tabs({
    select: function(event, ui){
      selected_tab = ui.index;
    }
  });

  $('.page_part a.delete').live('click', function(){
    $(this).prev().val(true);
    $('.page_parts').after($(this).prev());
    page_parts.tabs('remove', selected_tab);     
    return false;
  });
  
  $('textarea[data-filter=textile]').each(function(){
    TextileEditor.initialize($(this).attr('id'));
  });
  
  $('textarea[data-filter=wysiwyg]').ckeditor();

  $('select.filter').live('change', function(){
    console.debug('Going to change the filter');
    textarea = $('#' + $(this).attr('rel'));
    filter = textarea.attr('data-filter');
    
    switch ($(this).val()){
      case 'wysiwyg':
        if (filter == 'textile') {
          remove_textile(textarea);
        }
        add_wysiswyg(textarea)
        textarea.attr('data-filter', 'wysiwyg');
        break;
      case 'textile':
        if (filter == 'wysiwyg') {
          remove_wysiwyg(textarea);
        }
        add_textile(textarea)
        textarea.attr('data-filter', 'textile');
        break;
      case 'erb':
        remove_editors(textarea);
        textarea.attr('data-filter', 'erb');
        break;
      case 'erb+textile':
        if (filter == 'wysiwyg') {
          remove_wysiwyg(textarea);
        }
        add_textile(textarea)
        textarea.attr('data-filter', 'erb+textile');
        break;
      case 'none':
        remove_editors(textarea);
        textarea.attr('data-filter', 'none');
        break;
    }
  });
  
  $('#page_no_publish_window').change(function(){
    $('.edit_page .field.publish_from').toggle('slide');
    $('.edit_page .field.publish_to').toggle('slide');
  });
  
  $('textarea.ignore_tab').keypress(function(e){
    if(e.keyCode == 9){
      var pos = $(this).caret().start + 2;
      text = $(this).val().substr(0, $(this).caret().start) + '  ' + $(this).val().substr($(this).caret().start);
      console.debug($(this).val().substr($(this).caret().start));
      $(this).val(text); 
      
		  if ($(this).get(0).setSelectionRange) 
		  { 	
			  $(this).get(0).setSelectionRange(pos, pos); 	
		  } 
		  else if ($(this).get(0).createTextRange) 
		  { 
			  var range = $(this).get(0).createTextRange(); 
			  range.collapse(true); range.moveEnd("character", pos); 
			  range.moveStart("character", pos); range.select(); 
		  } 
      return false;
    }
  });
});

function add_wysiswyg(textarea){
  textarea.ckeditor();
}

function add_textile(textarea){
  id = textarea.attr('id');
  if ($('#textile-toolbar-' + id).length == 0){
    TextileEditor.initialize(id);
  } 
}

function remove_wysiwyg(textarea){
  textarea.ckeditor(function(){
    this.destroy();
  });
}

function remove_textile(textarea){
  $('#textile-toolbar-' + textarea.attr('id')).remove();
}

function remove_editors(textarea){
  filter = textarea.attr('data-filter');
  
  if (filter == 'wysiwyg') {
    remove_wysiwyg(textarea);
  }
  
  if (filter == 'textile' || filter == 'erb+textile') {
    remove_textile(textarea);
  }
}

function page_sort(){
  $(".page").draggable({
    zIndex : 1000000,
    revert : 'invalid',
    opacity : 0.2,
    scroll : true,
    helper : 'clone'
  });

  $('.drop_line').droppable({
    accept : '.page',
    hoverClass : 'drop_target',
    greedy : true,
    tolerance: 'pointer',
    drop: function(ev, ui){
      $('#' + ui.draggable.attr('id') + ' .status').addClass('small_waiting');
      $.ajax({
        data:'position=' + encodeURIComponent($(this).attr('data-position')) + '&position_id=' + encodeURIComponent($(this).attr('data-id')) + '&id=' + encodeURIComponent($(ui.draggable).attr('data-id')),// + '&' + csrf_token + '=' + csrf_param,
        dataType:'script',
        url: $('#pages').attr('data-href'),
        type: 'put'
      })
    },
    over: function(ev, ui){
      $(this).parent().addClass('drag_hover_over');
    },
    out: function(ev, ui){
      $(this).parent().removeClass('drag_hover_over');
    }
  });
}

function add_fields(link, association, content){
  var page_part_name = $('#new_page_part_name').val();
  
  if (page_part_name != ''){
    if ($('#' + page_part_name.replace(/[^a-z0-9\-_]+/ig, '-')).length == 0){
      var new_id = new Date().getTime();
      var regexp = new RegExp("new_" + association, "g");

      $('.page_parts').tabs('add', '#' + new_id, page_part_name);
      $('#' + new_id).html(content.replace(regexp, new_id));
      $('#' + new_id).addClass('page_part');
      $('#' + new_id + ' .field:first input').val(page_part_name);
      $('#new_page_part_name').val('');
    }
    else {
      flash_message('Name already exists', 'alert');      
    }
  } else {
    flash_message('You need to specify a name', 'alert');
  }
}

