# README

Rename /assets/stylesheets/application.css into
/assets/stylesheets/application.Scss and add:

- BOOTSTRAP
  yarn add bootstrap
  ins stylesheets/application.scss:
  @import "bootstrap/scss/bootstrap";
  @import 'myimports;

layout: for Bootstrop !!!! headers

<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

- TURBOLINKS
  layouts/application.html.erb
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload', defer: true %>

/javascript/application.js
document.addEventListener("turbolinks:load", () => {
if (document.querySelector("#select")) {
console.log("start");
addBook();
}
});

- SIMPLE_FORM
  rails generate simple_form:install --bootstrap
