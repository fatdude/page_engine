var teButtons = TextileEditor.buttons;

teButtons.push(new TextileEditorButton('ed_strong',			'/assets/textile-editor/bold.png',          '*',   '*',  'b', 'Bold','s'));
teButtons.push(new TextileEditorButton('ed_emphasis',		'/assets/textile-editor/italic.png',        '_',   '_',  'i', 'Italicize','s'));
teButtons.push(new TextileEditorButton('ed_underline',	'/assets/textile-editor/underline.png',     '+',   '+',  'u', 'Underline','s'));
teButtons.push(new TextileEditorButton('ed_strike',     '/assets/textile-editor/strikethrough.png', '-',   '-',  's', 'Strikethrough','s'));
teButtons.push(new TextileEditorButton('ed_ol',					'/assets/textile-editor/list_numbers.png',  ' # ', '\n', ',', 'Numbered List'));
teButtons.push(new TextileEditorButton('ed_ul',					'/assets/textile-editor/list_bullets.png',  ' * ', '\n', '.', 'Bulleted List'));
teButtons.push(new TextileEditorButton('ed_p',					'/assets/textile-editor/paragraph.png',     'p',   '\n', 'p', 'Paragraph'));
teButtons.push(new TextileEditorButton('ed_h1',					'/assets/textile-editor/h1.png',            'h1',  '\n', '1', 'Header 1'));
teButtons.push(new TextileEditorButton('ed_h2',					'/assets/textile-editor/h2.png',            'h2',  '\n', '2', 'Header 2'));
teButtons.push(new TextileEditorButton('ed_h3',					'/assets/textile-editor/h3.png',            'h3',  '\n', '3', 'Header 3'));
teButtons.push(new TextileEditorButton('ed_h4',					'/assets/textile-editor/h4.png',            'h4',  '\n', '4', 'Header 4'));
teButtons.push(new TextileEditorButton('ed_block',   		'/assets/textile-editor/blockquote.png',    'bq',  '\n', 'q', 'Blockquote'));
teButtons.push(new TextileEditorButton('ed_outdent', 		'/assets/textile-editor/outdent.png',       ')',   '\n', ']', 'Outdent'));
teButtons.push(new TextileEditorButton('ed_indent',  		'/assets/textile-editor/indent.png',        '(',   '\n', '[', 'Indent'));
teButtons.push(new TextileEditorButton('ed_justifyl',		'/assets/textile-editor/left.png',          '<',   '\n', 'l', 'Left Justify'));
teButtons.push(new TextileEditorButton('ed_justifyc',		'/assets/textile-editor/center.png',        '=',   '\n', 'e', 'Center Text'));
teButtons.push(new TextileEditorButton('ed_justifyr',		'/assets/textile-editor/right.png',         '>',   '\n', 'r', 'Right Justify'));
teButtons.push(new TextileEditorButton('ed_justify', 		'/assets/textile-editor/justify.png',       '<>',  '\n', 'j', 'Justify'));
teButtons.push('<a href="http://textile.thresholdstate.com/" target="_blank" class="help" title="Display help information for textile formatting"><img src="/assets/textile-editor/help.png" alt="Display help information for textile formatting"/></a>');

// teButtons.push(new TextileEditorButton('ed_code','code','@','@','c','Code'));
