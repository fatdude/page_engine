page = Page.create(:title => 'Home')
body = page.page_parts.find_by_title('body')
body.update_attributes(:filter => 'textile', :content => "h1. Welcome

Aenean dictum porttitor arcu vitae vehicula. Nullam posuere augue vitae lorem ultrices facilisis? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non nisi erat? Donec id eros sed metus lobortis semper sed non nulla. Cras cursus ipsum eget neque imperdiet feugiat. Etiam sed sapien id felis aliquam aliquet. Nam fermentum tempus suscipit.

Mauris non mi mi, a vulputate nunc! Phasellus aliquam urna nec lorem consectetur in porttitor sapien laoreet! Nam erat elit, aliquam quis auctor et, tempor quis arcu. Cras diam nunc, mollis pharetra pulvinar eu, dapibus in augue. Aenean malesuada nulla ac neque facilisis congue? Nulla interdum euismod eros; at tempor magna sagittis id. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aliquam orci aliquam.
)")