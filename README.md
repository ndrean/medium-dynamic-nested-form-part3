We summarize different techniques to build forms, with has_many and belongs_to associations, with nested routes, with select or create, and with deep nested associations. Deep nested association with joint table Deep nested association with joint table

We consider the first two tables for the diagramm: we have two associated models, Author and Book with respective attributes title and name associated one-to-many. The foreign key author_id will appear in the table books. Our basics models are:

```ruby
class Book                                 class Author
  belongs_to :author                          has_many :books
  (attr :name)                                (attr :title)
```

We will use the gem _Simple Form_ . We describe how to create ‘new’ forms depending upon which controller is in charge. We will add methods such as accepts_nested_attributes_for for both the has_many and belongs_to to the model depending upon the situation.

## `has_many` association form

You want to create a form to create an author and an associated book and your action is controlled by authors. Then your form model is `Author.new` and you add the method `accepts_nested_attributes_for :books` in the model `Author`. You use the method `collection.build` in the controller and adapt the strong params with `books_attributes` array.

```ruby
# authors_controller.rb
def new
  @author = Author.new; @author.books.build
enddef create
  @author = Author.new(author_params)
if @author.save
  redirect_to authors_path
else
  render :new
enddef author_params
params.require(:author).permit(:name, books_attributes:[:title])
end
```

The view _/authors/new.html.erb_ will need to use the `fields_for` builder to pass the input book.title .

> Note on error handling: in case you want to render back the form and display any error as per your backend validations, you need an instance variable `@author` in your controller to feed the fallback route else render :new . It is simply displayed back in the view using the tag `<% f.error_notification %>` with Simple Form .

```ruby
# authors/new.html.erb
<%= simple_form_for @author do |f| %>
  <%= f.error_notification %>
  <%= f.input :name %>
  <%= f.simple_fields_for :books do |b| %>
    <%= b.input :title %>
  <% end %>
  <%= f.button :submit %>
<% end%>
```

## `belongs_to` association form

You want to create a book and an associated author, and your action is controlled by books. Your form model is Book.new and you will can use `find_or_create`. You need to use the method `build_association` in the controller and the Book model needs to have: `accepts_nested_attributes_for :author` . The strong params need to accept `author_attributes:[:name]`.

```ruby
# books_controller.rbdef new
  @book = Book.new;  @book.build_author
  # accepts_nested_attributes_for :author, in Book model
enddef create
# no error rendering
  author = Author.find_or_create_by(
            name: books_params[:author_attributes][:name])
  book = Book.new(title: books_params[:title])
  book.author = author
  book.save
  redirect_to :author_path
enddef books_params
  params.require(:book).permit(
    :title, :author_id, author_attributes: [:name, :id])
end
```

You need `fields_for` to pass the `author.name` attribute with the model `@book=Book.new`. Your use the association `@book.author`. Adapt the action `url: xxx_path` with your routes (the path to your ‘create’ action triggered on submit).

```ruby
# /books/new.html.erb
<%= simple_form_for @book, url: xxx_path do |b| %>
  <%= b.fields_for :author do |a| %>
    <%= a.input :name,  value_method: :name %>
  <% end %>  <%= b.input :title %>
  <%= b.button :submit %>
<% end %>
```

## Nested routes

You have an author (for example via a link) and you want to create an associated book, and your routes are nested: _authors/:author_id/books_. You want the action to be controlled by books. Your controller should read the params to find the author, instanciate a new Book object and link the objects.

```ruby
# books_controler.rbdef new
  @author = Author.find(params[:author_id]);  @book = Book.new @book.author = @author
enddef create
  @author = Author.find(params[:author_id])
  book = Book.create(books_params)
endprivate
def books_params
  params.require(:book).permit(:title, :author_id)
end
```

In the view, we want to display the name of the `@author` we found, not it’s `author_id`. To populate the input, we can:

- assign a collection to the input with the single instance `@author`, and exclude the blank value. This will display a drop-down select bow with a single value. To further remove the arrow, you can apply a CSS style `.select { -moz-appearance: none; -webkit-appearance: none; }` (for resp. Firefox and Safari,Chrome).
- we can also use `fields_for` to render the associated `@book.author.name` field and use the HTML attribute `value`.

```ruby
# /books/new.html.erb
<%= simple_form_for [@author, @book], url: xxx_path do |b|%><!-- we want to render @author.name, not @book.author_id -->
<!-- method 1, needs CSS arrow hiding trick -->
  <%= b.input :author_id, collection: [@author], include_blank: false %><!-- method 2: doesn't use CSS arrow hiding -->
  <%= b.fields_for :author do |a| %>
    <%= a.input :name, input_html: {value: @author.name} %>
  <%= end %>
<!-- -->  <%= b.input :title %>
  <%= b.button :submit %>
<% end %>
```

## Create or select author and new book

You want to create or select an author and create an associated book. Your action is controlled by books and your model is `Book.new`. Since you want to create or select the associated model `Author`, you need an instance variable, say `@new_author`. For this, we declare an instance variable `new_author` in the `Book` model to store it. The `Author` model is unchanged and the `Book` model is: `belongs_to : author; attr_accessor :new_author`.

```ruby
# books_controller.rbdef book_new
  @book = Book.new;
enddef book_create
  book = Book.new(books_params)
  name = books_params[:new_author]
  if !name.blank?
    book.create_author(name: name)
  else
    book.author = Author.find(books_params[:author_id])
  end
  book.save
  redirect_to :root
endprivate
def books_params
  params.require(:book).permit(:title, :author_id, :new_author)
end
```

and the view

```ruby
# books/new/html.erb
<%= simple_form_for @book, url: xxx_path do |b| %>
  <%= b.input :author_id, collection: Author.all, include_blank: false, label: 'Select an author', prompt: "select an author... %>
  <%= b.input :new_author, label: 'Or create a new author', prompt:'Enter new name' %>
  <%= b.input :title %>
  <%= b.button :submit %>
<% end %>
```

## Deep nested form

Consider four tables associated in the following way:

`[authors] 1<n [books] 1<n [comments] n>1 [readers]`

where the table comments is a joint table between books and readers and the rest are one-to-many associations.

We can create a form that creates an author, an associated book, an associated comment and a new reader.

The controller will be `@author.books.build.comments.build.build_reader` with `@author = Author.new`. The create action is simply `Author.new(authors_params)` with:

```ruby
def authors_params
 params.require(:author).permit(:name,
   books_attributes: [ :title,
     comments_attributes: [:body,
       reader_attributes: [:name ] ] ] )
end
```

The form will be simply:

```ruby
<%= simple_form_for @author do |a| %>
  <%= a.name %>
  <%= a.fields_for :books do |b| %>
    <%= b.title %>
    <%= b.fields_for :comments do |c| %>
      <%= c.body %>
      <%= c.fields_for :reader do |r| %>
        <%= r.name %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

The minimal models will be:

```ruby
class Author
  has_many :books; has_many :comments, through: :books
  accepts_nested_attributes_for :books

class Book
  belongs_to :author
  has_many :comments
  has_many :readers, through: :comments
  accepts_nested_attributes_for :comments

class Comment
  belongs_to :book
  belongs_to :reader
  accepts_nested_attributes_for :reader

class Reader
  has_many :comments
  has_many :books, through: :comments
  has_many :authors, through: :comments
```

## Dynamic “on-the-fly” forms

If you wish to create dynamic “on-the-fly” forms, a solution with Vanilla Javascript is exposed here: <https://github.com/ndrean/medium-dynamic-nested-form-part1>

# SETUP

- BOOTSTRAP
  > Rename _/assets/stylesheets/application.css_ into _/assets/stylesheets/application.Scss_
  > yarn add bootstrap

> In _stylesheets/application.scss_ do:

```ruby
@import "bootstrap/scss/bootstrap";
@import 'myimports;
```

**Layout: for Bootstrop !!!! headers**

```html
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
```

- TURBOLINKS

```html
layouts/application.html.erb <%= javascript_pack_tag 'application',
'data-turbolinks-track': 'reload', defer: true %>
```

/javascript/application.js

```js
document.addEventListener("turbolinks:load", () => {
  if (document.querySelector("#select")) {
    console.log("start");
    addBook();
  }
});
```

- SIMPLE_FORM
  `rails generate simple_form:install --bootstrap`
